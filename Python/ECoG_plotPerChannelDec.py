#Purpose: This script plots the perChannel decoding results.
#Project: ECoG
#Author: D.T.
#Date: 20 May 2021

##########################################
#Load common libraries
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
import pymatreader
import scipy.stats as scipy

#from mpl_toolkits.axes_grid1.inset_locator import inset_axes
from svglib.svglib import svg2rlg
from reportlab.graphics import renderPDF

#Load specific variables and functions
from base import findTimeClust, find_nearest, my_smooth
from ECoG_finalFigs_cfg import *
from ECoG_base_plot import pretty_colorbar
from ECoG_base_plotDecoding import pretty_decod, pretty_gat 
from ECoG_base_stats import myStats

##########################################
#Define important variables
ListSubjects = ['EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP']
ListFilenames = 'erp_100_TimDim_timeBin-100ms_meanSubtraction'#'erp_100_TimDim_timeBin-100ms_nomeanSubtraction'

if generalization:
	gen_filename = 'timeGen'
else:
	gen_filename = 'diag'

#decCond = ['itemPos']

##########################################
#Loop over conditions and subjects
for condi, cond in enumerate(decCond):

	for subi, subject in enumerate(ListSubjects):
		fig_group, ax_group = plt.subplots(1,1, sharey=False, figsize=[5, 5])

		#Load necessary data
		if (cond is not 'indItems') & (cond is not 'itemPos') & (cond is not 'indItems_trainCue0_testCue0') & (cond is not 'indItems_trainCue1_testCue1') & (cond is not 'indItems_trainCue0_testCue1') & (cond is not 'indItems_trainCue1_testCue0'):
			score = np.squeeze(np.load(data_path + ListFilenames + '/' + subject + '_erp_timDim_' + cond + '_diag_' + ListFilenames + '_acc' + str(acc) + '_score.npy'))		
		elif (cond is 'indItems') | (cond is 'indItems_trainCue0_testCue0') | (cond is 'indItems_trainCue1_testCue1') | (cond is 'indItems_trainCue1_testCue0'):
			score = np.squeeze(np.load(data_path + ListFilenames + '/' + subject + '_erp_timDim_' + cond + '_timeGen_' + ListFilenames + '_average_score.npy'))
		elif (cond is 'itemPos') | (cond is 'indItems_trainCue0_testCue1'):
			score = np.squeeze(np.load(data_path + ListFilenames + '/' + subject + '_erp_timDim_' + cond + '_diag_' + ListFilenames + '_acc' + str(acc) + '_average_score.npy'))
		
		channelMAT = pymatreader.read_mat('/media/darinka/Data0/iEEG/Results/Data/'+  subject +  '/'+  subject +  '_sortedChannels.mat')	
		sortIndex = channelMAT['sortIndex']	
		sortIndex = sortIndex-1
		sortIndex = sortIndex.astype(int)

		#Sort decoding data
		score_sorted = np.zeros((np.shape(score)[0], np.shape(score)[1]))
		for timei, time in enumerate(np.arange(np.shape(score)[0])):
			tmp = score[timei, :]
			tmp_sorted = tmp[sortIndex]
			score_sorted[timei, :] = tmp_sorted

		#score_sorted[score_sorted < .51] = np.nan

		#Plot
		im = ax_group.matshow(np.transpose(score_sorted), cmap='Reds', origin='lower')
		plt.colorbar(im, ax=ax_group)

		plt.show()
