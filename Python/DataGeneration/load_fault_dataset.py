from genericpath import exists
import logging
import os
import pickle
import pandas as pd
import numpy as np
import random

logger = logging.getLogger(__name__)
FILE_BASE = os.path.dirname(os.path.abspath(__file__)) 

class FaultLoader:
    #---------------------------------------------------------------------------
    def load_fault_dataset(self, number, fault_distribution=None, context='all'):
        '''
        Parameters
        ----------
        number : int
            Number N_e of experiments to load.
            The returned data and target will be lists of length N_e, where 
            each element will contain timeseries.

        fault_distribution : dict_like, default = None
            Distribution of fault types in the returned experiments
            Valid dict keys are dependant on the dataset.

            For instance for the boiler fault dataset, the distribution
            { 'eta_fault': 0.1, 'G_fault': 0.1, 'eta_G_fault': 0 }
            would return 10% of experiments with a fault on eta, 
            10% with a fault on G, no experiment with double faults, 
            and 80% of experiments with no faults. 
            
            By default, the distribution sums to 1, and what is not defined 
            will be considered as experiments with no faults

        context: str, list, default='all'
            Restrictions on the context of returned experiements (boundary conditions)
            By default, the returned experiments will be distributed among available context

            It is possible to get experiments on a given context (e.g. only using weather data for month 1),
            by defining a value or list of values for context

        Returns
        -------
        data : [ list of N_e np.ndarray with shape (N_t x N_v) ]
            A list of data coming from different experiments. 
            Each piece of data is an array containing time series of length N_t for N_v variables

        metadata : { dict_like with 
            'data_labels': [ list of N_v str ] 
                Labels of data columns for variables. Naming convention is VariableName_Unit (e.g. Power_W)

            'target_labels': [ list of N_s str ] 
                Labels of targets columns.

            'fault_specs': pandas Dataframe
                Dataframe with N_e lines describing each experiment

            }

        Raises
        ------
        IncorrectFaultDistribution:


        Examples
        --------
        data, target, _ = load_fault_experiments(1000, {'eta_fault': 0.1, 'eta_G_fault', 0.01} )
        assert data[0].shape = (8064, 5)
        '''
        fault_list = self.get_fault_list(number, fault_distribution, context)
        df_list, metadata = self.load_fault_dataset_df(fault_list)
        return df_list, metadata

    #---------------------------------------------------------------------------
    def get_fault_specs(self, fault_list):
        return self._metadata.loc[fault_list]

    #---------------------------------------------------------------------------
    def load_fault_dataset_df(self, fault_list):
        data, metadata = self.load_fault_dataset_np(fault_list)
        df_list = self.make_df(data, metadata)
        return df_list, metadata

    #---------------------------------------------------------------------------
    def load_fault_dataset_np(self, fault_list):
        
        # 1. Making metadata
        fault_specs = self.get_fault_specs(fault_list)
        metadata = {
            'data_labels': self._data_labels,
            'fault_specs': fault_specs
        }

        # 2. Loading data
        data_list = []
        for i, id in enumerate(fault_list):
            # For appending boundary conditions
            bc_id = fault_specs.iloc[i, 0] # XXX same index several times
            data = self.load_numpy_file(id, bc_id)
            data_list.append(data)

        return data_list, metadata

    #---------------------------------------------------------------------------
    def get_fault_list(self, number, fault_distribution, context):
        '''Concrete implementation of load_fault_dataset'''
        print("Base")
    #---------------------------------------------------------------------------
    def init_dataset(self, dataset, prefix):
        self._dataset_base = dataset
        self._dataset_results = os.path.join(self._dataset_base, 'pickle')

        if not os.path.exists(self._dataset_base):
            logger.warn('Dataset does not exist ' + self._dataset_base)
            return # TODO throw exception

        if not os.path.exists(self._dataset_results):
            logger.warn('No picle files in dataset ' + self._dataset_results)
            return # TODO throw exception

        metadata_path = os.path.join(self._dataset_base, prefix+'-metadata.csv')
        if not os.path.exists(metadata_path):
            logger.warn('Dataset has no metadata' + metadata_path)
            return # TODO throw exception

        self._metadata = pd.read_csv(metadata_path, sep=";", index_col=0)

        # Loading boundary conditions files only once
        self._bc_list = []
        for i in range(0, 13):
            bc_file=os.path.join(self._dataset_results, prefix+'-bc%02d.pickle' % i) # XXX using %02d
            # TODO: clean BoilerNoise to avoid special case (bc01 instead of bc1) 
            if (prefix == 'Boiler') and (i > 5):
                # skip
                break

            # XXX: Network has boundary conditions directly in files
            if (prefix == 'Network'):
                # skip
                break

            if not os.path.exists(bc_file):
                logger.warn('Boundary condition file does not exist' + bc_file)
                continue

            data = None # Filled with a numpy array
            with open(bc_file, 'rb') as f:
                data = pickle.load(f)
            
            self._bc_list.append(data)

    #---------------------------------------------------------------------------
    def get_fault_samples(self, nb_samples, query):
        r = self._metadata.query(query)

        all_samples = list(r.index)
        total_nb_samples = len(all_samples)
        if total_nb_samples == 0:
            return []
            
        # If nb_samples > total_nb_samples, put the whole list several times
        sample_ids = all_samples * int(nb_samples/total_nb_samples)
        sample_ids = random.sample(sample_ids, len(sample_ids))

        # Else, append only a randomly chosen subset
        rest = nb_samples % total_nb_samples
        sample_ids += random.sample(all_samples, rest)

        assert(len(sample_ids) == nb_samples)

        return sample_ids

    #---------------------------------------------------------------------------
    def load_numpy_file(self, id, bc_id=None):
        file=os.path.join(self._dataset_results, id +'.pickle')
        if not os.path.exists(file):
            logger.warn('Could not find', file)

        data = None # Filled with a numpy array
        with open(file, 'rb') as f:
            data = pickle.load(f)

        if(bc_id is not None):
            # Appending boundary condition
            nb_lines = data.shape[0] # in case data is shorter than bounday conditions
            data = np.hstack((data, self._bc_list[bc_id][0:nb_lines,:]))

        return data
    #---------------------------------------------------------------------------
    def make_df(self, data_list, metadata):   
          # Creating arrays for start and stop times 
        f_start_idx = [metadata['fault_specs'][self._fault_start_label][i]*self._data_freq 
                        for i in range(len(data_list))]
        f_stop_idx = [metadata['fault_specs'][self._fault_stop_label][i]*self._data_freq 
                        for i in range(len(data_list))]

        df_list = []
        for i in range(len(data_list)):
            df = pd.DataFrame(data_list[i], columns=  metadata['data_labels'])
            delta = list(df.Time*1e9) # TODO set unit='s'
            delta[0] = 0
            df.index = pd.TimedeltaIndex(delta)

            df_r = df.resample('600s').mean()

            size = len(df_r)
            if(size < 4032):
                logger.debug('---- low size %d' % size)
            
            fault = np.zeros(size)
            fault[min(f_start_idx[i], size):min(f_stop_idx[i], size)+1] = 1

            df_r['anomaly'] = fault

            df_list.append(df_r)

        return df_list
