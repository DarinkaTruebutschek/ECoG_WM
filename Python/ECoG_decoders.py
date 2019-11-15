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

def binaryClassif(data_train, label_train, data_test, label_test, generalization=False, proba=False, n_folds=5, predict_mode='cross-validation', scoring=None):
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

	#Scoring
	if scoring is 'auc':
		scorer = 'roc_auc'

	##########################################
	#Learning process
	if generalization:
		time_gen = GeneralizingEstimator(clf, scoring=scorer, n_jobs=-1, verbose=True)
	else:
		time_gen = SlidingEstimator(clf, scoring=scorer, n_jobs=-1, verbose=True)

	if predict_mode == 'cross-validation':
		y_pred_all = []
		test_index_all = []
		scores = []

		#Hard-code cv
		cv = StratifiedKFold(n_splits=n_folds, shuffle=True, random_state=42)
		print (cv)

		for train_index, test_index in cv.split(data_train, label_train):
			print("TRAIN:", train_index, "TEST:", test_index)

			X_train, X_test = data_train[train_index], data_test[test_index]
			y_train, y_test = label_train[train_index], label_test[test_index]

			#Train on X_train, y_train
			time_gen.fit(X_train, y_train)

			#Test on X_test
			y_pred = time_gen.predict_proba(X_test)
			print(np.shape(y_pred))

			#Concatenate all predictions and test indices to be able to later on compute accuracy for multiple labels
			y_pred_all.append(y_pred)
			test_index_all.append(test_index)

			#Score 
			if scoring is not None:
				score_fold = time_gen.score(X_test, y_test)
				scores.append(score_fold)

		if scoring is not None:
			scores = np.asarray(scores)
			scores = np.mean(scores, axis=0)

	elif predict_mode == 'mean-prediction':
		time_gen.fit(X_train, y_train)
		y_pred_all = time_gen.predict(X_test)

	return time_gen, y_pred_all, test_index_all, scores



