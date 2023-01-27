# -*- coding: utf-8 -*-
"""
Created on Tue May 10 12:25:55 2022

@author: MV242848
"""
import sys
import os
import shutil
from subprocess import Popen, PIPE
import random

#-----------------------------------------------------------------------------
import set_python_path # Manual setting of path
from set_python_path import DYMOSIM_BASE_PATH, DATA_PATH

from dymola.dymola_interface import DymolaInterface
import dymolaUtilities as dymU
import generate_signal_defauts as GD
#-----------------------------------------------------------------------------


#-----------------------------------------------------------------------------
# Class definition
#-----------------------------------------------------------------------------
class DymosimExec(object):
    
    def __init__(self, dymosim_path, data_path):
        self._dymola = None

        self._dymosim_path = dymosim_path
        self._data_path = data_path
            
        self._bc_txt = self.make_path('applied_boundary_conditions.txt')
        self._fault1_txt = self.make_path('applied_fault_1.txt')
        self._fault2_txt = self.make_path('applied_fault_2.txt')
        dymosim_script = 'dymosim.sh' if os.name == 'posix' else 'dymosim.bat'
        self._dymosim_exe = self.make_path(dymosim_script)
        self._dymosim_status = self.make_path('status')
        self._result_mat = self.make_path('dsres.mat')
        self._variables_to_read = []
        self._variable_headers = [] # TODO                                  
        self._counter = 0
        
    def __enter__(self):
        # so it can be used when dymola.interface is not available
        #self._dymola = DymolaInterface() 
        return self

    def __exit__(self, a, b, c):
        # so it can be used when dymola.interface is not available
        #self._dymola.close()
        pass

    def clean_input_files(self):
        if(os.path.exists(self._fault1_txt)):
            os.remove(self._fault1_txt)
            #shutil.move(self._fault1_txt, self._fault1_txt+str(self._counter))

        if(os.path.exists(self._fault2_txt)):
            os.remove(self._fault2_txt)
            #shutil.move(self._fault2_txt, self._fault2_txt+str(self._counter))

        self._counter = self._counter + 1

    def make_path(self, *paths):
        return os.path.join(self._dymosim_path, *paths)

    def set_boundary_conditions(self, month):       
        bc_file = os.path.join(self._data_path, 'BC', 'data_BC_%d.txt' % month)
        # logging.debug("using boundary conditions from", bc_file)
        shutil.copy(bc_file, self._bc_txt)

    def run_fault_experiment(self, fault1, fault2):     
        self.clean_input_files()
        
        if fault1 is None:
            fault1 = {'type': 'step', 'initial_value':0, 'final_value':0, 
                      'start':0, 'stop':0}
        
        if fault2 is None:
            fault2 = {'type': 'step', 'initial_value':0, 'final_value':0, 
                      'start':0, 'stop':0}
        
        tmp_id = '%d' % round(100* random.random())
        
        GD.generate_defaut_file(tmp_id + '1', fault1['type'], fault1)            
        shutil.move('Data_DC_'+tmp_id+'1.txt', self._fault1_txt)
        
        GD.generate_defaut_file(tmp_id + '2', fault2['type'], fault2)
        shutil.move('Data_DC_'+tmp_id+'2.txt', self._fault2_txt)
        
        with Popen([self._dymosim_exe], stdout=PIPE) as proc:
            print(proc.stdout.read())
    #---------------------------------------------------------------------------
    def read_results(self, variables=None):
        if(variables is None):
            variables = self._variables_to_read

        try:
            if self._dymola is None:
                self._dymola = DymolaInterface()

            df = dymU.read_trajectories(self._dymola, 
                                      variables, 
                                      self._result_mat)
        except ConnectionRefusedError as ex:
            print(ex)
            print("Retrying ..................................")
            # try again after reopening
            self._dymola.close()
            self._dymola = DymolaInterface()
            df = dymU.read_trajectories(self._dymola, 
                                      variables, 
                                      self._result_mat)
        
        return df
    #---------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# For Boiler model