#-------------------------------------------------------------------------------
def get_nb_samples(params, total_count, key, current_count):
    '''
    Compute the number of samples for a given fault, based on definition

    Parameters
    ----------
    params: dict_like
        Dictionnary containing the definitinon of the distribution
    total_count: int
        Total number of samples required
    key: str
        Type of fault to look for in params
    current_count: int
        Number of samples already defined

    Returns
    -------
    new_count:
        Number of samples 
    current_count: int
        Number of samples already defined
    '''
    ratio = 0
    try:
        ratio = float(params[key])
    except:
        return 0, current_count

    new_count = int(total_count * ratio)
    if new_count  > (total_count-current_count): 
        logger.warning("Total share exceed (%s : %d + %d > %d)" %
                (key, new_count, current_count, total_count))
        new_count = total_count-current_count # Correcting

    current_count += new_count
    return new_count, current_count
#-------------------------------------------------------------------------------
class BoilerFaultLoader(FaultLoader):
    #---------------------------------------------------------------------------
    def __init__(self, dataset):
        super().__init__()
        self.init_dataset(dataset, 'Boiler')

        self._data_labels = ['Time', 
                'Boiler_FuelPower_W',
                'Boiler_ThermalPower_W', 
                'Boiler_TOut_K',
                'Boiler_G',
                'Boiler_Eta']
        self._data_labels += ['TExt_degC','DemandPower_kW','TSupply_degC','Treturn_degC']

        self._target_labels = None

        self._data_freq = 6
        self._fault_start_label = 'eta_f_start'
        self._fault_stop_label = 'eta_f_stop'
   
    #---------------------------------------------------------------------------
    def get_fault_list(self, nb, fd, context):
        logger.debug("Boiler")

        # 1. Computing number of samples for each type of fault
        nb_tot = 0
        nb_G_fault, nb_tot = get_nb_samples(fd, nb, 'G_fault', nb_tot)
        nb_eta_fault, nb_tot = get_nb_samples(fd, nb, 'eta_fault', nb_tot)
        nb_eta_G_fault, nb_tot =  get_nb_samples(fd, nb, 'eta_G_fault', nb_tot)
        nb_no_fault = nb - nb_tot # Remaining as no fault

        logging.debug("%d no faults, %d G faults, %d eta faults, %d eta G faults" % 
            (nb_no_fault, nb_G_fault, nb_eta_fault, nb_eta_G_fault))

        # 2. Extracting experiments for each type of fault
        fault_list = [] 
        fault_list += self.get_fault_samples(nb_G_fault, 
                    'G_f_type > 0 & eta_f_type == 0 & ' + context)
        fault_list += self.get_fault_samples(nb_eta_fault, 
                    'G_f_type == 0 & eta_f_type > 0 & ' + context)
        fault_list += self.get_fault_samples(nb_eta_G_fault, 
                    'G_f_type > 0 & eta_f_type > 0 & ' + context)
        fault_list += self.get_fault_samples(nb_no_fault, 
                    'G_f_type == 0 & eta_f_type == 0 & ' + context)

        logging.debug(fault_list)

        return fault_list

    #------------------------------------------------------------------------------- 
    def make_df(self, data, metadata, num_class=1):
        df_list = []
        meta = metadata['fault_specs'].reset_index()
        
        for ii in range(len(data)):
            # Handling case of missing time col in saved pickle files
            if(data[ii].shape[1] == len(metadata['data_labels']) - 1):
                # Case of first BoilerNoise dataset
                logger.warn('Adapting to BoilerNoise-20220208 dataset') 
                metadata['data_labels'] = metadata['data_labels'][1:]
                self._data_freq = 60/5 # Setting data frequency 5 min 

            df = pd.DataFrame(data=data[ii], columns=metadata['data_labels'])

            df['Boiler_TOut_degC'] = df['Boiler_TOut_K'] - 273.15

            class_eta = 1
            class_G = 1
            if(num_class > 1):
                class_G = 2     
            # XXX should trigger a warning if inconsistent
            # XXX should use value 3 when both faults at the same time

            fault_spec = meta.loc[ii]

            size = len(df)
            fault_class = np.zeros(len(df))
            if(int(fault_spec['eta_f_type']) > 0):
                start_idx   = int(fault_spec['eta_f_start'] * self._data_freq)
                stop_idx    = int(fault_spec['eta_f_stop']  * self._data_freq)    
                fault_class[min(start_idx,size):min(stop_idx, size)+1] = class_eta
            if(int(fault_spec['G_f_type']) > 0):
                start_idx   = int(fault_spec['G_f_start'] * self._data_freq)
                stop_idx    = int(fault_spec['G_f_stop']  * self._data_freq)    
                fault_class[min(start_idx,size):min(stop_idx, size)+1] = class_G

            df['anomaly'] = fault_class
            df_list.append(df)

        return df_list

