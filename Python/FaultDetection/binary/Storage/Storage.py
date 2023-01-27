#!/usr/bin/env python
# coding: utf-8

import os
FILE_BASE = os.path.dirname(os.path.abspath(__file__)) 
import sys
sys.path.append(os.path.join( FILE_BASE, '../..'))

TRAIN_SPEC = os.path.join(FILE_BASE, 'sto_train.csv')
TEST_SPEC = os.path.join(FILE_BASE, 'sto_test.csv')

TRAIN_DATA_FILE = os.path.join(FILE_BASE, "df_train_sto.pickle")
TEST_DATA_FILE = os.path.join(FILE_BASE, "df_test_sto.pickle")

TRAIN_SIZE = 100
TEST_SIZE = 10

HIDDEN_VARS=['Time']

import logging
import pandas as pd

from utils import DATA_ROOT, save_object
from load_fault_dataset import StorageFaultLoader

def gen_train_spec():
    loader = StorageFaultLoader(os.path.join(DATA_ROOT, 'StorageSimplified-20220906'))

    fault_list = []
    for i in range(1, 5):
        fault_list += loader.get_fault_list(1,  {'kIns_fault': 0.0  }, context='bc == %d' % i)
        for min_start in range(0, 672, 168):
            start_context = 'kIns_f_start > %d & kIns_f_start <= %d' % (min_start, min_start + 168)
            fault_list += loader.get_fault_list(6,  {'kIns_fault': 1.0  }, context='bc == %d & %s' % (i, start_context))

    fault_spec = loader.get_fault_specs(fault_list)
    return fault_spec

def gen_test_spec():
    loader = StorageFaultLoader(os.path.join(DATA_ROOT, 'StorageSimplified-20220906'))

    fault_list = []

    fault_list += loader.get_fault_list(1,  {'kIns_fault': 0.0  }, context='bc == 0')
    fault_list += loader.get_fault_list(6,  {'kIns_fault': 1.0  }, context='bc == 0 & kIns_f_final <= 0.5')
    fault_list += loader.get_fault_list(3,  {'kIns_fault': 1.0  }, context='bc == 0 & kIns_f_final > 0.5')

    fault_spec = loader.get_fault_specs(fault_list)
    return fault_spec

def prepare_dataset():
    from load_fault_dataset import StorageFaultLoader

    loader = StorageFaultLoader(os.path.join(DATA_ROOT, 'StorageSimplified-20220906'))

    # # Train Data
    train_faults = pd.read_csv(TRAIN_SPEC, index_col=0)
    data_train, metadata_train = loader.load_fault_dataset_df(list(train_faults.index.values))
    df_train = pd.concat(data_train) 
    df_train.drop(columns=HIDDEN_VARS, inplace=True)

    # # Test Data
    test_faults = pd.read_csv(TEST_SPEC, index_col=0)
    data_test , metadata_test = loader.load_fault_dataset_df(list(test_faults.index.values))
    df_test = pd.concat(data_test)
    df_test.drop(columns=HIDDEN_VARS, inplace=True)


    logging.info("Saving train data to %s" % TRAIN_DATA_FILE)
    save_object(df_train, TRAIN_DATA_FILE)

    logging.info("Saving test data to %s" % TEST_DATA_FILE)
    save_object(df_test, TEST_DATA_FILE)

#-------------------------------------------------------------------------------
if __name__ == '__main__':
    prepare_dataset()

