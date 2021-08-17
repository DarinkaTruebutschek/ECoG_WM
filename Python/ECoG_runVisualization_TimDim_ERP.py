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
ListFilenames = ['erp_100_TimDim_timeBin-100ms_nomeanSubtraction']

#winSize = 4000 #in msec
if ((ListFilenames[0] == 'erp_100_TimDim_timeBin-100ms_nomeanSubtraction') | (ListFilenames[0] == 'probeLocked_erp_100_longEpoch_TimDim_timeBin-100ms_nomeanSubtraction') |
	(ListFilenames[0] == 'respLocked_erp_100_TimDim_timeBin-100ms_nomeanSubtraction')):
	if fmethod is 'erp_100':
		winSize = ([[-.2, -.1], [-.1, 0], [0, .1], [.1, .2], [.2, .3], [.3, .4], [.4, .5], [.5, .6], [.6, .7], [.7, .8], [.8, .9], [.9, 1.],
		[1., 1.1], [1.1, 1.2], [1.2, 1.3], [1.3, 1.4], [1.4, 1.5], [1.5, 1.6], [1.6, 1.7], [1.7, 1.8], [1.8, 1.9], [1.9, 2.0], 
		[2., 2.1], [2.1, 2.2], [2.2, 2.3], [2.3, 2.4], [2.4, 2.5], [2.5, 2.6], [2.6, 2.7], [2.7, 2.8], [2.8, 2.9], [2.9, 3.0],
		[3., 3.1], [3.1, 3.2], [3.2, 3.3], [3.3, 3.4], [3.4, 3.5], [3.5, 3.6], [3.6, 3.7], [3.7, 3.8], [3.8, 3.9], [3.9, 4.0],
		[4., 4.1], [4.1, 4.2], [4.2, 4.3], [4.3, 4.4], [4.4, 4.5]])
	elif fmethod is 'probeLocked_erp_100_longEpoch':
		winSize = ([[-4.5, -4.4], [-4.4, -4.3], [-4.3, -4.2], [-4.2, -4.1], [-4.1, -4.0], 
		[-4.0, -3.9], [-3.9, -3.8], [-3.8, -3.7], [-3.7, -3.6], [-3.6, -3.5], [-3.5, -3.4], [-3.4, -3.3], [-3.3, -3.2], [-3.2, -3.1], [-3.1, -3.0], 
		[-3.0, -2.9], [-2.9, -2.8], [-2.8, -2.7], [-2.7, -2.6], [-2.6, -2.5], [-2.5, -2.4], [-2.4, -2.3], [-2.3, -2.2], [-2.2, -2.1], [-2.1, -2.0],
		[-2.0, -1.9], [-1.9, -1.8], [-1.8, -1.7], [-1.7, -1.6], [-1.6, -1.5], [-1.5, -1.4], [-1.4, -1.3], [-1.3, -1.2], [-1.2, -1.1], [-1.1, -1.0],
		[-1.0, -0.9], [-0.9, -0.8], [-0.8, -0.7], [-0.7, -0.6], [-0.6, -0.5], [-0.5, -0.4], [-0.4, -0.3], [-0.3, -0.2], [-0.2, -0.1], [-0.1, 0.0],
		[0.0, 0.1], [0.1, 0.2], [0.2, 0.3], [0.3, 0.4], [0.4, 0.5]])
	elif fmethod is 'respLocked_erp_100':
		winSize = ([[-4.0, -3.9], [-3.9, -3.8], [-3.8, -3.7], [-3.7, -3.6], [-3.6, -3.5], [-3.5, -3.4], [-3.4, -3.3], [-3.3, -3.2], [-3.2, -3.1], [-3.1, -3.0], 
		[-3.0, -2.9], [-2.9, -2.8], [-2.8, -2.7], [-2.7, -2.6], [-2.6, -2.5], [-2.5, -2.4], [-2.4, -2.3], [-2.3, -2.2], [-2.2, -2.1], [-2.1, -2.0],
		[-2.0, -1.9], [-1.9, -1.8], [-1.8, -1.7], [-1.7, -1.6], [-1.6, -1.5], [-1.5, -1.4], [-1.4, -1.3], [-1.3, -1.2], [-1.2, -1.1], [-1.1, -1.0],
		[-1.0, -0.9], [-0.9, -0.8], [-0.8, -0.7], [-0.7, -0.6], [-0.6, -0.5], [-0.5, -0.4], [-0.4, -0.3], [-0.3, -0.2], [-0.2, -0.1], [-0.1, 0.0]])