#-------------------------------------------------------------------------------
class StorageFaultLoader(FaultLoader):
    #---------------------------------------------------------------------------
    def __init__(self, dataset):
        super().__init__()
        self.init_dataset(dataset, 'Storage')

        self._data_labels = ['Time',
                            'ChargeSP_W',
                            'DischargeSP_W',
                            'Charge_Discharge_W',
                            'TempIn_K',
                            'TempOut_K',
                            'MFR_kg_s']
        self._data_labels += ['TempStorage%d_K' % i for i in range(1,11)]

        self._data_labels += ['TExt_degC','DemandPower_kW','TSupply_degC','Treturn_degC']

        self._target_labels = None

        self._data_freq = 6
        self._fault_start_label = 'kIns_f_start'
        self._fault_stop_label = 'kIns_f_stop'

    #---------------------------------------------------------------------------
    def get_fault_list(self, nb, fd, context):
        logger.debug("Storage")

        # 1. Computing number of samples for each type of fault
        nb_tot = 0
        nb_kIns_fault, nb_tot = get_nb_samples(fd, nb, 'kIns_fault', nb_tot)
        nb_no_fault = nb - nb_tot # Remaining as no fault

        logging.debug(" %d no faults, %d kIns faults" % 
            (nb_no_fault, nb_kIns_fault))

        # 2. Extracting experiments for each type of fault
        fault_list = [] 
        fault_list += self.get_fault_samples(nb_kIns_fault, 
                    'kIns_f_type > 0 & ' + context)
        fault_list += self.get_fault_samples(nb_no_fault, 
                    'kIns_f_type == 0 & ' + context)

        logging.debug(fault_list)

        return fault_list

