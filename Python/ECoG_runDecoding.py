#Purpose: This function runs the decoding analysis.
#Project: ECoG
#Author: Darinka Truebutschek
#Date: 14 October 2019

##########################################
#Load common libraries
import numpy as np

#Load specific variables and functions
from ECoG_decod_cfg import *
from ECoG_prepDec import ECoG_prepDec
from ECoG_decoders import binaryClassif

##########################################
#Define important variables
#ListSubjects = ['EG_I', 'HL', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP']
#ListFreqs = [[8, 12], [13, 30], [31, 70], [71, 160]]
#ListFilenames = ['alpha', 'beta', 'lowGamma', 'highGamma']

ListSubjects = ['EG_I']
ListFreqs = [[8, 12]]
ListFilenames = ['alpha']

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

		for labeli, _ in enumerate(range(np.shape(y_train)[1])):
			print('Running decoding on label ', labeli)

			model, predictions, cv_test = binaryClassif(X_train, y_train[:, labeli], X_test, y_test[:, labeli], generalization=generalization, proba=proba, n_folds=n_folds, predict_mode=predict_mode)

			time_gen.append(model)
			y_pred.append(predictions)
			test_index.append(cv_test)

