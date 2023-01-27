# -*- coding: utf-8 -*-
import pytest
import os

import logging
logging.basicConfig(format='%(asctime)s %(levelname)s:%(message)s', level=logging.INFO, datefmt='%Y-%m-%d %H:%M:%S')

import random
random.seed(42)

from load_fault_dataset import *

FILE_BASE = os.path.dirname(os.path.abspath(__file__)) 

@pytest.mark.Loading
def test_load_boiler():
    loader = BoilerFaultLoader(os.path.join(FILE_BASE, 'BoilerNoise-20220208'))
    
    data, metadata = loader.load_fault_dataset_df(['BoilerNoise-bc0-s0-000', 'BoilerNoise-bc0-s1-000'])
    assert(len(data) == 2 )

    df_list, metadata = loader.load_fault_dataset(2,  {'eta_fault': 0.5  }, context='bc > 0 & bc < 5')
    assert(len(data) == 2 )

@pytest.mark.Loading
def test_load_storage():

    loader = StorageFaultLoader(os.path.join(FILE_BASE, 'StorageSimplified-20220906'))

    data, metadata = loader.load_fault_dataset_df(['Storage-bc0-s0-000', 'Storage-bc0-s1-000'])
    assert(len(data) == 2 )

    df_list, metadata2 = loader.load_fault_dataset(2,  {'COP_fault': 0.5  }, context='bc > 0 & bc < 5')
    assert(len(df_list) == 2 )

@pytest.mark.Loading
def test_load_heatpump():
    loader = HeatPumpFaultLoader(os.path.join(FILE_BASE, 'HeatPump-20220908')) # indiquer le chemin du dossier contenant les données

    data, metadata = loader.load_fault_dataset_df(['HeatPump-bc00-s0-000', 'HeatPump-bc00-s1-000'])
    assert(len(data) == 2 )

    df_list, metadata2 = loader.load_fault_dataset(2,  {'COP_fault': 0.5  }, context='bc > 0 & bc < 5')
    assert(len(df_list) == 2 )

@pytest.mark.Loading
def test_load_substation():
    loader = SubstationFaultLoader(os.path.join(FILE_BASE, 'Substation-20221015'))

    data = loader.load_numpy_file('Substation-bc0-s0-000', 0)

    # not available on my machine
    data, metadata = loader.load_fault_dataset_df(['Substation-bc0-s0-000', 'Substation-bc0-s1-000'])
    assert(len(data) == 2 )

    df_list, metadata2 = loader.load_fault_dataset(2,  {'fouling_fault': 0.5  }, context='bc > 0 & bc < 5')
    assert(len(df_list) == 2 )

if __name__ == '__main__':
    test_load_boiler()
    test_load_storage()
    test_load_heatpump()
    test_load_substation()