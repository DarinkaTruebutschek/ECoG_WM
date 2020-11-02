#Purpose: This function runs the decoding analysis with time (as opposed to channels) as features.
#In other words, we will be looking at slices
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
ListFilenames = ['erp_100_TimDim_allTimeBins_meanSubtraction']

if generalization:
	gen_filename = 'timeGen'
else:
	gen_filename = 'diag'

##########################################
#Loop over subjects and frequencies
for subi, subject in enumerate(ListSubjects):

	print('Decoding subject ', subject)

	#Run decoding
	time_gen = []
	y_pred = []
	test_index = []
	score = []
	onsets = []

	score_label = []

	for toii, toi in enumerate(win_size):
		print('Decoding time bin ', toi)

		#Prep data for decoding
		X_train, y_train, X_test, y_test, time, chans, trainTimes_onsets = ECoG_prepDec(decCond, subject, 'all', toii)

		#Run classification seperately for each individual channel
		for chani, _ in enumerate(np.arange(np.shape(X_train)[0])):
			print('Decoding channel numnber ', chani)

			if (decCond is 'indItems') | (decCond is 'itemPos'):
				for labeli, _ in enumerate(range(np.shape(y_train)[1])):
					print('Running decoding on label ', labeli)

					X_train_tmp = X_train[chani, :, :]
					X_test_tmp = X_test[chani, :, :]
					model, predictions, cv_test, score_label = binaryClassif(X_train_tmp[:, :, np.newaxis], y_train[:, labeli], X_test_tmp[:, :, np.newaxis], y_test[:, labeli], generalization=generalization, proba=proba, n_folds=n_folds, predict_mode=predict_mode, scoring=score_method)

					#if (np.mod(.2, win_size) != 0): #without baseline to facilitate code
				 		#model, predictions, cv_test, score_label = binaryClassif(X_train[chani, :, :, 1:], y_train[:, labeli], X_test[chani, :, :, 1:], y_test[:, labeli], generalization=generalization, proba=proba, n_folds=n_folds, predict_mode=predict_mode, scoring=score_method)
					#else: 
						#model, predictions, cv_test, score_label = binaryClassif(X_train[chani, :, :, :], y_train[:, labeli], X_test[chani, :, :, :], y_test[:, labeli], generalization=generalization, proba=proba, n_folds=n_folds, predict_mode=predict_mode, scoring=score_method)

					time_gen.append(model) #shape: (n_channels_n_labels)
					y_pred.append(predictions) #shape: (n_channels x n_labels) x n_folds, within each label: n_folds x n_testTrials x n_testTime x n_labels
					test_index.append(cv_test) #shape: (n_channels x n_folds) x n_testTrials
					score.append(score_label) #shape: (n_channels x n_labels) x n_testTime
			else:
				if X_train.ndim == 4: #aka, there aree multiple training time windows
					model, predictions, cv_test, score_label = binaryClassif(X_train[chani, :, :, :], y_train, X_test[chani, :, :, :], y_test, generalization=generalization, proba=proba, n_folds=n_folds, predict_mode=predict_mode, scoring=score_method)
				elif X_train.ndim == 3: #aka, we are just testing on one big time bin
					X_train_tmp = X_train[chani, :, :]
					X_test_tmp = X_test[chani, :, :]
					model, predictions, cv_test, score_label = binaryClassif(X_train_tmp[:, :, np.newaxis], y_train, X_test_tmp[:, :, np.newaxis], y_test, generalization=generalization, proba=proba, n_folds=n_folds, predict_mode=predict_mode, scoring=score_method)

				time_gen.append(model) #shape: (n_channels)
				y_pred.append(predictions) #shape: (n_channels x n_folds), within each fold: n_testTrials x n_testTime x n_labels
				test_index.append(cv_test) #shape: (n_channels x n_folds) x n_testTrials
				score.append(score_label) #shape: (n_channels x n_testTime)
				onsets.append(trainTimes_onsets)

	#Reshape variables
	y_pred = np.squeeze(np.asarray(y_pred))
	test_index = np.squeeze(np.asarray(test_index))
	score = np.squeeze(np.asarray(score))

	if np.shape(win_size)[0] == 1:
		if (fmethod != 'respLocked_erp_100') & (decCond != 'indItems'):
			if (np.mod(.2, win_size) != 0): #without baseline to facilitate code
				y_pred = np.transpose(np.reshape(y_pred, (labeli+1, chani+1, n_folds)), (1, 0, 2)) #channels x labels x folds
				test_index = np.transpose(np.reshape(test_index, (labeli+1, chani+1, n_folds)), (1, 0, 2)) #channels x labels x folds
				score = np.transpose(np.reshape(score, (labeli+1, chani+1, np.shape(trainTimes_onsets)[0]-2)), (1, 0, 2)) #channels x labels x folds
			else:
				y_pred = np.transpose(np.reshape(y_pred, (labeli+1, chani+1, n_folds)), (1, 0, 2)) #channels x labels x folds
				test_index = np.transpose(np.reshape(test_index, (labeli+1, chani+1, n_folds)), (1, 0, 2)) #channels x labels x folds
				score = np.transpose(np.reshape(score, (labeli+1, chani+1, np.shape(trainTimes_onsets)[0]-1)), (1, 0, 2)) #channels x labels x folds
	else:
		if (decCond is not 'indItems') & (decCond is not 'itemPos'):
			if subject is not 'LJ': #in this subject, the test sets for each split of the cv had exactly the same number of trials, so the dimensions of y_pred and test_index were different
				y_pred  = np.reshape(y_pred, (len(win_size), len(chans), n_folds))
				test_index = np.reshape(test_index, (len(win_size), len(chans), n_folds))
				score = np.reshape(score, (len(win_size), len(chans), 1))
			else:
				score = np.reshape(score, (len(win_size), len(chans), 1))
		else:
			if subject is not 'LJ':
				#y_pred = np.reshape(y_pred, (labeli+1, len(win_size), len(chans), n_folds))
				#test_index = np.reshape(test_index, (labeli+1, len(win_size), len(chans), n_folds))
				#score = np.reshape(score, (labeli+1, len(win_size), len(chans), 1))
				y_pred = np.reshape(y_pred, (len(win_size), len(chans), labeli+1, n_folds))
				test_index = np.reshape(test_index, (len(win_size), len(chans), labeli+1, n_folds))
				score = np.reshape(score, (len(win_size), len(chans), labeli+1, 1))
			else:
				score = np.reshape(score, (len(win_size), len(chans), labeli+1, 1))

	#Compute average score for all labels
	#if (decCond is 'indItems'):
	#if score.ndim > 2:
		#average_score = np.mean(score, axis=1)
	if (decCond is 'indItems') | (decCond is 'itemPos'):
		#average_score = np.mean(score, axis=0)
		average_score = np.mean(score, axis=2)

	#Save all data
	if os.path.isdir(result_path + ListFilenames[0]) is False:
		os.makedirs(result_path + ListFilenames[0])

	np.save(result_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_time.npy', time, allow_pickle=True)
	np.save(result_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_onsetTimes.npy', trainTimes_onsets, allow_pickle=True)
	np.save(result_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_channels.npy', chans, allow_pickle=True)
	np.save(result_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_time_gen.npy', time_gen, allow_pickle=True)
	np.save(result_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_y_pred.npy', y_pred, allow_pickle=True)
	np.save(result_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_test_index.npy', test_index, allow_pickle=True)
	np.save(result_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_score.npy', score, allow_pickle=True)

	if (decCond is 'indItems') | (decCond is 'itemPos'):
	#if score.ndim > 2:
		np.save(result_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_average_score.npy', average_score, allow_pickle=True)



