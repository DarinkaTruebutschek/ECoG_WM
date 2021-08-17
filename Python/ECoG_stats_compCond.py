#Purpose: This scripts computes the stats for the comparison between different conditions of decoding
#Project: ECoG
#Author: D.T.
#Date: 24 June 2021

##########################################
#Load common libraries
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
import scipy.stats as scipy

#from mpl_toolkits.axes_grid1.inset_locator import inset_axes
from svglib.svglib import svg2rlg
from reportlab.graphics import renderPDF

#Load specific variables and functions
from base import findTimeClust, find_nearest, my_smooth
from ECoG_finalFigs_cfg import *
from ECoG_base_plot import pretty_plot, pretty_colorbar
from ECoG_base_plotDecoding import pretty_decod, pretty_gat, _set_ticks
from ECoG_base_stats import myStats

##########################################
#Define important variables
n_comparisons  = 2 #how many conditions should be compared with each other
conds = ['erp_100', 'frontal_erp_100']

if (n_comparisons == 2) & ('erp_100' in conds) & ('frontal_erp_100' in conds):
	ListSubjects = ['EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS']
	ListFilenames = ['erp_100', 'frontal_erp_100']
	gen_filename = 'timeGen'

	scores1 = []
	scores2 = []
elif (n_comparisons == 2) & ('erp_100' in conds) & ('temporal_erp_100' in conds):
	ListSubjects = ['HS', 'KJ_I', 'LJ', 'MG', 'WS', 'KR', 'AP']
	ListFilenames = ['erp_100', 'temporal_erp_100']
	gen_filename = 'timeGen'

	scores1 = []
	scores2 = []
elif (n_comparisons == 2) & ('frontal_erp_100' in conds) & ('temporal_erp_100' in conds):
	ListSubjects = ['HS', 'KJ_I', 'LJ', 'MG', 'WS', 'KR']
	ListFilenames = ['frontal_erp_100', 'temporal_erp_100']
	gen_filename = 'timeGen'

	scores1 = []
	scores2 = []

