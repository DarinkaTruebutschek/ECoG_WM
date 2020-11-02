#Purpose: This function runs the decoding analysis.
#Project: ECoG
#Author: D.T.
#Date: 14 October 2019

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
ListFreqs = [[8, 12], [13, 30], [30, 70], [70, 180]]
ListFilenames = ['alpha_final', 'beta_final', 'lowGamma_final', 'highGamma_final']

if generalization:
	gen_filename = 'timeGen'
else:
	gen_filename = 'diag'

##########################################
#Loop over subjects and frequencies
for subi, subject in enumerate(ListSubjects):
	for freqi, freq in enumerate(ListFreqs):
		print('Decoding ', subject, 'in frequency band: ', freq)

		#Prep data for decoding
		X_train, y_train, X_test, y_test, time = ECoG_prepDec(decCond, subject, freq)

		#Run decoding
		time_gen = []
		y_pred = []
		test_index = []
		score = []

		if decCond is 'indItems':
			for labeli, _ in enumerate(range(np.shape(y_train)[1])):
				print('Running decoding on label ', labeli)

				model, predictions, cv_test, score_label = binaryClassif(X_train, y_train[:, labeli], X_test, y_test[:, labeli], generalization=generalization, proba=proba, n_folds=n_folds, predict_mode=predict_mode, scoring=score_method)
				
				time_gen.append(model) #shape:n_labels
				y_pred.append(predictions) #shape: n_labels x n_folds, within each label: n_folds x n_testTrials x n_TestTime x n_labels
				test_index.append(cv_test) #shape: n_labels x n_folds
				score.append(score_label)		
		else:
			model, predictions, cv_test, score_label = binaryClassif(X_train, y_train, X_test, y_test, generalization=generalization, proba=proba, n_folds=n_folds, predict_mode=predict_mode, scoring=score_method)

		time_gen.append(model)
		y_pred.append(predictions) #shape: n_labels x n_folds, within each label: n_folds x n_testTrials x n_trainTime x n_TestTime x n_labels
		test_index.append(cv_test) #shape: n_labels x n_folds
		score.append(score_label)

		#Compute average score for all labels
		score = np.asarray(score)
		if decCond is 'indItems':
			average_score = np.mean(score, axis=0)

		#Save all data
		if os.path.isdir(result_path + ListFilenames[freqi]) is False:
			os.makedirs(result_path + ListFilenames[freqi])

		np.save(result_path + ListFilenames[freqi] + '/' + subject + '_WavDec_' + decCond + '_' + gen_filename + '_' + ListFilenames[freqi] + '_acc' + str(acc) + '_time.npy', time, allow_pickle=True)
		np.save(result_path + ListFilenames[freqi] + '/' + subject + '_WavDec_' + decCond + '_' + gen_filename + '_' + ListFilenames[freqi] + '_acc' + str(acc) + '_time_gen.npy', time_gen, allow_pickle=True)
		np.save(result_path + ListFilenames[freqi] + '/' + subject + '_WavDec_' + decCond + '_' + gen_filename + '_' + ListFilenames[freqi] + '_acc' + str(acc) + '_y_pred.npy', y_pred, allow_pickle=True)
		np.save(result_path + ListFilenames[freqi] + '/' + subject + '_WavDec_' + decCond + '_' + gen_filename + '_' + ListFilenames[freqi] + '_acc' + str(acc) + '_test_index.npy', test_index, allow_pickle=True)
		np.save(result_path + ListFilenames[freqi] + '/' + subject + '_WavDec_' + decCond + '_' + gen_filename + '_' + ListFilenames[freqi] + '_acc' + str(acc) + '_score.npy', score, allow_pickle=True)

		if decCond is 'indItems':
			np.save(result_path + ListFilenames[freqi] + '/' + subject + '_WavDec_' + decCond + '_' + gen_filename + '_' + ListFilenames[freqi] + '_acc' + str(acc) + '_average_score.npy', average_score, allow_pickle=True)



