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

#def ECoG_prepDec(decCond, subject, foi, toi_i):
def ECoG_prepDec(decCond, subject, foi):

	##########################################
	#Load data (X)
	fname = data_path + subject + '/' +  subject + '_' + fmethod + '.mat'
	if (fmethod is 'tfa_wavelet') | (fmethod is 'respLocked_tfa_wavelet') | (fmethod is 'tfa_wavelet_final'):
		data = ECoG_fldtrp2mne(fname, 'freq', 'tfa') #for tfa data, this is a 4d-matrix of size n_trials, n_channels, n_freqs, n_times

		if foi is not 'all':
			#Preprocess data: Extract specific frequencies, apply baseline correction, and then average over those frequencies
			_, foi_1 = find_nearest(data.freqs, foi[0])
			_, foi_2 = find_nearest(data.freqs, foi[1])

			data.crop(tmin=trainTime[0], tmax=trainTime[1], fmin=foi_1, fmax=foi_2)
		else:
			_, foi_1 = find_nearest(data.freqs, 8)
			_, foi_2 = find_nearest(data.freqs, 180)
			data.crop(tmin=trainTime[0], tmax=trainTime[1], fmin=foi_1, fmax=foi_2)

		if blc:
			data.apply_baseline(baseline=bl, mode='zscore', verbose=True)

		if foi is not 'all':
			data.data = np.mean(data.data, axis=2)
	elif (fmethod is 'erp') | (fmethod is 'erp_100'):
		data = ECoG_fldtrp2mne(fname, 'data', 'erp') #for erp data, this is a 3d-matrix of sixe n_trials, n_channels, n_freqs, n_times

		#Preprocess data: Apply baseline correction 
		if blc:
			data.apply_baseline(baseline=bl, verbose=True)
	elif (fmethod is 'respLocked_erp_100'):
		data = ECoG_fldtrp2mne(fname, 'data_respLocked', 'erp') #for erp data, this is a 3d-matrix of sixe n_trials, n_channels, n_freqs, n_times
		data.crop(tmin=trainTime[0], tmax=trainTime[1])
	elif (fmethod is 'probeLocked_erp_100') | (fmethod is 'probeLocked_erp_100_longEpoch'):
		data = ECoG_fldtrp2mne(fname, 'data_probeLocked', 'erp')
		data.crop(tmin=trainTime[0], tmax=trainTime[1])

		#Preprocess data: Apply baseline correction 
		if blc:
			data.apply_baseline(baseline=bl, verbose=True)

	##########################################
	#Load labels (y)
	if fmethod is not 'probeLocked_erp_100_longEpoch':
		fname = behavior_path + subject + '_memory_behavior_forPython_final.mat'
	else:
		fname = behavior_path + subject + '_memory_behavior_forPython_Probe_final.mat'

	trialInfo = loadtablefrommat(fname, 'table_struct', 'table_columns')

	#Select only that subset of data also used in the ECoG analyses
	if fmethod is 'probeLocked_erp_100_longEpoch':
		trialInfo = trialInfo[trialInfo.trials_included_probe != 0]
	else:
		trialInfo = trialInfo[trialInfo.EEG_included != 0]

	#Sanity check: Do X and y have the same dimensions?
	if (fmethod is 'tfa_wavelet') | (fmethod is 'tfa_wavelet_final'):
		if np.shape(data.data)[0] != np.shape(trialInfo)[0]:
			print('X and y do not have the same dimensions')
	elif (fmethod is 'erp') | (fmethod is 'erp_100') | (fmethod is 'respLocked_erp_100') | (fmethod is 'probeLocked_erp_100') | (fmethod is 'probeLocked_erp_100_longEpoch'):
		if np.shape(data.get_data())[0] != np.shape(trialInfo)[0]:
			print('X and y do not have the same dimensions')

	##########################################
	#Prepare X and y specifically
	if (fmethod is 'tfa_wavelet') | (fmethod is 'respLocked_tfa_wavelet') | (fmethod is 'tfa_wavelet_final'):
		if win_size is not False:
			X_train_tmp = data.data
		else:
			X_train = data.data
	elif (fmethod is 'erp') | (fmethod is 'erp_100') | (fmethod is 'respLocked_erp_100') | (fmethod is 'probeLocked_erp_100') | (fmethod is 'probeLocked_erp_100_longEpoch'):
		if win_size is not False:
			X_train_tmp = data.get_data() #n_trials x n_channels x n_timepoints (decoding done seperately on each time point)
		else:
			X_train = data.get_data()

	#If temporal, and not spatial (default) pattern is to be decoded,
	#extract the appropriate channels of interest, time window of interest,
	#and reformat the data (aka: n_channels x n_trials x n_timebins of size n_timepoints)
	if (win_size is not False):
		if (np.shape(win_size)[0] == 1):

			#Determine how many time points will be included as features given the requested window size
			step_size_sample = np.round(data.info['sfreq'])*step_size #step size expressed in n_samples
			win_size_sample = np.round(data.info['sfreq'])*win_size #window size expressed in n_samples

			if np.round(np.mod(.2, win_size)) != 0: #first time bin should automatically correspond to the baseline period, with the first real time bin starting at cue onset (for stim-locked analyses) & to the first sample for resp_locked analyses
				first_onset = find_nearest(data.times, bl[0])[0]
				timebins_onset = np.arange(find_nearest(data.times, bl[1])[0], np.shape(data.times)[0], step_size_sample)
				timebins_onset = np.hstack((first_onset, timebins_onset))
			else:
				if fmethod != 'respLocked_erp_100':
					timebins_onset = np.arange(find_nearest(data.times, bl[0])[0], np.shape(data.times)[0], step_size_sample) #vector corresponding to the onset times of the timebins (in samples)
				else:
					timebins_onset = np.arange(find_nearest(data.times, np.min(data.times))[0], np.shape(data.times)[0], step_size_sample)

			#Display which times will actually be trained on
			print(data.times[timebins_onset.astype(int)])

			X_train = np.zeros((np.shape(X_train_tmp)[1], np.shape(X_train_tmp)[0], int(win_size_sample+1), np.shape(timebins_onset)[0]-1)) #initialize empty data matrix

			for toi_i, toi in enumerate(timebins_onset):
				if int(toi+win_size_sample+1) <= np.shape(data.times)[0]:
					#print(toi_i, toi)
					if (fmethod != 'respLocked_erp_100') & (np.mod(.2, win_size) != 0) & (toi_i == 0):
						slices = np.full((np.shape(X_train_tmp)[0], np.shape(X_train_tmp)[1], int(win_size_sample+1)), np.nan)
						slices[:, :, toi_i : int(np.diff((timebins_onset[0], timebins_onset[1]))+1)] = X_train_tmp[:, :, int(toi) : int(timebins_onset[1])+1] #first time bin encompasses baseline period
					else:
						slices = X_train_tmp[:, :, int(toi) : int(toi+win_size_sample+1)] #remember that the last sample will be exluded, so we add 1
					slices = np.transpose(slices, (1, 0, 2)) #n_channels x n_trials x n_timepoints
					X_train[:, :, :, toi_i] = slices

			del X_train_tmp
		elif np.shape(win_size)[0] > 1:
			if (fmethod is 'erp') | (fmethod is 'erp_100') | (fmethod is 'respLocked_erp_100'):
				timebins_onset = find_nearest(data.times, win_size[toi_i][0])[0] 
				win_size_sample = np.round(data.info['sfreq'])*(np.abs(win_size[toi_i][1]-win_size[toi_i][0]))

				#Display which times will actually be trained on
				#print(data.times[timebins_onset.astype(int)])

				slices = X_train_tmp[:, :, int(timebins_onset) : int(timebins_onset+win_size_sample+1)]
				slices = np.transpose(slices, (1, 0, 2)) #n_channels x n_trials x n_timepoints
				X_train = slices

				del X_train_tmp
			else: #for tfa data
				timebins_onset = find_nearest(data.times, win_size[toi_i][0])[0] 
				timebins_offset = find_nearest(data.times, win_size[toi_i][1])[0]
				win_size_sample = timebins_offset - timebins_onset

				#Display which times will actually be trained on
				#print(data.times[timebins_onset.astype(int)])

				slices = X_train_tmp[:, :, :, int(timebins_onset) : int(timebins_onset+win_size_sample+1)] #trials x channels x frequencies x timepoints
				slices = np.transpose(slices, (1, 0, 3, 2)) #n_channels x n_trials x n_timepoints x n_frequencies
				X_train = slices

		#Take relative baseline if need be (i.e., subtract the mean within each time bin seperately for each trial and channel)
		if rel_blc & (np.shape(win_size)[0] == 1):
			if fmethod != 'respLocked_erp_100':
				my_mean = np.mean(X_train, axis=2)

				for t, timepoint in enumerate(np.arange(np.shape(X_train)[2])):
					X_train[:, :, t, :] = X_train[:, :, t, :] - my_mean
			else:
				my_mean = np.mean(X_train, axis=2)

				for t, timepoint in enumerate(np.arange(np.shape(X_train)[2])):
					X_train[:, :, t, :] = X_train[:, :, t, :] - my_mean
		elif rel_blc & (np.shape(win_size)[0] > 1):
			if (fmethod is 'erp') | (fmethod is 'erp_100') | (fmethod is 'respLocked_erp_100'):
				my_mean = np.mean(X_train, axis=2)

				for t, timepoint in enumerate(np.arange(np.shape(X_train)[2])):
					X_train[:, :, t] = X_train[:, :, t] - my_mean
			else:
				my_mean = np.mean(X_train, axis=2)

				for t, timepoint in enumerate(np.arange(np.shape(X_train)[2])):
					X_train[:, :, t, :] = X_train[:, :, t, :] - my_mean

	if (decCond is 'indItems') | (decCond is 'indItems_trainCue0_testCue0') | (decCond is 'indItems_trainCue1_testCue1'):
		y_train = []
		for _, row_i in enumerate(range(len(trialInfo))):
			tmp = trialInfo.values[row_i, 7:11]
			tmp = tmp[~np.isnan(tmp)]
			y_train.append(tmp)

		del tmp	

		y_train = MultiLabelBinarizer().fit_transform(y_train)
	elif (decCond is 'indItems_trainCue0_testCue1') | (decCond is 'indItems_trainCue1_testCue0'):
		y_train = []
		y_test = []
		for _, row_i in enumerate(range(len(trialInfo))):
			tmp = trialInfo.values[row_i, 7:11]
			tmp = tmp[~np.isnan(tmp)]
			y_train.append(tmp)
			y_test.append(tmp)

		del tmp	

		y_train = MultiLabelBinarizer().fit_transform(y_train)
		y_test = MultiLabelBinarizer().fit_transform(y_test)
	elif decCond is 'itemPos':
		y_train = []
		for _, row_i in enumerate(range(len(trialInfo))):
			tmp = trialInfo.values[row_i, 17:21]
			tmp = tmp[~np.isnan(tmp)]
			y_train.append(tmp)

		del tmp	

		y_train = MultiLabelBinarizer().fit_transform(y_train)
	elif decCond is 'cue':
		y_train = trialInfo.values[:, 3]
	elif decCond is 'load':
		y_train = trialInfo.values[:, 6] #labels: 1, 2, & 4
		y_train[y_train == 1] = 0
		y_train[y_train == 2] = 1
		y_train[y_train == 4] = 2
	elif decCond is 'probe':
		y_train = trialInfo.values[:, 4] 
	elif decCond is 'probeID':
		y_train = trialInfo.values[:, 11]
	elif decCond is 'buttonPress':
		y_train = trialInfo.values[:, 12]
		y_train[y_train == 2] = 1 #1/2 = trigger pulled
		y_train[(y_train == 3) | (y_train == 4)] = 0 #3/4 = trigger not pulled

	#Select only those trials, in which the subject responded correctly & throw out any additional nan entries
	if acc & (decCond is not 'indItems_trainCue0_testCue0' and decCond is not 'indItems_trainCue1_testCue1' and decCond is not 'indItems_trainCue0_testCue1' and decCond is not 'indItems_trainCue1_testCue0'):
		sel = np.where((((~np.isnan(trialInfo.block_id)) & (trialInfo.resp == 1)) | ((~np.isnan(trialInfo.block_id)) & (trialInfo.resp == 3))))
	elif acc & (decCond is 'indItems_trainCue0_testCue0'):
		sel = np.where((((~np.isnan(trialInfo.block_id)) & (trialInfo.resp == 1) & (trialInfo.cue == 0)) | ((~np.isnan(trialInfo.block_id)) & (trialInfo.resp == 3) & (trialInfo.cue == 0))))
	elif acc & (decCond is 'indItems_trainCue1_testCue1'):
		sel = np.where((((~np.isnan(trialInfo.block_id)) & (trialInfo.resp == 1) & (trialInfo.cue == 1)) | ((~np.isnan(trialInfo.block_id)) & (trialInfo.resp == 3) & (trialInfo.cue == 1))))
	elif acc & (decCond is 'indItems_trainCue0_testCue1'):
		sel_train = np.where((((~np.isnan(trialInfo.block_id)) & (trialInfo.resp == 1) & (trialInfo.cue == 0)) | ((~np.isnan(trialInfo.block_id)) & (trialInfo.resp == 3) & (trialInfo.cue == 0))))
		sel_test = np.where((((~np.isnan(trialInfo.block_id)) & (trialInfo.resp == 1) & (trialInfo.cue == 1)) | ((~np.isnan(trialInfo.block_id)) & (trialInfo.resp == 3) & (trialInfo.cue == 1))))	
	elif acc & (decCond is 'indItems_trainCue1_testCue0'):
		sel_train = np.where((((~np.isnan(trialInfo.block_id)) & (trialInfo.resp == 1) & (trialInfo.cue == 1)) | ((~np.isnan(trialInfo.block_id)) & (trialInfo.resp == 3) & (trialInfo.cue == 1))))
		sel_test = np.where((((~np.isnan(trialInfo.block_id)) & (trialInfo.resp == 1) & (trialInfo.cue == 0)) | ((~np.isnan(trialInfo.block_id)) & (trialInfo.resp == 3) & (trialInfo.cue == 0))))	
	else:
		sel = np.where(~np.isnan(trialInfo.block_id))

	if (win_size is not False):
		if (np.shape(win_size)[0] == 1):
			X_train = X_train[:, np.squeeze(sel), :, :]
			X_train = np.squeeze(X_train)
			y_train = y_train[np.squeeze(sel)]
			#y_train = np.squeeze(y_train[np.squeeze(sel), :])
		elif (np.shape(win_size)[0] > 1):
			X_train = X_train[:, np.squeeze(sel), :]
			X_train = np.squeeze(X_train)
			y_train = y_train[np.squeeze(sel)]
	elif (win_size is False) and (decCond is not 'indItems_trainCue0_testCue1') and (decCond is not 'indItems_trainCue1_testCue0'):
		X_train = X_train[sel]
		y_train = np.squeeze(y_train)[sel]
	elif (win_size is False) and (decCond is 'indItems_trainCue0_testCue1'):
		X_test = np.copy(X_train)

		X_train = X_train[sel_train]
		y_train = np.squeeze(y_train)[sel_train]

		X_test = X_test[sel_test]
		y_test = np.squeeze(y_test)[sel_test]
	elif (win_size is False) and (decCond is 'indItems_trainCue1_testCue0'):
		X_test = np.copy(X_train)

		X_train = X_train[sel_train]
		y_train = np.squeeze(y_train)[sel_train]

		X_test = X_test[sel_test]
		y_test = np.squeeze(y_test)[sel_test]

	#Define train and test sets
	if (predict_mode == 'cross-validation') and (decCond is not 'indItems_trainCue0_testCue1') and (decCond is not 'indItems_trainCue1_testCue0'):
		X_test = np.copy(X_train)
		y_test = np.copy(y_train)

	print('Training on:', np.shape(X_train), np.shape(y_train))
	print('Testing on:', np.shape(X_test), np.shape(y_test))
	
	return X_train, y_train, X_test, y_test, data.times

	#return X_train, y_train, X_test, y_test, data.times, data.info['ch_names'], timebins_onset 