##########################################
#Loop over conditions and subjects
for compi, comp in enumerate(conds):
	for condi, cond in enumerate(decCond):
		for subi, subject in enumerate(ListSubjects):

			#Load all of the data 
			if (cond is not 'indItems') & (cond is not 'itemPos') & (cond is not 'indItems_trainCue0_testCue0') & (cond is not 'indItems_trainCue1_testCue1') & (cond is not 'indItems_trainCue0_testCue1') & (cond is not 'indItems_trainCue1_testCue0'):
				if fdecoding is not 'perChannel':
					score = np.squeeze(np.load(data_path + comp + '/' + subject + '_BroadbandERP_' + cond + '_' + gen_filename + '_' + comp + '_acc' + str(acc) + '_score.npy'))
				else:
					score = np.squeeze(np.load(data_path + comp + '/' + subject + '_erp_timDim_' + cond + '_diag_' + comp + '_acc' + str(acc) + '_score.npy'))
					score = np.mean(score, axis=1)
			elif (cond is 'indItems') | (cond is 'indItems_trainCue0_testCue0') | (cond is 'indItems_trainCue1_testCue1') | (cond is 'indItems_trainCue1_testCue0'):
				if fdecoding is not 'perChannel':
					score = np.squeeze(np.load(data_path + comp + '/' + subject + '_BroadbandERP_' + cond + '_' + gen_filename + '_' + comp + '_acc' + str(acc) + '_average_score.npy'))
				else:
					if (cond is 'indItems') & (comp is 'erp_100'):
						score = np.squeeze(np.load(data_path + comp + '/' + subject + '_erp_timDim_' + cond + '_diag_' + comp + '_acc' + str(acc) + '_average_score.npy'))
						score = np.mean(score, axis=1)
					elif (cond is 'indItems') & (comp is not 'erp_100'):
						score = np.squeeze(np.load(data_path + comp + '/' + subject + '_erp_timDim_' + cond + '_diag_' + comp + '_acc' + str(acc) + '_average_score.npy'))
						score = np.mean(score, axis=1)
			elif (cond is 'itemPos') | (cond is 'indItems_trainCue0_testCue1'):
				if fdecoding is not 'perChannel':
					score = np.mean(np.load(data_path + comp + '/' + subject + '_BroadbandERP_' + cond + '_' + gen_filename + '_' + comp + '_acc' + str(acc) + '_score.npy'), axis=0)
					score = np.squeeze(score)	#score_old = np.squeeze(np.load(data_path + ListFilenames[0] + '/orig_' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_score.npy'))
				else:
					score = np.squeeze(np.load(data_path + comp + '/' + subject + '_erp_timDim_' + cond + '_diag_' + comp + '_acc' + str(acc) + '_average_score.npy'))
					score = np.mean(score, axis=1)

			if fdecoding is not 'perChannel':
				time = np.load(data_path + comp + '/' + subject + '_BroadbandERP_' + cond + '_' + gen_filename + '_' + comp + '_acc' + str(acc) + '_time.npy')
			else:
				if (comp is 'erp_100') | (comp is 'frontal_erp_100') | (comp is 'temporal_erp_100'):
					time = np.arange(-.2, 4.5, .1)
				elif (comp is 'probeLocked_erp_100_longEpoch') | (comp is 'frontal_probeLocked_erp_100_longEpoch') | (comp is 'temporal_probeLocked_erp_100_longEpoch'):
					time =  np.arange(-4.5, .5, .1)
				elif (comp is 'respLocked_erp_100') | (comp is 'frontal_respLocked_erp_100') | (comp is 'temporal_respLocked_erp_100'):
					time = np.arange(-4.0, .0, .1)

			#Include only relevant period of the trial (i.e., baseline + epoch)
			if fdecoding is not 'perChannel':
				if (comp != 'respLocked_erp_100') & (comp != 'frontal_respLocked_erp_100') & (comp != 'temporal_respLocked_erp_100') & (comp != 'respLocked_tfa_wavelet') & (comp != 'probeLocked_erp_100_longEpoch') & (comp != 'frontal_probeLocked_erp_100_longEpoch') & (comp != 'temporal_probeLocked_erp_100_longEpoch'):
					begin_t = find_nearest(time, bl[0])
				else:
					begin_t = find_nearest(time, trainTime[0])

				if gen_filename is 'diag':
					score = score[:, begin_t[0] :]
				else:
					score = score[begin_t[0] :, begin_t[0] :]

			if (n_comparisons == 2):
				if compi == 0:
					scores1.append(score)
					np.asarray(scores1)
				elif compi == 1:
					scores2.append(score)
					np.asarray(scores2)

#Reshape
if fdecoding is not 'perChannel':
	if n_comparisons == 2:
		scores1 = np.reshape(scores1, (len(decCond), len(ListSubjects), np.shape(score)[0], np.shape(score)[1]))
		scores2 = np.reshape(scores2, (len(decCond), len(ListSubjects), np.shape(score)[0], np.shape(score)[1]))
else:
	scores = np.reshape(scores, (len(decCond), len(ListSubjects), np.shape(score)[0]))

##########################################
#Compute stats if wanted
p_values_diag = []
p_values = []

if n_comparisons == 2: 
	if gen_filename is 'diag':
		for condi, cond in enumerate(decCond):
			p_value_diag = myStats(np.array(scores1)[condi, :, :, None] - np.array(scores2)[condi, :, :, None], tail=0, permutations=n_permutations)
			p_values_diag.append(p_value_diag)

		np.savez(result_path + 'erp_100/Stats/Group_BroadbandERP_' + cond + '_' + gen_filename + '_' + ListFilenames[0] + '_comp_' + ListFilenames[0] + '_' + ListFilenames[1] + '_stats.npz', p_values_diag)
	else:
		for condi, cond in enumerate(decCond):
			tmp1 = [np.diag(sc) for sc in scores1[condi]]
			tmp2 = [np.diag(sc) for sc in scores2[condi]]
			p_value = myStats(np.array(scores1[condi]) - np.array(scores2[condi]), tail=0, permutations=n_permutations)
			p_value_diag = myStats(np.array(tmp1)[:, :, None] - np.array(tmp2)[:, :, None], tail=0, permutations=n_permutations)

			p_values_diag.append(p_value_diag)
			p_values.append(p_value)

			del tmp1, tmp2

		np.savez(result_path + 'erp_100/Stats/Group_BroadbandERP_' + cond + '_' + gen_filename + '_' + ListFilenames[0] + '_comp_' + ListFilenames[0] + '_' + ListFilenames[1] + '_stats.npz', p_value, p_values_diag)

