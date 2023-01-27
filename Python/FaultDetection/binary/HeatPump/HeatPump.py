#!/usr/bin/env python
# coding: utf-8

import os
FILE_BASE = os.path.dirname(os.path.abspath(__file__)) 

import sys
sys.path.append(os.path.join( FILE_BASE, '../..'))

TRAIN_SPEC = os.path.join(FILE_BASE, 'hp_train.csv')
TEST_SPEC = os.path.join(FILE_BASE, 'hp_test.csv')

TRAIN_DATA_FILE = os.path.join(FILE_BASE, "df_train_hp.pickle")
TEST_DATA_FILE = os.path.join(FILE_BASE, "df_test_hp.pickle")

HIDDEN_VARS = ['Time', 'COP']

import logging
import pandas as pd

from utils import DATA_ROOT, save_object

def prepare_dataset():
    from load_fault_dataset import HeatPumpFaultLoader

    loader = HeatPumpFaultLoader(os.path.join(DATA_ROOT, 'HeatPump-20220908'))

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

