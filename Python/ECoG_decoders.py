#Purpose: This script contains different functions to run a decoding analysis.
#Project: ECoG
#Author: Darinka Truebutschek
#Date: 08 October 2019

##########################################
#Load common libraries
import numpy as np

#MNE
from mne.decoding import (SlidingEstimator, GeneralizingEstimator, cross_val_multiscore, LinearModel)

#Sklearn
from sklearn import svm
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import make_pipeline
from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import roc_auc_score
from sklearn.feature_selection import SelectKBest, f_classif

def binaryClassif(data_train, label_train, data_test, label_test, generalization=False, proba=False, n_folds=5, predict_mode='cross-validation'):
	"""
	This function performs a binary classification task.
	"""

	##########################################
	#Learning machinery 
	#Scaler to standardize features (i.e., each time point for each channel) by removing mean and scaling to unit variance
	scaler = StandardScaler()

	#Model
	model = svm.SVC(C=1, kernel='linear', class_weight='balanced', probability=proba, decision_function_shape='ovr')

	#Pipeline
	clf = make_pipeline(scaler, model)

	##########################################
	#Learning process
	time_gen = GeneralizingEstimator(clf, scoring=None, n_jobs=-1, verbose=True)

	if predict_mode == 'cross-validation':
		y_pred_all = []
		test_index_all = []

		#Hard-code cv
		cv = StratifiedKFold(n_folds)
		print (cv)

		for train_index, test_index in cv.split(data_train, label_train):
			print("TRAIN:", train_index, "TEST:", test_index)

			X_train, X_test = data_train[train_index], data_test[test_index]
			y_train, y_test = label_train[train_index], label_test[test_index]

			#Train on X_train, y_train
			time_gen.fit(X_train, y_train)

			#Test on X_test
			y_pred = time_gen.predict_proba(X_test)

			#Concatenate all predictions and test indices to be able to later on compute accuracy for multiple labels
			y_pred_all.append(y_pred)
			test_index_all.append(test_index)

		#predictions = cross_val_multiscore(time_gen, X_train, y_train, cv=cv, n_jobs=-1) #matrix of size n_folds, n_labels, n_times
	elif predict_mode == 'mean-prediction':
		time_gen.fit(X_train, y_train)
		y_pred_all = time_gen.predict(X_test)

	return time_gen, y_pred_all, test_index_all



