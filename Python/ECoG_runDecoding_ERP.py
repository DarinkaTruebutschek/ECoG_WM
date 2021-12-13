#Purpose: This function runs the decoding analysis in erps.
#Project: ECoG
#Author: D.T.
#Date: 13 January 2020

##########################################
#Load common libraries
import numpy as np
import sys
import os

#Load specific variables and functions
from ECoG_decod_cfg import *
from ECoG_prepDec import ECoG_prepDec
from ECoG_decoders import binaryClassif

##########################################
#Define important variables
ListSubjects = ['EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP']
#ListSubjects = ['EG_I']
#ListSubjects = ['HS', 'KJ_I', 'LJ', 'MG', 'WS', 'KR', 'AP', 'AS']

#ListSubjects = ['EG_I', 'HS', 'KJ_I', 'LJ', 'MG']
#ListFreqs = [[8, 12], [13, 30], [31, 70], [71, 160]]
ListFilenames = ['erp_100']

if generalization:
	gen_filename = 'timeGen'
else:
	gen_filename = 'diag'

if 'load1' in decCond:
	ListSubjects = ['EG_I', 'KJ_I', 'MG', 'WS', 'AP']
##########################################
#Loop over subjects and frequencies
for subi, subject in enumerate(ListSubjects):
	
	print('Decoding subject ', subject)
	
	#Prep data for decoding
	X_train, y_train, X_test, y_test, time = ECoG_prepDec(decCond, subject, 'all')

	#Check whether the train & test set are equal
	if np.shape(y_train)[0] < np.shape(y_test)[0]:
		minTrial = []
		minTrial.append(np.shape(y_train)[0])

		#Randomly select a subset of trials in the larger sample
		tmp = np.random.choice(np.arange(np.shape(y_test)[0]), np.shape(y_train)[0], replace=False)
		tmp = np.sort(tmp)

		X_test = X_test[tmp]
		y_test = y_test[tmp]
	elif np.shape(y_test)[0] < np.shape(y_train)[0]:
		minTrial = []
		minTrial.append(np.shape(y_test)[0])

		#Randomly select a subset of trials in the larger sample
		tmp = np.random.choice(np.arange(np.shape(y_train)[0]), np.shape(y_test)[0], replace=False)
		tmp = np.sort(tmp)

		X_train = X_train[tmp]
		y_train = y_train[tmp]
	elif (decCond is 'indItems_trainCue0_testCue0') | (decCond is 'indItems_trainCue1_testCue1'):
		minTrials = np.load(result_path + ListFilenames[0] + '/'  + subject + '_BroadbandERP_indItems_trainCue0_testCue1_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_minTrials.npy')

		if np.shape(y_train)[0] > minTrials[0]:
		
			#Randomly select a subset of trials in both samples
			tmp = np.random.choice(np.arange(np.shape(y_train)[0]), minTrials, replace=False)
			tmp = np.sort(tmp)

			X_train = X_train[tmp]
			y_train = y_train[tmp]
			X_test = X_test[tmp]
			y_test = y_test[tmp]
	elif (decCond is 'indItems_load1_trainCue0_testCue0') | (decCond is 'indItems_load1_trainCue1_testCue1'):
		minTrials = np.load(result_path + ListFilenames[0] + '/'  + subject + '_BroadbandERP_indItems_load1_trainCue0_testCue1_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_minTrials.npy')

		if np.shape(y_train)[0] > minTrials[0]:
		
			#Randomly select a subset of trials in both samples
			tmp = np.random.choice(np.arange(np.shape(y_train)[0]), minTrials, replace=False)
			tmp = np.sort(tmp)

			X_train = X_train[tmp]
			y_train = y_train[tmp]
			X_test = X_test[tmp]
			y_test = y_test[tmp]

	if np.shape(X_train) != np.shape(X_test):
		exit()

	#Run decoding
	time_gen = []
	y_pred = []
	test_index = []
	score = []

	if (decCond is 'indItems') | (decCond is 'itemPos') | (decCond is 'indItems_trainCue0_testCue0') | (decCond is 'indItems_trainCue1_testCue1') | (decCond is 'indItems_trainCue0_testCue1') | (decCond is 'indItems_trainCue1_testCue0') | (decCond is 'indItems_load1') | (decCond  is  'itemPos_load1') | (decCond is 'indItems_load1_trainCue1_testCue0') | (decCond is 'indItems_load1_trainCue0_testCue1') | (decCond is 'indItems_load1_trainCue1_testCue1') | (decCond is 'indItems_load1_trainCue0_testCue0'):	
		for labeli, _ in enumerate(range(np.shape(y_train)[1])):
			print('Running decoding on label ', labeli)
			print(np.sum(y_train[:, labeli]))
			print(np.sum(y_test[:, labeli]))

			model, predictions, cv_test, score_label = binaryClassif(X_train, y_train[:, labeli], X_test, y_test[:, labeli], generalization=generalization, proba=proba, n_folds=n_folds, predict_mode=predict_mode, scoring=score_method)
			
			time_gen.append(model) #shape:n_labels
			y_pred.append(predictions) #shape: n_labels x n_folds, within each label: n_folds x n_testTrials x n_TestTime x n_labels
			test_index.append(cv_test) #shape: n_labels x n_folds
			score.append(score_label)
	else:	
		model, predictions, cv_test, score_label = binaryClassif(X_train, y_train, X_test, y_test, generalization=generalization, proba=proba, n_folds=n_folds, predict_mode=predict_mode, scoring=score_method)
		
		time_gen.append(model) #shape:n_labels
		y_pred.append(predictions) #shape: n_labels x n_folds, within each label: n_folds x n_testTrials x n_TestTime x n_labels
		test_index.append(cv_test) #shape: n_labels x n_folds
		score.append(score_label)

	#Compute average score for all labels
	score = np.asarray(score)
	if (decCond is 'indItems') | (decCond is 'itemPos') | (decCond is 'indItems_trainCue0_testCue0') | (decCond is 'indItems_trainCue1_testCue1') | (decCond is 'indItems_trainCue1_testCue0') | (decCond is 'indItems_load1') | (decCond is 'itemPos_load1') | (decCond is 'indItems_load1_trainCue1_testCue0') | (decCond is 'indItems_load1_trainCue0_testCue1') | (decCond is 'indItems_load1_trainCue1_testCue1') | (decCond is 'indItems_load1_trainCue0_testCue0'):
	#if score.ndim > 2:
		average_score = np.mean(score, axis=0)

	#Save all data
	if os.path.isdir(result_path + ListFilenames[0]) is False:
		os.makedirs(result_path + ListFilenames[0])

	np.save(result_path + ListFilenames[0] + '/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_time.npy', time, allow_pickle=True)
	np.save(result_path + ListFilenames[0] + '/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_time_gen.npy', time_gen, allow_pickle=True)
	np.save(result_path + ListFilenames[0] + '/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_y_pred.npy', y_pred, allow_pickle=True)
	np.save(result_path + ListFilenames[0] + '/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_test_index.npy', test_index, allow_pickle=True)
	np.save(result_path + ListFilenames[0] + '/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_score.npy', score, allow_pickle=True)

	if (decCond is 'indItems') | (decCond is 'itemPos') | (decCond is 'indItems_trainCue0_testCue0') | (decCond is 'indItems_trainCue1_testCue1') | (decCond is 'indItems_trainCue1_testCue0') | (decCond is 'indItems_load1') | (decCond is  'itemPos_load1') | (decCond is 'indItems_load1_trainCue1_testCue0') | (decCond is 'indItems_load1_trainCue0_testCue1') | (decCond is 'indItems_load1_trainCue1_testCue1') | (decCond is 'indItems_load1_trainCue0_testCue0'):
	#if score.ndim > 2:
		np.save(result_path + ListFilenames[0] + '/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_average_score.npy', average_score, allow_pickle=True)

	if (decCond is 'indItems_trainCue1_testCue0') | (decCond is 'indItems_trainCue0_testCue1') | (decCond is 'indItems_load1_trainCue1_testCue0') | (decCond is 'indItems_load1_trainCue0_testCue1'):
		np.asarray(minTrial)
		np.save(result_path + ListFilenames[0] + '/'  + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_minTrials.npy', minTrial, allow_pickle=True)

