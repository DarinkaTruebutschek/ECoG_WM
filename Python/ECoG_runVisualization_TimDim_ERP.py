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
ListSubjects = ['EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'AS', 'AP', 'KR', 'CD']
ListFilenames = ['respLocked_erp_TimDim_timeBin_100_stepSize_100']

winSize = 100 #in msec

if generalization:
	gen_filename = 'timeGen'
else:
	gen_filename = 'diag'

##########################################
#Loop over subjects 

#Initialize variables
scores = []
channels = []

for subi, subject in enumerate(ListSubjects):

	#Load all of the data 
	score = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_score.npy') #shape: channels x labels x timebins
	channel = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_channels.npy') #labels for the channels used

	if (fmethod != 'respLocked_erp_100') & (winSize > 200): #to also get the baseline data if the time window is larger than the desired baseline window
		score_bl_tmp = np.load(data_path + 'erp_TimDim_timeBin_100_stepSize_100/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_erp_TimDim_timeBin_100_stepSize_100_score.npy')
		score_bl = score_bl_tmp[:, :, 0:2]

		#Concatenate with original score matrix
		score = np.concatenate((score_bl, score), axis=2)

		del score_bl_tmp, score_bl

	if subi == 0: #as this is invariant across different subjects, it only needs to be loaded once
		time = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_time.npy') #this is the original time dimension, including pre-baseline period
		onsetTimes = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_onsetTimes.npy') #corresponds to the onset of the time bins

		if (fmethod != 'respLocked_erp_100') & (winSize > 200):
			onsetTimes_bl_tmp = np.load(data_path + 'erp_TimDim_timeBin_100_stepSize_100/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_erp_TimDim_timeBin_100_stepSize_100_onsetTimes.npy')

			#Concatenate with the original time vector
			onsetTimes = np.concatenate((onsetTimes_bl_tmp[0:2], onsetTimes[1 :]), axis=0)

			del onsetTimes_bl_tmp

		#Sanity check: Do the onset times correspond to the number of time bins in the score?
		if decCond is 'indItems':
			if np.shape(onsetTimes)[0]-1 != np.shape(score)[2]:
				print (colored('ERROR: Number of time bins and decoding dimensions do not match!', 'red'))
		else:
			if np.shape(onsetTimes)[0]-1 != np.shape(score)[1]:
				print (colored('ERROR: Number of time bins and decoding dimensions do not match!', 'red'))

	#First, plot individual channels for each subject to get an idea
	print('Plotting ', subject)

	#fig_diag, ax_diag = plt.subplots(7, 7, sharex=True, sharey=True, squeeze=True, figsize=[30, 30])
	fig_diag = plt.figure(figsize=[30, 30])
	gs = fig_diag.add_gridspec(7, 7, wspace=.5, hspace=.5)

	for chani, chan_label in enumerate(channel):
		#print(chan_label)
		
		ax = fig_diag.add_subplot(gs[chani])

		if decCond is 'indItems':
			pretty_decod(np.mean(score[chani], axis=0), times=time[onsetTimes.astype(int)][0 : -1], ylabel=chan_label, color=line_color[0], 
				sig=None, chance=chance, ax=ax, thickness=line_thickness, lim=[.45, .55])
		else:
			pretty_decod(score[chani], times=time[onsetTimes.astype(int)][0 : -1], ylabel=chan_label, color=line_color[0], 
				sig=None, chance=chance, ax=ax, thickness=line_thickness, lim=[.45, .8])

		if fmethod != 'respLocked_erp_100':
			#Add relevant info
			ax.axvline(1.500, color='dimgray', zorder=-3) #indicates item onset
			ax.set_xticks(np.arange(0., 4.5, .5))
			ax.set_xticklabels(['Cue', '', '', 'Item', '', '', '', '', ''], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
		else:
			#Add relevant info
			ax.set_xticks(np.arange(-4.0, -0.1, .5))
			ax.set_xticklabels(['-4.0', '', '-3.0', '', '-2.0', '', '-1.0', ''], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels

		#ax.set_title('Average ' + ListFilenames[0] + ' for subject ' + subject, fontname=font_name, fontsize=font_size+2, fontweight=font_weight)

	#Save
	plt.savefig(result_path + ListFilenames[0] + '/Figures/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_decodingTimecourse.svg',
		 format = 'svg', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames[0] + '/Figures/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_decodingTimecourse.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames[0] + '/Figures/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_decodingTimecourse.pdf')

	#Close figure
	plt.close()

	#Save info for matlab
	if decCond is 'indItems':
		avg_score_bl = np.mean(np.mean(score[:, :, 0:2], axis=2), axis=1)
		avg_score_preItem = np.mean(np.mean(score[:, :, 2:6], axis=2), axis=1)
		avg_score_postItem = np.mean(np.mean(score[:, :, 6:], axis=2), axis=1)

		sio.savemat(data_path + ListFilenames[0] + '/forMatlab/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_averageDecodingPerChannel_bl.mat', mdict={'data': avg_score_bl}) 
		sio.savemat(data_path + ListFilenames[0] + '/forMatlab/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_averageDecodingPerChannel_preItem.mat', mdict={'data': avg_score_preItem}) 
		sio.savemat(data_path + ListFilenames[0] + '/forMatlab/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_averageDecodingPerChannel_postItem.mat', mdict={'data': avg_score_postItem}) 
		sio.savemat(data_path + ListFilenames[0] + '/forMatlab/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_channels.mat', mdict={'data': channel}) 
	elif decCond is 'respButtons':
		avg_score = np.mean(score, axis=1)

		sio.savemat(data_path + ListFilenames[0] + '/forMatlab/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_averageDecodingPerChannel_preResp.mat', mdict={'data': avg_score}) 
		sio.savemat(data_path + ListFilenames[0] + '/forMatlab/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_channels.mat', mdict={'data': channel}) 
	
	#Plot overall average in comparison with chanxtime decoding
	if decCond is 'indItems':
		scores.append(np.mean(np.mean(score, axis=0), axis=0))
	else:
		scores.append(np.mean(score, axis=0))

if fmethod != 'respLocked_erp_100':
	fig_group, ax_group = plt.subplots(1, 1, sharey=True, figsize=[10, 5])
	pretty_decod(scores, times=time[onsetTimes.astype(int)][0 : -1], color=line_color[0], sig=None, chance=chance, fill=True, ax=ax_group, thickness=line_thickness)

	#Add relevant info
	ax_group.axvline(1.500, color='dimgray', zorder=-3) #indicates item onset

	ax_group.set_xticks(np.arange(0., 4.3, .5)), 
	ax_group.set_xticklabels(['Cue', '', '', 'Item', '', '', '', '', ''], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels

	ax_group.set_title('Average ' + ListFilenames[0], fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
else:
	fig_group, ax_group = plt.subplots(1, 1, sharey=True, figsize=[10, 5])
	pretty_decod(np.array(scores), times=time[onsetTimes.astype(int)][0 : -1], color=line_color[0], sig=None, chance=chance, fill=True, ax=ax_group, thickness=line_thickness)

	#Add relevant info
	ax.set_xticks(np.arange(-4.0, -0.1, .5))
	ax.set_xticklabels(['-4.0', '', '-3.0', '', '-2.0', '', '-1.0', ''], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels

	ax_group.set_title('Average ' + ListFilenames[0], fontname=font_name, fontsize=font_size+2, fontweight=font_weight)

#Save
plt.savefig(result_path + ListFilenames[0] + '/Figures/Group_averageDecodingPerChannel_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_decodingTimecourse.svg',
	format = 'svg', dpi = 300, bbox_inches = 'tight')
tmp = svg2rlg(result_path + ListFilenames[0] + '/Figures/Group_averageDecodingPerChannel_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_decodingTimecourse.svg')
renderPDF.drawToFile(tmp, result_path + ListFilenames[0] + '/Figures/Group_averageDecodingPerChannel_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_decodingTimecourse.pdf')

