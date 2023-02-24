import os
import pandas as pd

class DataManager:
    def __init__(self, base_path):
        self.base_path = base_path
        self.database_id   = []
        self.database      = []

    def load_headers(self, filename):
        import json
        with open(filename, 'r') as f:
            sim_md = json.load(f)

        columns = [v['Name'] for v in sim_md['variables']]
        columns += [v['Name'] for v in sim_md['variables.boundaries']]
        columns += [v['Name'] for v in sim_md['variables.anomalies']]

        return columns

    def load_data(self, fault_list):
        '''Loads the data from csv file
        '''

        for f in fault_list:
            file = os.path.join(self.base_path, 'csv', '%s.csv' % f)
            df = pd.read_csv(file, index_col=0)
            df.index = pd.TimedeltaIndex(df.index, unit='s')
            self.database.append(df)
            self.database_id.append(f)

    def get_X_y_h(self, target_var, hidden_vars):
        y_list = []
        h_list = []
        X_list = []
        for df in self.database:
            y_list.append(df[target_var])
            h_list.append(df[hidden_vars])
            X_list.append(df.drop(columns=hidden_vars + [target_var]))

        return X_list, y_list, h_list

    def get_X_y_concat(self, target_var, hidden_vars): 
        X_list, y_list, _ = self.get_X_y_h(target_var, hidden_vars)
        return pd.concat(X_list, ignore_index=True), pd.concat(y_list, ignore_index=True)