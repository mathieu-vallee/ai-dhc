#!/usr/bin/env python
# coding: utf-8

import os
FILE_BASE = os.path.dirname(os.path.abspath(__file__)) 

import sys
sys.path.append(os.path.join( FILE_BASE, '../..'))

TRAIN_SPEC = os.path.join(FILE_BASE, 'boiler_thl_train.csv')
TEST_SPEC = os.path.join(FILE_BASE, 'boiler_thl_test.csv')

TRAIN_DATA_FILE = os.path.join(FILE_BASE, "df_train_thl.pickle")
TEST_DATA_FILE = os.path.join(FILE_BASE, "df_test_thl.pickle")

HIDDEN_VARS = ['Boiler_Eta','Boiler_G','Boiler_TOut_K']

import logging

import pandas as pd

from utils import DATA_ROOT, save_object
from load_fault_dataset import BoilerFaultLoader

def gen_train_spec():
    loader = BoilerFaultLoader(os.path.join(DATA_ROOT, 'BoilerNoise-20220208')) 

    fault_list = []
    for i in range(1, 5):
        fault_list += loader.get_fault_list(1,  {'G_fault': 0.0  }, context='bc == %d' % i)
        for min_start in range(0, 672, 168):
            start_context = 'G_f_start > %d & G_f_start <= %d' % (min_start, min_start + 168)
            fault_list += loader.get_fault_list(6,  {'G_fault': 1.0  }, context='bc == %d & %s' % (i, start_context))

    fault_spec = loader.get_fault_specs(fault_list)
    return fault_spec

def gen_test_spec():
    loader = BoilerFaultLoader(os.path.join(DATA_ROOT, 'BoilerNoise-20220208')) 

    fault_list = []

    fault_list += loader.get_fault_list(1,  {'G_fault': 0.0  }, context='bc == 0')
    fault_list += loader.get_fault_list(6,  {'G_fault': 1.0  }, context='bc == 0 & G_f_final <= 0.5')
    fault_list += loader.get_fault_list(3,  {'G_fault': 1.0  }, context='bc == 0 & G_f_final > 0.5')

    fault_spec = loader.get_fault_specs(fault_list)
    return fault_spec

def prepare_dataset():
    loader = BoilerFaultLoader(os.path.join(DATA_ROOT, 'BoilerNoise-20220208')) 

    # # Train Data
    train_faults = pd.read_csv(TRAIN_SPEC, index_col=0)
    data_train, metadata_train = loader.load_fault_dataset_df(list(train_faults.index.values))
    df_train = pd.concat(data_train) 
    df_train = df_train.drop(columns=HIDDEN_VARS)

    # # Test Data
    test_faults = pd.read_csv(TEST_SPEC, index_col=0)
    data_test , metadata_test = loader.load_fault_dataset_df(list(test_faults.index.values))
    df_test = pd.concat(data_test)
    df_test = df_test.drop(columns=HIDDEN_VARS)


    logging.info("Saving train data to %s" % TRAIN_DATA_FILE)
    save_object(df_train, TRAIN_DATA_FILE)

    logging.info("Saving test data to %s" % TEST_DATA_FILE)
    save_object(df_test, TEST_DATA_FILE)

#-------------------------------------------------------------------------------
if __name__ == '__main__':
    prepare_dataset()

