#Purpose: This function prepares the ECoG data for decoding.
#Project: ECoG
#Author: Darinka Truebutschek
#Date: 14 October 2019

##########################################
#Load common libraries
import base
import numpy as np

from sklearn.preprocessing import MultiLabelBinarizer

#Load specific variables and functions
from base import find_nearest, loadtablefrommat

from ECoG_decod_cfg import *
from ECoG_fldtrp2mne import ECoG_fldtrp2mne

def ECoG_prepDec(decCond, subject, foi):

	##########################################
	#Load data (X)
	fname = data_path + subject + '/' +  subject + '_' + fmethod + '.mat'
	if fmethod is 'tfa_wavelet':
		data = ECoG_fldtrp2mne(fname, 'freq', 'tfa') #for tfa data, this is a 4d-matrix of size n_trials, n_channels, n_freqs, n_times
	elif fmethod is 'broadband_erp':
		data = ECoG_fldtrp2mne(fname, 'data', 'erp') #for erp data, this is a 3d-matrix of sixe n_trials, n_channels, n_freqs, n_times

	#Preprocess data: Extract specific frequencies, apply baseline correction, and then average over those frequencies
	_, foi_1 = find_nearest(data.freqs, foi[0])
	_, foi_2 = find_nearest(data.freqs, foi[1])

	data.crop(tmin=bl[0], tmax=trainTime[1], fmin=foi_1, fmax=foi_2)

	if blc:
		data.apply_baseline(baseline=bl, mode='zscore', verbose=True)

	data.data = np.mean(data.data, axis=2)

	##########################################
	#Load labels (y)
	fname = behavior_path + subject + '_memory_behavior_forPython.mat'
	trialInfo = loadtablefrommat(fname, 'table_struct', 'table_columns')

	#Select only that subset of data also used in the ECoG analyses
	trialInfo = trialInfo[trialInfo.EEG_included != 0]

	#Sanity check: Do X and y have the same dimensions?
	if np.shape(data.data)[0] != np.shape(trialInfo)[0]:
		print('X and y do not have the same dimensions')

	##########################################
	#Prepare X and y specifically
	X_train = data.data

	if decCond is 'indItems':
		y_train = []
		for _, row_i in enumerate(range(len(trialInfo))):
			tmp = trialInfo.values[row_i, 7:11]
			tmp = tmp[~np.isnan(tmp)]
			y_train.append(tmp)

		del tmp	

		y_train = MultiLabelBinarizer().fit_transform(y_train)

	#Select only those trials, in which the subject responded correctly
	if acc:
		sel = np.where((trialInfo.resp == 1) | (trialInfo.resp == 3))

		X_train = X_train[sel]
		y_train = np.squeeze(y_train[sel, :])

	#Define train and test sets
	if predict_mode == 'cross-validation':
		X_test = np.copy(X_train)
		y_test = np.copy(y_train)

	print('Training on:', np.shape(X_train), np.shape(y_train))
	print('Testing on:', np.shape(X_test), np.shape(y_test))

	return X_train, y_train, X_test, y_test, data.times
