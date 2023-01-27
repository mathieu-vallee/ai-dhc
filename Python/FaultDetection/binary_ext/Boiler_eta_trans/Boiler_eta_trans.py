#!/usr/bin/env python
# coding: utf-8

import os
FILE_BASE = os.path.dirname(os.path.abspath(__file__)) 

import sys
sys.path.append(os.path.join( FILE_BASE, '../..'))

# TRAIN_SPEC = os.path.join(FILE_BASE, 'boiler_trans_train.csv')
# TEST_SPEC = os.path.join(FILE_BASE, 'boiler_trans_test.csv')

TRAIN_DATA_FILE = os.path.join(FILE_BASE, "df_train_trans.pickle")
TEST_DATA_FILE = os.path.join(FILE_BASE, "df_test_trans.pickle")

HIDDEN_COLS = ['Time', 'Boiler_Eta','Boiler_G','Boiler_TOut_K']

import logging

import pandas as pd

from utils import DATA_ROOT, save_object
from load_fault_dataset import BoilerFaultLoader

def gen_train_spec(size):
    loader = BoilerFaultLoader(os.path.join(DATA_ROOT, 'BoilerVarSize-20221122/BoilerVarSize%d' % size)) 

    fault_list = []
    for i in range(1, 5):
        fault_list += loader.get_fault_list(1,  {'eta_fault': 0.0  }, context='bc == %d' % i)
        for min_start in range(0, 672, 168):
            start_context = 'eta_f_start > %d & eta_f_start <= %d' % (min_start, min_start + 168)
            fault_list += loader.get_fault_list(6,  {'eta_fault': 1.0  }, context='bc == %d & %s' % (i, start_context))

    fault_spec = loader.get_fault_specs(fault_list)

    return fault_spec

def gen_test_spec():
    loader = BoilerFaultLoader(os.path.join(DATA_ROOT, 'BoilerTrans-20221212')) 

    fault_list = []
    for i in range(1, 5):
        fault_list += loader.get_fault_list(1,  {'eta_fault': 0.0  }, context='bc == %d' % i)
        for min_start in range(0, 672, 168):
            start_context = 'eta_f_start > %d & eta_f_start <= %d' % (min_start, min_start + 168)
            fault_list += loader.get_fault_list(6,  {'eta_fault': 1.0  }, context='bc == %d & %s' % (i, start_context))

    fault_spec = loader.get_fault_specs(fault_list)

    return fault_spec


def prepare_dataset():

    all_data_train = []

   # Train Data from sources boiler, with faults
    for i in [2]:
        loader = BoilerFaultLoader(os.path.join(DATA_ROOT, 'BoilerVarSize-20221122/BoilerVarSize%d' % i)) 

        # # Train Data
        train_spec =os.path.join(FILE_BASE, 'train_size%d.csv' % i)
        train_faults = pd.read_csv(train_spec, index_col=0)
        data_train, metadata_train = loader.load_fault_dataset_df(list(train_faults.index.values))
        all_data_train += data_train

   # Train Data from target boiler, without faults
    loader = BoilerFaultLoader(os.path.join(DATA_ROOT, 'BoilerTrans-20221212')) 

    train_spec =os.path.join(FILE_BASE, 'train_target_nofaults.csv')
    train_faults = pd.read_csv(train_spec, index_col=0)
    data_train, metadata_train = loader.load_fault_dataset_df(list(train_faults.index.values))
    all_data_train += data_train

    # Compiling train data
    df_train = pd.concat(all_data_train) 
    df_train = df_train.drop(columns=HIDDEN_COLS)

    # # Test Data
    loader = BoilerFaultLoader(os.path.join(DATA_ROOT, 'BoilerTrans-20221212'))

    test_spec =os.path.join(FILE_BASE, 'test_target_faults.csv')
    test_faults = pd.read_csv(test_spec, index_col=0)
    data_test , metadata_test = loader.load_fault_dataset_df(list(test_faults.index.values))
    df_test = pd.concat(data_test)
    df_test = df_test.drop(columns=HIDDEN_COLS)

    logging.info("Saving train data to %s" % TRAIN_DATA_FILE)
    save_object(df_train, TRAIN_DATA_FILE)

    logging.info("Saving test data to %s" % TEST_DATA_FILE)
    save_object(df_test, TEST_DATA_FILE)


def prepare_dataset_v0():

    all_data_train = []
    for i in [1,2,3,8]:
        loader = BoilerFaultLoader(os.path.join(DATA_ROOT, 'BoilerVarSize-20221122/BoilerVarSize%d' % i)) 

        # # Train Data
        train_spec =os.path.join(FILE_BASE, 'train_size%d.csv' % i)
        train_faults = pd.read_csv(train_spec, index_col=0)
        data_train, metadata_train = loader.load_fault_dataset_df(list(train_faults.index.values))
        all_data_train += data_train
        
    df_train = pd.concat(all_data_train) 
    df_train = df_train.drop(columns=['Time', 'Boiler_Eta','Boiler_G','Boiler_TOut_K'])

    # # Test Data
    loader = BoilerFaultLoader(os.path.join(DATA_ROOT, 'BoilerVarSize-20221122/BoilerVarSize3'))

    test_spec =os.path.join(FILE_BASE, 'test_size3.csv')
    test_faults = pd.read_csv(test_spec, index_col=0)
    data_test , metadata_test = loader.load_fault_dataset_df(list(test_faults.index.values))
    df_test = pd.concat(data_test)
    df_test = df_test.drop(columns=['Time', 'Boiler_Eta','Boiler_G','Boiler_TOut_K'])


    logging.info("Saving train data to %s" % TRAIN_DATA_FILE)
    save_object(df_train, TRAIN_DATA_FILE)

    logging.info("Saving test data to %s" % TEST_DATA_FILE)
    save_object(df_test, TEST_DATA_FILE)

#-------------------------------------------------------------------------------
if __name__ == '__main__':
    prepare_dataset()

