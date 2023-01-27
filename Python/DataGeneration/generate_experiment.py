# -*- coding: utf-8 -*-
"""
Created on Tue May 10 14:53:53 2022

@author: MV242848
"""
import random
import numpy as np
import pandas as pd

SIM_LENGTH = 24*7*4
#SIM_LENGTH = 12

#-------------------------------------------------------------------------------
def generate_random_fault(prefix):
   liste_type = [2, 1] #['step', 'ramp']
   type_defaut = random.choice(liste_type)

   time_range = [i for i in range(SIM_LENGTH)] # max value is SIM_LENGTH - 1

   # On pioche dans tous les pas de temps suivant une proba geometrique calcule. proba p à modifier peut-être
   # proba_geometrique = stats.geom.pmf(time_range, 0.01)
   # proba_geometrique /= np.sum(proba_geometrique)
   # start = np.random.choice(time_range, size=1, replace = True, p=proba_geometrique)[0]
   
   #On pioche un temps de debut de defaut selon une loi uniforme
   start = np.random.choice(time_range)
   
   #Suivre une loi normale de parametre mu, sigma
   mu, sigma = 0, 0.3
   # a, b = (0 - mu) / sigma, (1 - mu) / sigma
   valeur_finale = 2
   while valeur_finale > 1:
       valeur_finale = abs(np.random.normal(mu, sigma))
       
   #Valeur du defaut suivant une loi uniforme (compris entre 0 ou 1)
   # valeur_finale = random.random()
   
   dico = {prefix+'type': type_defaut, 
           prefix+'start': round(start, 1), 
           prefix+'stop': SIM_LENGTH,
           prefix+'init': 0, 
           prefix+'final': round(valeur_finale, 2)}
   
   return dico
#-------------------------------------------------------------------------------
def get_sim_id(bc, sim_type, sim_nb):
    return 'bc%02d-s%d-%03d' % (bc, sim_type, sim_nb) 
#-------------------------------------------------------------------------------
def generate_experiment(n_faults, sim_prefix, fault_prefix):
    keys = [fault_prefix + s for s in ['type', 'start', 'stop', 'init', 'final']]
    default_value = dict(zip(keys, [0]*len(keys)))

    fault_list = []

    for bc in range(0,13):
                
        # Simulation without faults
        fault = default_value.copy()
        fault['bc'] = bc
        fault['id'] = sim_prefix+get_sim_id(bc, 0, 0)
        fault_list.append(fault)

        # Simulation without faults on the COP
        for i in range(n_faults):
            fault = generate_random_fault(fault_prefix)
            fault['bc'] = bc
            fault['id'] = sim_prefix+get_sim_id(bc, 1, i)
            fault_list.append(fault)
    df = pd.DataFrame(fault_list)
    df.to_csv('metadata.csv', sep=";", index=False, columns=['id','bc']+keys)
#-------------------------------------------------------------------------------

if __name__ == '__main__':
    generate_experiment(100, sim_prefix='HeatPump-', fault_prefix='COP_f_')