#!/usr/bin/env python
# coding: utf-8

import os
FILE_BASE = os.path.dirname(os.path.abspath(__file__)) 
DATA_ROOT = os.path.join(FILE_BASE, '../DataGeneration')

# DATA_ROOT = '/home/570.75.83-21-00152-AI_DHC/2021-Projet-AI_DHC/Python/DataGeneration'
# DATA_ROOT = r'C:\Users\mv242848\Desktop\2021-Projet-AI_DHC\Python\DataGeneration'
# DATA_ROOT = 'S:/370-Energie/370.75-SYS2T/370.75.83-21-00152-AI_DHC/50-Donnee Technique/DataGeneration'

import sys
sys.path.insert(0, DATA_ROOT)

import pickle

from cmath import nan
import pandas as pd
import numpy as np

#-------------------------------------------------------------------------------
def save_object(obj, file_name):
    with open(file_name, 'wb') as file:
        pickle.dump(obj, file)

#-------------------------------------------------------------------------------
def load_object(file_name):
    with open(file_name, 'rb') as file:
        return pickle.load(file)

#-------------------------------------------------------------------------------
def load_data(file_name):
    df = load_object(file_name)

    # # Split Data
    x = df.drop(['anomaly'], axis = 1)
    y = df['anomaly']
    return  x,  y

#-------------------------------------------------------------------------------
class DataManager:
    def __init__(self):
        self.database      = None
        self.del_cols_data = None
        self.database_id   = None
        self.nan_row       = None

    def prepare_database(self, df_list, metadata, del_cols=[]):
        self.nan_row       = 0
        self.database_id   = [None] * len(df_list)
        self.del_cols_data = [None] * len(df_list)
        self.database      = [None] * len(df_list)
        metadata['fault_specs'].reset_index(inplace=True)

        for ii in range(len(df_list)):
            df          = df_list[ii].copy()  
            df['class'] = df['anomaly']
            self.database_id[ii] = metadata['fault_specs'].loc[ii, 'id']    
            if len(del_cols) > 0:
                self.del_cols_data[ii] = df[del_cols]
                df.drop(del_cols, axis=1, inplace=True) 
            self.database[ii] = df 
            self.database[ii].dropna(subset = self.database[ii].columns, inplace=True)
               
    def add_last_info(self, col_names, horizon):
        if( len(col_names) > 0):
            self.nan_row = max(self.nan_row, horizon - 1)
    
        for ii in range(len(self.database)):
            for name in col_names:
                values = self.database[ii][name].values
                for jj in range(1, horizon):
                    delayed_vals = np.hstack([[nan]*jj, values[0:-jj]])
                    self.database[ii][f'{name}_{jj}'] = delayed_vals
                    #self.database[ii].loc[jj:, f'{name}_{jj}'] = values[0:-jj]  
        
    def add_statistic_info(self, col_names, horizon):
        if( len(col_names) > 0):
            self.nan_row = max(self.nan_row, horizon - 1)

        for ii in range(len(self.database)):
            for name in col_names:
                self.database[ii][f'{name}_mean'] = self.database[ii][name].rolling(horizon).mean()
                self.database[ii][f'{name}_var']  = self.database[ii][name].rolling(horizon).var()
        
    def split_X_Y(self):
        X, Y = [], []
        for ii in range(len(self.database)):
            self.database[ii].dropna(subset = self.database[ii].columns, inplace=True)
            self.database[ii].reset_index(drop=True, inplace=True)
            X.append(self.database[ii].loc[: , self.database[ii].columns!='class'].copy())
            Y.append(self.database[ii]['class'])
            self.del_cols_data[ii] = self.del_cols_data[ii].iloc[self.nan_row:] 
            self.del_cols_data[ii][0:self.nan_row] = nan
            self.del_cols_data[ii].reset_index(drop=True, inplace=True)
        return X, Y

    def split_X_Y_concat(self):
        X, Y = self.split_X_Y()
        return pd.concat(X, ignore_index=True), pd.concat(Y, ignore_index=True)