else:
	if fmethod is 'erp_100':
		winSize = [[-.2, 0], [0, .5], [0.5, 1.5], [1.5, 2.5], [2.5, 4.5]]
	elif fmethod is 'respLocked_erp_100':
		winSize = [[-4, -3], [-3, -2], [-2, -1], [-1, -.5], [-.5, 0]]

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
	if (decCond is not 'itemPos') & (decCond is not 'indItems'):
		score = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc1_score.npy') #shape: channels x labels x timebins OR timebins x channels x 1 (if no sliding window was used )
	elif decCond is 'itemPos':
		#score = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_average_score.npy') #shape: channels x labels x timebins OR timebins x channels x 1 (if no sliding window was used )
		score = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc1_score.npy') #shape: channels x labels x timebins OR timebins x channels x 1 (if no sliding window was used )
		score = np.mean(score, axis=2)
	else:
		if fmethod is 'erp_100':
			score = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + 'timeGen' + '_' + ListFilenames[0] + '_average_score.npy')
		else:
			score = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc1_average_score.npy')

	if decCond != 'indItems':
		channel = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc1_channels.npy') #labels for the channels used
	else:
		if fmethod is 'erp_100':
			channel = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + 'timeGen' + '_' + ListFilenames[0] + '_channels.npy')
		else:
			channel = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc1_channels.npy')
	
	if (fmethod is 'probeLocked_erp_100_longEpoch') & (decCond is 'buttonPress') & (subject is 'SB'):
		score = np.reshape(score, (len(winSize), len(channel), 1))

	if np.shape(score)[2] == 1:
		score = np.squeeze(score)

	if ((ListFilenames[0] != 'erp_100_TimDim_timeBin-100ms_nomeanSubtraction') & (ListFilenames[0] != 'probeLocked_erp_100_longEpoch_TimDim_timeBin-100ms_nomeanSubtraction') &
		(ListFilenames[0] != 'respLocked_erp_100_TimDim_timeBin-100ms_nomeanSubtraction')):
		if len(winSize) == 1:
			if (fmethod != 'respLocked_erp_100') & (winSize > 200): #to also get the baseline data if the time window is larger than the desired baseline window
				score_bl_tmp = np.load(data_path + 'erp_TimDim_timeBin_100_stepSize_100/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_erp_TimDim_timeBin_100_stepSize_100_score.npy')
				score_bl = score_bl_tmp[:, :, 0:2]

				#Concatenate with original score matrix
				score = np.concatenate((score_bl, score), axis=2)

				del score_bl_tmp, score_bl

	if subi == 0: #as this is invariant across different subjects, it only needs to be loaded once
		if (fmethod is 'erp_100') & (decCond is 'indItems'):
			time = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + 'timeGen' + '_' + ListFilenames[0] + '_acc1_time.npy') #this is the original time dimension, including pre-baseline period
			onsetTimes = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + 'timeGen' + '_' + ListFilenames[0] + '_acc1_onsetTimes.npy') #corresponds to the onset of the time bins
		else:
			time = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc1_time.npy') #this is the original time dimension, including pre-baseline period
			onsetTimes = np.load(data_path + ListFilenames[0] + '/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc1_onsetTimes.npy') #corresponds to the onset of the time bins

		if len(winSize) == 1:
			if (fmethod != 'respLocked_erp_100') & (winSize > 200):
				onsetTimes_bl_tmp = np.load(data_path + 'erp_TimDim_timeBin_100_stepSize_100/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_erp_TimDim_timeBin_100_stepSize_100_onsetTimes.npy')

				#Concatenate with the original time vector
				onsetTimes = np.concatenate((onsetTimes_bl_tmp[0:2], onsetTimes[1 :]), axis=0)

				del onsetTimes_bl_tmp

			#Sanity check: Do the onset times correspond to the number of time bins in the score?
			#if decCond is 'indItems':
				#if np.shape(onsetTimes)[0]-1 != np.shape(score)[2]:
					#print (colored('ERROR: Number of time bins and decoding dimensions do not match!', 'red'))
			#else:
				#if np.shape(onsetTimes)[0]-1 != np.shape(score)[1]:
					#print (colored('ERROR: Number of time bins and decoding dimensions do not match!', 'red'))

	#Append scores of all subjects (in preparation for z-scoring)
	scores.append(score)
	channels.append(channel)

	#First, plot individual channels for each subject to get an idea
	print('Plotting ', subject)

	if np.shape(score)[1] == 1: #this happens if trained on entire time window (in this case, just plot a bar plot and exit)
		fig_bar = plt.figure(figsize=[60, 8])
		sns.set_style("dark")
		ax = sns.barplot(x=channel, y=np.squeeze(score), palette="Spectral")
		
		#Add relevant info
		ax.axhline(0.5, color='dimgray', zorder=-3) #indicates chance
		#plt.rcParams.update({'fontname': font_name, 'font.size': font_size, 'font.weight': font_weight})

		#Save
		plt.savefig(result_path + ListFilenames[0] + '/Figures/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_barPlot_Channels.svg',
		 format = 'svg', dpi = 300, bbox_inches = 'tight')
		tmp = svg2rlg(result_path + ListFilenames[0] + '/Figures/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_barPlot_Channels.svg')
		renderPDF.drawToFile(tmp, result_path + ListFilenames[0] + '/Figures/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_barPlot_Channels.pdf')

	#Close figure
	plt.close()

	'''
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
	'''

	#Save info for matlab
	if ((ListFilenames[0] != 'erp_100_TimDim_timeBin-100ms_nomeanSubtraction') & (ListFilenames[0] != 'probeLocked_erp_100_longEpoch_TimDim_timeBin-100ms_nomeanSubtraction') &
		(ListFilenames[0] != 'respLocked_erp_100_TimDim_timeBin-100ms_nomeanSubtraction')):
		if len(winSize) == 1:
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
		elif len(winSize) > 1:
			sio.savemat(data_path + ListFilenames[0] + '/forMatlab/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_scores.mat', mdict={'data': score}) 
			sio.savemat(data_path + ListFilenames[0] + '/forMatlab/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_channels.mat', mdict={'data': channel}) 

	elif ((ListFilenames[0] == 'erp_100_TimDim_timeBin-100ms_nomeanSubtraction') | (ListFilenames[0] == 'probeLocked_erp_100_longEpoch_TimDim_timeBin-100ms_nomeanSubtraction') |
		(ListFilenames[0] == 'respLocked_erp_100_TimDim_timeBin-100ms_nomeanSubtraction')):
		if fmethod is 'erp_100':
			sio.savemat(data_path + ListFilenames[0] + '/forMatlab/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_scores.mat', mdict={'data': score})
			sio.savemat(data_path + ListFilenames[0] + '/forMatlab/' + subject + '_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_channels.mat', mdict={'data': channel})
		elif fmethod is 'probeLocked_erp_100_longEpoch':
			sio.savemat(data_path + ListFilenames[0] + '/forMatlab/' + subject + '_probeLocked_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_scores.mat', mdict={'data': score})
			sio.savemat(data_path + ListFilenames[0] + '/forMatlab/' + subject + '_probelocked_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_channels.mat', mdict={'data': channel})
		elif fmethod is 'respLocked_erp_100':
			sio.savemat(data_path + ListFilenames[0] + '/forMatlab/' + subject + '_respLocked_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_scores.mat', mdict={'data': score})
			sio.savemat(data_path + ListFilenames[0] + '/forMatlab/' + subject + '_respLocked_erp_timDim_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_channels.mat', mdict={'data': channel})
			
			
	'''
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
'''