#-------------------------------------------------------------------------------
class HeatPumpFaultLoader(FaultLoader):
    #---------------------------------------------------------------------------
    def __init__(self, dataset):
        super().__init__()
        self.init_dataset(dataset, 'HeatPump')

        self._data_labels = ['Time',
                             'COP', 'P_elec', 'P_cond', 
                                   'T_cond_in', 'T_cond_out', 
                                   'T_eva_in', 'T_eva_out']

        self._data_labels += ['TExt_degC','DemandPower_kW','TSupply_degC','Treturn_degC']

        self._target_labels = None

        self._data_freq = 6
        self._fault_start_label = 'COP_f_start'
        self._fault_stop_label = 'COP_f_stop'

    #---------------------------------------------------------------------------
    def get_fault_list(self, nb, fd, context):
        logger.debug("HeatPump")

        # 1. Computing number of samples for each type of fault
        nb_tot = 0
        nb_fault, nb_tot = get_nb_samples(fd, nb, 'COP_fault', nb_tot)
        nb_no_fault = nb - nb_tot # Remaining as no fault

        logging.debug(" %d no faults, %d COP faults" % 
            (nb_no_fault, nb_fault))

        # 2. Extracting experiments for each type of fault
        fault_list = [] 
        fault_list += self.get_fault_samples(nb_fault, 
                    'COP_f_type > 0 & ' + context)
        fault_list += self.get_fault_samples(nb_no_fault, 
                    'COP_f_type == 0 & ' + context)

        logging.debug(fault_list)

        return fault_list

    #-------------------------------------------------------------------------------