#-----------------------------------------------------------------------------
class DymosimExecBoiler(DymosimExec):
    
    def __init__(self, dymosim_path, data_path):
        super().__init__(dymosim_path, data_path)
        self._variables_to_read = ['boilerNoControl_modif.fuelPower',
                         'boilerNoControl_modif.QflowCalculation.y',
                         'boilerNoControl_modif.G_modifier.y',
                         'boilerNoControl_modif.eta_tot',
        #                     'LHV_noise.y',
                         'boilerNoControl_modif.T_out']

#-------------------------------------------------------------------------------
# For Storage model
#-------------------------------------------------------------------------------
class DymosimExecStorage(DymosimExec):
    def __init__(self, dymosim_path, data_path):
        super().__init__(dymosim_path, data_path)
        self._storage_bc_txt = super().make_path('applied_storage_setpoint.txt')
        self._variables_to_read = ['Charge.y', 'Discharge.y', 'Storage.Pdecharge', 
                                   'Tin.T', 'Tout.T', 'Source.ports[1].m_flow'] 
        self._variables_to_read += ['Storage.vol[%d].T' % i for i in range(1,11)]

    def set_boundary_conditions(self, month):       
        super().set_boundary_conditions(month)
        storage_bc_file = os.path.join(self._data_path, 'Storage_setpoint',
        # XXX using same setpoints each time 'Storage_setpoint_%d.txt' % month)
                                             'Storage_setpoint_simplified.txt')
        # print("using boundary conditions from", bc_file)
        shutil.copy(storage_bc_file, self._storage_bc_txt)

#-------------------------------------------------------------------------------
# For HeatPump model
#-------------------------------------------------------------------------------
class DymosimExecHeatPump(DymosimExec):
    def __init__(self, dymosim_path, data_path):
        super().__init__(dymosim_path, data_path)
        self._variables_to_read = ['COP', 'P_elec', 'P_cond', 
                                   'T_cond_in', 'T_cond_out', 
                                   'T_eva_in', 'T_eva_out'] 

#-------------------------------------------------------------------------------
# For Substation model
#-------------------------------------------------------------------------------
class DymosimExecSubstation(DymosimExec):
    def __init__(self, dymosim_path, data_path):
        super().__init__(dymosim_path, data_path)
        self._variables_to_read = ['linearNetwork.SST[1].UA', 
                                   'linearNetwork.SST[1].POS',
                                   'linearNetwork.SST[1].TIN_p',
                                   'linearNetwork.SST[1].TOUT_p',
                                   'linearNetwork.UA_ext[1]'] 

        # XXX Different for substations based on linear network
        self._fault1_txt = self.make_path('applied_fault_3.txt')

#-----------------------------------------------------------------------------
# Main program
#-----------------------------------------------------------------------------
if __name__ == '__main__':   
    bc = 4
    fault1 = {'type': 'step', 'initial_value':0, 'final_value':1, 
              'start':10, 'stop':672}
    fault2 = {'type': 'step', 'initial_value':0, 'final_value':1, 
              'start':10, 'stop':672}

    boiler_path = os.path.join(DYMOSIM_BASE_PATH, 'Boiler')
    with DymosimExecBoiler(boiler_path, DATA_PATH) as dymosim:
        dymosim.set_boundary_conditions(bc)
        
        for i in range(0,1):           
            dymosim.run_fault_experiment(fault1, fault2)   
            df = dymosim.read_results()
            check_a = df['boilerNoControl_modif.G_modifier.y'][-1] - df['boilerNoControl_modif.G_modifier.y'][0]
            check_b = df['boilerNoControl_modif.eta_tot'][-1] - df['boilerNoControl_modif.eta_tot'][0]
            check_c = df['BC_TimeTable.y[6]'][0]
            print(check_a, check_b, check_c)
#-----------------------------------------------------------------------------
