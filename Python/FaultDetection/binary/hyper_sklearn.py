#!/usr/bin/env python
# coding: utf-8

import os
FILE_BASE = os.path.dirname(os.path.abspath(__file__)) 

import sys
sys.path.append(os.path.join( FILE_BASE, '..'))

import logging
logging.basicConfig(format='%(asctime)s %(levelname)s:%(message)s', 
                     level=logging.INFO, datefmt='%Y-%m-%d %H:%M:%S')

from sklearn.metrics import matthews_corrcoef

from hpsklearn import HyperoptEstimator
from hpsklearn import any_preprocessing
from hyperopt import tpe

from utils import load_data

#-------------------------------------------------------------------------------
def loss_fn(y_target, y_pred):
   return 0.5 - matthews_corrcoef(y_target, y_pred)/2 

#-------------------------------------------------------------------------------
def evaluate_model(classifier, dump_file, X_train, y_train, X_test, y_test):
   # define search
   model = HyperoptEstimator(classifier=classifier, 
                              preprocessing=any_preprocessing('pre'),
                              loss_fn=loss_fn, 
                              algo=tpe.suggest,
                              max_evals=20,
                              fit_increment=1,
                              fit_increment_dump_filename=dump_file, 
                              trial_timeout=3000, n_jobs=20)

   # perform the search
   model.fit(X_train, y_train, cv_shuffle=True)

   # summarize performance
   y_pred = model.predict(X_test)
   mcc = matthews_corrcoef(y_test,	y_pred)
   print("MCC: %.3f" % mcc)

   acc = model.score(X_test, y_test)
   print("Accuracy: %.3f" % acc)

   # summarize the best model
   print(model.best_model())

#-------------------------------------------------------------------------------
if __name__ == '__main__':
   from argparse import ArgumentParser

   parser = ArgumentParser()
   parser.add_argument("-m", "--models", nargs='+', 
                     help="models to evaluate", metavar="MODEL")
   parser.add_argument("train_file", help="pickle file with train data", metavar="TRAIN FILE")               
   parser.add_argument("test_file", help="pickle file with test data", metavar="TEST FILE")  
   args = parser.parse_args()

   X_train, y_train = load_data(args.train_file)
   X_test, y_test = load_data(args.test_file)

   if args.models is None:
      sys.exit()

   for model in args.models:
      if(model == 'lr'):
         from hpsklearn import logistic_regression
         evaluate_model(logistic_regression('lr', l1_ratio=0.5), 'hp_lr.pickle', 
                        X_train, y_train, X_test, y_test)

      elif(model == 'knn'):
         from hpsklearn import k_neighbors_classifier
         evaluate_model(k_neighbors_classifier('knn'), 'hp_knn.pickle', 
                         X_train, y_train, X_test, y_test)

      elif(model == 'rf'):
         from hpsklearn import random_forest_classifier
         evaluate_model(random_forest_classifier('rf'), 'hp_rf.pickle', 
                        X_train, y_train, X_test, y_test)

      elif(model == 'xgb'):
         from hpsklearn import xgboost_classification
         evaluate_model(xgboost_classification('xgb'), 'hp_xgb.pickle', 
                        X_train, y_train, X_test, y_test)

      elif(model == 'svc'):
         from hpsklearn import linear_svc
         evaluate_model(linear_svc('svc'), 'hp_svc.pickle',
                        X_train, y_train, X_test, y_test)

# from sklearn.tree import DecisionTreeClassifier
# from sklearn.neural_network import MLPClassifier
      else:
         logging.warning('Invalid model '+ model)

      
