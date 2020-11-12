#Purpose: This function prepares the time-decoding data for first visual inspection.
#Project: ECoG
#Author: D.T.
#Date: 21 January 2020

##########################################
#Load common libraries
import matplotlib.pyplot as plt
import numpy as np
import os
import scipy.io as sio
import seaborn as sns

from termcolor import colored
from svglib.svglib import svg2rlg
from reportlab.graphics import renderPDF

#Load specific variables and functions
from base import find_nearest, my_smooth
from ECoG_plotDecoding_cfg import *
from ECoG_base_plotDecoding import pretty_decod, pretty_gat 
from ECoG_base_stats import myStats

##########################################
#Define important variables
ListSubjects = ['EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP']
ListFilenames = ['tfa_wavelet_final_TimDim_allTimeBins_meanSubtraction']
ListFreqs = ([8.05664062,   9.03320312,  10.00976562,  10.98632812, 11.96289062,  12.93945312,  14.03808594,  15.01464844,
        15.99121094,  16.96777344,  17.94433594,  19.04296875, 20.99609375,  21.97265625,  22.94921875,  25.02441406, 26.97753906,  27.95410156,  30.02929688,  31.98242188,
        34.05761719,  36.98730469,  38.94042969,  41.9921875 , 45.04394531,  47.97363281,  51.02539062,  53.95507812, 57.98339844,  62.01171875,  66.04003906,  69.94628906,
        74.95117188,  79.95605469,  84.9609375 ,  90.94238281, 97.04589844, 104.00390625, 109.98535156, 118.04199219, 125.9765625 , 134.03320312, 142.94433594, 152.95410156,
       	162.96386719, 173.95019531, 185.05859375])

#winSize = 4000 #in msec
if fmethod is 'tfa_wavelet_final':
	winSize = [[-.2, 0], [0, .5], [0.5, 1.5], [1.5, 2.5], [2.5, 4.3]]
elif fmethod is 'respLocked_tfa_wavelet':
	winSize = [[-3.5, -3], [-3, -2], [-2, -1], [-1, -.5], [-.5, -.35]]

if generalization:
	gen_filename = 'timeGen'
else:
	gen_filename = 'diag'

##########################################
#Loop over subjects 

#Initialize variables
scores_1 = []
scores_2 = []
scores_3 = []
scores_4 = []
scores_5 = []

channels = []
num_chans = np.zeros(len(ListSubjects))

for subi, subject in enumerate(ListSubjects):

	#Load all of the data 
	if (decCond is not 'itemPos') & (decCond is not 'indItems'):
		score = np.load(data_path + ListFilenames[0] + '/' + subject + '_WavDec_timDim' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_score.npy') #shape: channels x labels x timebins OR timebins x channels x 1 (if no sliding window was used )
	elif decCond is 'itemPos':
		#score = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_average_score.npy') #shape: channels x labels x timebins OR timebins x channels x 1 (if no sliding window was used )
		score = np.load(data_path + ListFilenames[0] + '/' + subject + '_WavDec_timDim' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_score.npy') #shape: channels x labels x timebins OR timebins x channels x frequencies
		score = np.mean(score, axis=2)
	else:
		score = np.load(data_path + ListFilenames[0] + '/' + subject + '_WavDec_timDim' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_average_score.npy')

	channel = np.load(data_path + 'erp_100_TimDim_allTimeBins_meanSubtraction/' + subject + '_erp_timDim_cue_' + gen_filename + '_erp_100_TimDim_allTimeBins_meanSubtraction_channels.npy') #labels for the channels used

	if np.shape(score)[2] == 1:
		score = np.squeeze(score)

	if subi == 0: #as this is invariant across different subjects, it only needs to be loaded once
		time = np.load(data_path + ListFilenames[0] + '/' + subject + '_WavDec_timDim' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_time.npy') #this is the original time dimension, including pre-baseline period

		scores_1 = score[0]
		scores_2 = score[1]
		scores_3 = score[2]
		scores_4 = score[3]
		scores_5 = score[4]

		channels = channel
	else:
		scores_1 = np.vstack((scores_1, score[0]))
		scores_2 = np.vstack((scores_2, score[1]))
		scores_3 = np.vstack((scores_3, score[2]))
		scores_4 = np.vstack((scores_4, score[3]))
		scores_5 = np.vstack((scores_5, score[4]))

		channels = np.hstack((channels, channel))

	num_chans[subi] = len(channel)

#Append all
scores = []
scores.append((scores_1, scores_2, scores_3, scores_4, scores_5))
scores = np.array(np.squeeze(scores))

#Mask array
scores_m = np.ma.masked_where(scores < .51, scores)

#Plot
for timebin in np.arange(len(winSize)):
	fig_diag, ax_diag = plt.subplots(1, 1, sharey=True, figsize=[30, 10])
	plt.imshow(scores_m[timebin].T, vmin=.51, vmax=.65, origin='lower', cmap=map_color)

	#Demark individual subjects
	ax_diag.vlines(x=np.cumsum(num_chans), ymin=0, ymax=48, colors='k', zorder=-3) 

	ax_diag.set_aspect(aspect=2)

	ax_diag.set_xticks (np.arange(0., len(channels), 1))
	ax_diag.set_xticklabels(channels, fontname=font_name, fontsize=font_size-2, fontweight=font_weight, rotation='vertical')

	ax_diag.set_yticks (np.arange(0., len(ListFreqs), 1))
	ax_diag.set_yticklabels(np.round(ListFreqs), fontname=font_name, fontsize=font_size, fontweight=font_weight)

	ax_diag.set_title('Decoding ' + decCond + ' in timebin: ' + str(timebin), fontname=font_name, fontsize=font_size_gen+2, fontweight=font_weight)


	plt.colorbar()
	plt.tight_layout()

	#Save
	plt.savefig(result_path + ListFilenames[0] + '/Figures/' + 'Group_wavDec_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_timebin_' + str(timebin) + '_freqsxchans.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	plt.savefig(result_path + ListFilenames[0] + '/Figures/' + 'Group_wavDec_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_timebin_' + str(timebin) + '_freqsxchans.tiff',
		format = 'tiff', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames[0] + '/Figures/' + 'Group_wavDec_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_timebin_' + str(timebin) + '_freqsxchans.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames[0] + '/Figures/' + 'Group_wavDec_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_timebin_' + str(timebin) + '_freqsxchans.pdf')

	#Close figure
	plt.close()