class SubstationFaultLoader(FaultLoader):
    #---------------------------------------------------------------------------
    def __init__(self, dataset):
        super().__init__()
        self.init_dataset(dataset, 'Substation')

        self._data_labels = ['Time',
                            'UA', 
                            'POS_%',
                            'TIN_p_K',
                            'TOUT_p_K',
                            'UA_mod']

        self._data_labels += ['TExt_degC','DemandPower_kW','TSupply_degC','Treturn_degC']

        self._target_labels = None

        self._data_freq = 6 # could be 12 but need to change resample in add_anomalies
        self._fault_start_label = 'f1_start'
        self._fault_stop_label = 'f1_stop'

    #---------------------------------------------------------------------------
    def get_fault_list(self, nb, fd, context):
        logger.debug("Substation")

        # 1. Computing number of samples for each type of fault
        nb_tot = 0
        nb_flg_fault, nb_tot = get_nb_samples(fd, nb, 'fouling_fault', nb_tot)
        nb_no_fault = nb - nb_tot # Remaining as no fault

        logging.debug(" %d no faults, %d fouling faults" % 
            (nb_no_fault, nb_flg_fault, ))

        # 2. Extracting experiments for each type of fault
        fault_list = [] 
        fault_list += self.get_fault_samples(nb_flg_fault, 
                    'f1_type > 0 & ' + context)
        fault_list += self.get_fault_samples(nb_no_fault, 
                    'f1_type == 0 & ' + context)

        logging.debug(fault_list)

        return fault_list

class LinearNetworkFaultLoader(FaultLoader):

        def __init__(self, dataset):
            super().__init__()
            self.init_dataset(dataset, 'Network')

            # Mapping from Modelica names to Python namesw
            columns = {'BC_TimeTable.y[3]': 'T_Ext_degC', 
                    'BC_TimeTable.y[6]': 'P_dem_kW',
                    'BC_TimeTable.y[7]': 'T_sup_degC',
                    'BC_TimeTable.y[8]': 'T_ret_degC'}
            for i in range(1,10): # iterate on pipes
                columns['linearNetwork.fuite_COLD[%d].m_flow' % i] = 'leak_mfr_%02d_kg_s' % i
            for i in range(1,11): # iterate on substations
                columns['linearNetwork.Consumer_ReturnPressure[%d]' % i] = 'pres_ret_%02d_bar' % i
            for i in range(1,11): # separate loop to group by variable type
                columns['linearNetwork.TnetworkReturn[%d]' % i] = 'Tret_%02d_degC' % i

            self._data_labels = ['Time_s']
            self._data_labels += list(columns.values())
            self._data_labels += ['fault_class']

            self._target_labels = []


        def load_numpy_file(self, id, bc_id=None):
            # Overriding because no boundary condition files to load
            return super().load_numpy_file(id, None)

        def load_fault_dataset_df(self, number, fault_distribution=None, 
            data_cols=None, target_cols=None, context='all'):
            # Overriding because fault class already there

            data_list, _, metadata = self.load_fault_dataset(number, fault_distribution, 
                                                    data_cols, target_cols, context)

            df_list = []
            for d in data_list:
                df = pd.DataFrame(d, columns=self._data_labels)
                delta = df['Time_s']
                df.index = pd.TimedeltaIndex(delta, unit='s')
                df_list.append(df)

            return df_list, metadata

        def get_fault_list(self, nb, fd, context):
            logger.debug("LinearNetwork")

            # 1. Computing number of samples for each type of fault
            nb_tot = 0
            nb_leak_fault, nb_tot = get_nb_samples(fd, nb, 'leak_fault', nb_tot)
            nb_no_fault = nb - nb_tot # Remaining as no fault

            logging.debug(" %d no faults, %d leak faults" % 
                (nb_no_fault, nb_leak_fault))

            # 2. Extracting experiments for each type of fault
            fault_list = [] 
            fault_list += self.get_fault_samples(nb_leak_fault, 
                        'Leak_f_type > 0 & ' + context)
            fault_list += self.get_fault_samples(nb_no_fault, 
                        'Leak_f_type == 0 & ' + context)

            logging.debug(fault_list)

            return fault_list

# if __name__ == "__main__":
#     loader = BoilerFaultLoader()
#     loader.load_fault_dataset(1)
