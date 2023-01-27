#!/usr/bin/env python
# coding: utf-8

import os
FILE_BASE = os.path.dirname(os.path.abspath(__file__)) 

import sys
sys.path.append(os.path.join( FILE_BASE, '../..'))

TRAIN_SPEC = os.path.join(FILE_BASE, 'sst_train.csv')
TEST_SPEC = os.path.join(FILE_BASE, 'sst_test.csv')

TRAIN_DATA_FILE = os.path.join(FILE_BASE, "df_train_sst_real.pickle")
TEST_DATA_FILE = os.path.join(FILE_BASE, "df_test_sst_real.pickle")

TRAIN_SIZE = 100
TEST_SIZE = 10

HIDDEN_VARS=['Time', 'UA', 'UA_mod'] + ['POS_%', 'TExt_degC','TSupply_degC','Treturn_degC']

import logging

import pandas as pd

from utils import DATA_ROOT, save_object
from load_fault_dataset import SubstationFaultLoader

def prepare_dataset():
    loader = SubstationFaultLoader(os.path.join(DATA_ROOT, 'Substation-20221015'))

    # # Train Data
    train_faults = pd.read_csv(TRAIN_SPEC, index_col=0)
    data_train, metadata_train = loader.load_fault_dataset_df(list(train_faults.index.values))
    df_train = pd.concat(data_train) 
    df_train.drop(columns=HIDDEN_VARS, inplace=True)
    df_train['TIN_s_K'] = 48 + 237.15
    df_train['TOUT_s_K'] = 70 + 237.15

    # # Test Data
    test_faults = pd.read_csv(TEST_SPEC, index_col=0)
    data_test , metadata_test = loader.load_fault_dataset_df(list(test_faults.index.values))
    df_test = pd.concat(data_test)
    df_test.drop(columns=HIDDEN_VARS, inplace=True)
    df_test['TIN_s_K'] = 48 + 237.15
    df_test['TOUT_s_K'] = 70 + 237.15

    logging.info("Saving train data to %s" % TRAIN_DATA_FILE)
    save_object(df_train, TRAIN_DATA_FILE)

    logging.info("Saving test data to %s" % TEST_DATA_FILE)
    save_object(df_test, TEST_DATA_FILE)

#-------------------------------------------------------------------------------
if __name__ == '__main__':
    prepare_dataset()

