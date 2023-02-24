# -*- coding: utf-8 -*-
import os
FILE_BASE = os.path.dirname(os.path.abspath(__file__)) 
import sys
sys.path.append(os.path.join(FILE_BASE, '..','..'))

import pytest
import os
import pandas as pd

import logging
logging.basicConfig(format='%(asctime)s %(levelname)s:%(message)s', level=logging.INFO, datefmt='%Y-%m-%d %H:%M:%S')

from DataManager import DataManager

def load_data(filename, count):
    sim_spec = pd.read_csv(os.path.join(FILE_BASE, filename), index_col=0)
    sim_list = sim_spec.index.values

    dm = DataManager(FILE_BASE)
    dm.load_data(sim_list)
                 
    assert(len(dm.database) == count)

    return dm

def check_headers(dm):
    headers = dm.load_headers('sim_metadata.json')
    for df in dm.database:
        for i, j in zip(df.columns, headers):
            assert(i == j)

def test_load_eta_test():
    dm = load_data('boi_eta_test.csv', 10)
    check_headers(dm)

def test_load_eta_train():
    dm = load_data('boi_eta_train.csv', 100)
    check_headers(dm)

def test_load_hls_test():
    dm = load_data('boi_hls_test.csv', 10)
    check_headers(dm)

def test_load_hls_train():
    dm = load_data('boi_hls_train.csv', 100)
    check_headers(dm)

@pytest.mark.slow
def test_load_all():
    dm = load_data('fault_metadata.csv', 1818)
    check_headers(dm)
