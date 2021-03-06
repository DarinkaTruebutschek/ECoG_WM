#Purpose: This function runs the decoding analysis in erps.
#Project: ECoG
#Author: D.T.
#Date: 13 January 2020

##########################################
#Load common libraries
import numpy as np
import os

#Load specific variables and functions
from ECoG_decod_cfg import *
from ECoG_prepDec import ECoG_prepDec
from ECoG_decoders import binaryClassif

##########################################
#Define important variables
ListSubjects = ['EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP']
#ListSubjects = ['HS']

#ListSubjects = ['EG_I', 'HS', 'KJ_I', 'LJ', 'MG']
#ListFreqs = [[8, 12], [13, 30], [31, 70], [71, 160]]
ListFilenames = ['erp_100']

if generalization:
	gen_filename = 'timeGen'
else:
	gen_filename = 'diag'

##########################################
#Loop over subjects and frequencies
for subi, subject in enumerate(ListSubjects):
	
	print('Decoding subject ', subject)
	#Prep data for decoding
	X_train, y_train, X_test, y_test, time = ECoG_prepDec(decCond, subject, 'all')

	#Run decoding
	time_gen = []
	y_pred = []
	test_index = []
	score = []

	if (decCond is 'indItems') | (decCond is 'itemPos') | (decCond is 'indItems_trainCue0_testCue0') | (decCond is 'indItems_trainCue1_testCue1') | (decCond is 'indItems_trainCue0_testCue1') | (decCond is 'indItems_trainCue1_testCue0') | (decCond is 'indItems_load1'):
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
	if (decCond is 'indItems') | (decCond is 'itemPos') | (decCond is 'indItems_trainCue0_testCue0') | (decCond is 'indItems_trainCue1_testCue1') | (decCond is 'indItems_trainCue1_testCue0') | (decCond is 'indItems_load1'):
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

	if (decCond is 'indItems') | (decCond is 'itemPos') | (decCond is 'indItems_trainCue0_testCue0') | (decCond is 'indItems_trainCue1_testCue1') | (decCond is 'indItems_trainCue1_testCue0') | (decCond is 'indItems_load1'):
	#if score.ndim > 2:
		np.save(result_path + ListFilenames[0] + '/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_average_score.npy', average_score, allow_pickle=True)



