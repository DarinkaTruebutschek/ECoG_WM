#Purpose: This script contains different functions to run a decoding analysis.
#Project: ECoG
#Author: D.T.
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
from sklearn.metrics import make_scorer, roc_auc_score, confusion_matrix
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
	elif scoring is 'auc_multiclass':
		scorer =  make_scorer(roc_auc_score, average='macro', multi_class='ovr')

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

		#Start with actual loop
		for train_index, test_index in cv.split(data_train, label_train):
			print("TRAIN:", train_index, "TEST:", test_index)

			X_train, X_test = data_train[train_index], data_test[test_index]
			y_train, y_test = label_train[train_index], label_test[test_index]

			#Train on X_train, y_train
			time_gen.fit(X_train, y_train)

			#Test on X_test
			y_pred = time_gen.predict_proba(X_test)
			#y_pred = np.squeeze(y_pred) #trials x labels;
			print(np.shape(y_pred))

			#Concatenate all predictions and test indices to be able to later on compute accuracy for multiple labels
			y_pred_all.append(y_pred)
			test_index_all.append(test_index)

			#Score 
			if scoring is not None:
				if scoring is 'auc':
					score_fold = time_gen.score(X_test, y_test)
				elif scoring is 'auc_multiclass': #This has to be done by hand, as it seems incompatible with the GeneralizingEstimator parallelization
					
					#In case of the channel decoding only
					score_fold = roc_auc_score(y_test, np.squeeze(y_pred), multi_class='ovr')

					#In case of the typical channel x time decoding
					#if len(np.shape(y_pred)) == 4:
						#score_fold = np.zeros((np.shape(y_pred)[1], np.shape(y_pred)[2]))

						#for train_time in np.arange(np.shape(y_pred)[1]):
							#print('Scoring train_time: ' + str(train_time))
							#for test_time in np.arange(np.shape(y_pred)[2]):
								#score_fold[train_time, test_time] = roc_auc_score(y_test, y_pred[:, train_time, test_time, :], multi_class='ovr')
					#else:
						#score_fold = np.zeros((np.shape(y_pred)[1]))

						#for train_time in np.arange(np.shape(y_pred)[1]):
							#print('Scoring train_time: ' + str(train_time))
							#score_fold[train_time] = roc_auc_score(y_test, y_pred[:, train_time, :], multi_class='ovr')


					#In case of the channel decoding for TF data
					#score_fold = np.zeros((np.shape(y_pred)[1]))

					#for freqi in np.arange(np.shape(y_pred)[1]):
						#print('Scoring frequency: ' + str(freqi))

						#score_fold[freqi] = roc_auc_score(y_test, np.squeeze(y_pred[:, freqi, :]), multi_class='ovr')


				scores.append(score_fold)

		if scoring is not None:
			scores = np.asarray(scores)
			scores = np.mean(scores, axis=0)

	elif predict_mode == 'mean-prediction':
		y_pred_all = []
		test_index_all = []
		scores = []

		'''
		#Hard-code cv
		cv = StratifiedKFold(n_splits=n_folds, shuffle=True, random_state=42)
		print (cv)

		for train_index, _ in cv.split(data_train, label_train):
			print("TRAIN:", train_index)

			X_train = data_train[train_index]
			y_train = label_train[train_index]

			_, X_test = 

			time_gen.fit(X_train, y_train)

			#Test on X_test
			y_pred = time_gen.predict_proba(X_test)
			print(np.shape(y_pred))

			#Concatenate all predictions and test indices to be able to later on compute accuracy for multiple labels
			y_pred_all.append(y_pred)
			test_index_all.append(test_index)

			#Score
			score_fold = time_gen.score(X_test, y_test)
			scores.append(score_fold)
		scores = np.mean(scores, axis=0)
		'''
		#Train on X_train, y_train
		time_gen.fit(data_train, label_train)

		#Test on X_test
		test_index = np.arange(np.shape(data_test)[0])
		y_pred = time_gen.predict_proba(data_test)
		print(np.shape(y_pred))

		#Concatenate all predictions and test indices to be able to later on compute accuracy for multiple labels
		y_pred_all.append(y_pred)
		test_index_all.append(test_index)

		#Score 
		if scoring is not None:
			if scoring is 'auc':
				scores = time_gen.score(data_test, label_test)
	
	return time_gen, y_pred_all, test_index_all, scores



