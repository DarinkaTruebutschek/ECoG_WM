#Purpose: This scripts computes & plots the comparison between different conditions of decoding
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
import matplotlib.font_manager as font_manager

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
n_comparisons  = 3 #how many conditions should be compared with each other
conds = ['erp_100', 'frontal_erp_100', 'temporal_erp_100']

if (n_comparisons == 2) & ('frontal_erp_100' in conds):
	ListSubjects = ['EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS']
	ListFilenames = ['erp_100', 'frontal_erp_100']
	gen_filename = 'timeGen'

	scores1 = []
	scores2 = []

else:
	ListFilenames = conds
	gen_filename = 'timeGen'

	scores1 = []
	scores2 = []
	scores3 = []

##########################################
#Loop over conditions and subjects
for compi, comp in enumerate(conds):
	for condi, cond in enumerate(decCond):

		if (n_comparisons == 3) & (comp is 'erp_100') | (n_comparisons == 3) & (comp is 'probeLocked_erp_100_longEpoch') | (n_comparisons == 3) & (comp is 'respLocked_erp_100'):
			ListSubjects = ['EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP']
		elif (n_comparisons == 3) & (comp is 'frontal_erp_100') | (n_comparisons == 3) & (comp is 'frontal_probeLocked_erp_100_longEpoch') | (n_comparisons == 3) & (comp is 'frontal_respLocked_erp_100'):
			ListSubjects = ['EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS']
		elif (n_comparisons == 3) & (comp is 'temporal_erp_100') | (n_comparisons == 3) & (comp is 'temporal_probeLocked_erp_100_longEpoch') | (n_comparisons == 3) & (comp is 'temporal_respLocked_erp_100'):
			ListSubjects = ['HS', 'KJ_I', 'LJ', 'MG', 'WS', 'KR', 'AP']

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
					if (cond is 'indItems') & (fmethod is 'erp_100'):
						score = np.squeeze(np.load(data_path + comp + '/' + subject + '_erp_timDim_' + cond + '_diag_' + comp + '_acc' + str(acc) + '_average_score.npy'))
						score = np.mean(score, axis=1)
					elif (cond is 'indItems') & (fmethod is not 'erp_100'):
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
			elif (n_comparisons == 3):
				if compi == 0:
					scores1.append(score)
					np.asarray(scores1)
				elif compi == 1:
					scores2.append(score)
					np.asarray(scores2)
				elif compi == 2:
					scores3.append(score)
					np.asarray(scores3)


#Reshape
if fdecoding is not 'perChannel':
	if n_comparisons == 2:
		scores1 = np.reshape(scores1, (len(decCond), len(ListSubjects), np.shape(score)[0], np.shape(score)[1]))
		scores2 = np.reshape(scores2, (len(decCond), len(ListSubjects), np.shape(score)[0], np.shape(score)[1]))
	else:
		scores1 = np.reshape(scores1, (len(decCond), 11, np.shape(score)[0], np.shape(score)[1]))
		scores2 = np.reshape(scores2, (len(decCond), 10, np.shape(score)[0], np.shape(score)[1]))
		scores3 = np.reshape(scores3, (len(decCond), 7, np.shape(score)[0], np.shape(score)[1]))

##########################################
#Load stats
tmp=np.load(result_path + 'erp_100/Stats/Group_BroadbandERP_buttonPress_' + gen_filename + '_erp_100_comp_' + ListFilenames[0] + '_' + ListFilenames[1] + '_stats.npz')
p_values_diag_score1 = tmp['arr_1']

tmp=np.load(result_path + 'erp_100/Stats/Group_BroadbandERP_buttonPress_' + gen_filename + '_erp_100_comp_' + ListFilenames[0] + '_' + ListFilenames[2] + '_stats.npz')
p_values_diag_score2 = tmp['arr_1']

tmp=np.load(result_path + 'erp_100/Stats/Group_BroadbandERP_buttonPress_' + gen_filename + '_frontal_erp_100_comp_' + ListFilenames[1] + '_' + ListFilenames[2] + '_stats.npz')
p_values_diag_score3 = tmp['arr_1']

##########################################
#Smooth if need be (for visualization only)
if n_comparisons == 2:
	scores_smooth1 = np.empty_like(scores1)
	scores_smooth2 = np.empty_like(scores2)
	if smoothWindow > 0:
		for condi, cond in enumerate(decCond):
			scores_smooth1[condi] = [my_smooth(sc, smoothWindow) for sc in scores1[condi]]
			scores_smooth2[condi] = [my_smooth(sc, smoothWindow) for sc in scores2[condi]]
	else:
		scores_smooth1 = scores1
		scores_smooth2 = scores2
elif n_comparisons == 3:
	scores_smooth1 = np.empty_like(scores1)
	scores_smooth2 = np.empty_like(scores2)
	scores_smooth3 = np.empty_like(scores3)
	if smoothWindow > 0:
		for condi, cond in enumerate(decCond):
			scores_smooth1[condi] = [my_smooth(sc, smoothWindow) for sc in scores1[condi]]
			scores_smooth2[condi] = [my_smooth(sc, smoothWindow) for sc in scores2[condi]]
			scores_smooth3[condi] = [my_smooth(sc, smoothWindow) for sc in scores3[condi]]
	else:
		scores_smooth1 = scores1
		scores_smooth2 = scores2
		scores_smooth3 = scores3

##########################################
#Plot all conditions seperately as subplot & retrieve the necessary info for the stats
if fdecoding is not 'perChannel':
	time_short = time[begin_t[0] :]
else:
	time_short = time

sig_times1 = []
peaks_sig1 = []

sig_times2 = []
peaks_sig2 = []

sig_times3 = []
peaks_sig3 = []

if (decCond[0] is 'cue') | (fdecoding is 'perChannel'):
	fig_group, ax_group = plt.subplots(len(decCond), 1, sharey=False, figsize=[5, 10])
else:
	fig_group, ax_group = plt.subplots(2, 2, sharey=False, figsize=[8, 4])

for condi, cond in enumerate(decCond):
	if (decCond[0] is not 'cue') & (fdecoding is not 'perChannel'):
		if condi == 0:
			ax_tmp1 = 0
			ax_tmp2 = 0
		elif condi == 1:
			ax_tmp1 = 0
			ax_tmp2 = 1
		elif condi == 2:
			ax_tmp1 = 1
			ax_tmp2 = 0
		elif condi == 3:
			ax_tmp1 = 1
			ax_tmp2 = 1

	#Get stats
	#Significant time windows & clusters: SCORE 1
	sig_time1 = (time_short[p_values_diag_score1[condi] < stat_alpha])
	sig_times1.append(sig_time1)

	if sig_time1.size > 0:
		onset_time, offset_time = findTimeClust(sig_times1[condi])
		print (onset_time)

		peak_sig1 = p_values_diag_score1[condi][p_values_diag_score1[condi] < stat_alpha]
		peaks_sig1.append(peak_sig1)

	#Save necessary info in one convenient file
	if sig_time1.size > 0:
		if isinstance(onset_time, np.floating):
			df_tmp = pd.DataFrame([[onset_time, offset_time]], columns=['Onset', 'Offset'])
			df_tmp2 = pd.DataFrame([[peak_sig1]], columns=['PeakSig'])
		else:
			df_tmp = pd.DataFrame(np.transpose([onset_time, offset_time]), columns=['Onset', 'Offset'])
			df_tmp2 = pd.DataFrame([[peak_sig1]], columns=['PeakSig'])

		df = pd.concat([df_tmp, df_tmp2], ignore_index=True, axis=0)
		df.to_csv(result_path + 'erp_100/Stats/Group_BroadbandERP_' + cond + '_' + gen_filename + '_erp_100_comp_' + ListFilenames[0] + '_' + ListFilenames[1] + '_statValues.csv')

		del(onset_time, offset_time)

	#Significant time windows & clusters: SCORE 2
	sig_time2 = (time_short[p_values_diag_score2[condi] < stat_alpha])
	sig_times2.append(sig_time2)

	if sig_time2.size > 0:
		onset_time, offset_time = findTimeClust(sig_times2[condi])
		print (onset_time)

		peak_sig2 = p_values_diag_score2[condi][p_values_diag_score2[condi] < stat_alpha]
		peaks_sig2.append(peak_sig2)

	#Save necessary info in one convenient file
	if sig_time2.size > 0:
		if isinstance(onset_time, np.floating):
			df_tmp = pd.DataFrame([[onset_time, offset_time]], columns=['Onset', 'Offset'])
			df_tmp2 = pd.DataFrame([[peak_sig2]], columns=['PeakSig'])
		else:
			df_tmp = pd.DataFrame(np.transpose([onset_time, offset_time]), columns=['Onset', 'Offset'])
			df_tmp2 = pd.DataFrame([[peak_sig2]], columns=['PeakSig'])

		df = pd.concat([df_tmp, df_tmp2], ignore_index=True, axis=0)
		df.to_csv(result_path + 'erp_100/Stats/Group_BroadbandERP_' + cond + '_' + gen_filename + '_erp_100_comp_' + ListFilenames[0] + '_' + ListFilenames[2] + '_statValues.csv')

		del(onset_time, offset_time)

	#Significant time windows & clusters: SCORE 3
	sig_time3 = (time_short[p_values_diag_score3[condi] < stat_alpha])
	sig_times3.append(sig_time3)

	if sig_time3.size > 0:
		onset_time, offset_time = findTimeClust(sig_times3[condi])
		print (onset_time)

		peak_sig3 = p_values_diag_score3[condi][p_values_diag_score3[condi] < stat_alpha]
		peaks_sig3.append(peak_sig3)

	#Save necessary info in one convenient file
	if sig_time3.size > 0:
		if isinstance(onset_time, np.floating):
			df_tmp = pd.DataFrame([[onset_time, offset_time]], columns=['Onset', 'Offset'])
			df_tmp2 = pd.DataFrame([[peak_sig3]], columns=['PeakSig'])
		else:
			df_tmp = pd.DataFrame(np.transpose([onset_time, offset_time]), columns=['Onset', 'Offset'])
			df_tmp2 = pd.DataFrame([[peak_sig3]], columns=['PeakSig'])

		df = pd.concat([df_tmp, df_tmp2], ignore_index=True, axis=0)
		df.to_csv(result_path + 'erp_100/Stats/Group_BroadbandERP_' + cond + '_' + gen_filename + '_erp_100_comp_' + ListFilenames[1] + '_' + ListFilenames[2] + '_statValues.csv')

		del(onset_time, offset_time)

	#Plot
	if (decCond[0] == 'cue') & (fdecoding is not 'perChannel'):
		ax_group[condi].plot(time[begin_t[0] :], np.mean(np.asarray([np.diag(sc) for sc in scores_smooth3[condi]]), axis=0), color=line_color[condi], linewidth=2, linestyle='-.', alpha=.6)
		ax_group[condi].plot(time[begin_t[0] :], np.mean(np.asarray([np.diag(sc) for sc in scores_smooth2[condi]]), axis=0), color=line_color[condi], linewidth=2, linestyle='--', alpha=.8)
		ax_group[condi].plot(time[begin_t[0] :], np.mean(np.asarray([np.diag(sc) for sc in scores_smooth1[condi]]), axis=0), color=line_color[condi], linewidth=2, linestyle='-', alpha = 1)
		#pretty_decod(np.asarray([np.diag(sc) for sc in scores_smooth2[condi]]), times=time[begin_t[0] :], ax=ax_group[condi], color=line_color[condi], chance=chance,
			#alpha=.2, fill=True, thickness=0)
		#pretty_decod(np.asarray([np.diag(sc) for sc in scores_smooth1[condi]]), times=time[begin_t[0] :], ax=ax_group[condi], color=line_color[condi], chance=chance,
			#alpha=.2, fill=True, thickness=0)
	elif (fdecoding is 'perChannel'):
		pretty_decod(np.asarray(scores_smooth[condi]), times=time, ax=ax_group[condi], color=line_color[condi], sig=p_values_diag[condi]<stat_alpha, chance=chance,
			alpha=1, fill=True, thickness=0)
	else:
		pretty_decod(np.asarray([np.diag(sc) for sc in scores_smooth[condi]]), times=time[begin_t[0] :], ax=ax_group[ax_tmp1, ax_tmp2], color=line_color[condi], sig=p_values_diag[condi] < stat_alpha, chance=chance,
			alpha=1, fill=True, thickness=0)

	#Prettify
	pretty_plot(ax_group[condi])
	
	scores_diag = np.asarray([np.diag(sc) for sc in scores_smooth1[condi]])
	scores_m = np.mean(scores_diag, axis=0)
	sem = scores_diag.std(0) / np.sqrt(len(scores_diag))
	ymin, ymax = min(scores_m-4.5*sem), max(scores_m+4.5*sem)
	ax_group[condi].axhline(chance, linestyle='dotted', color='dimgray', zorder=-3)
	ax_group[condi].axvline(0, color='dimgray', zorder=-3)
	ax_group[condi].set_xlim(np.min(time_short), np.max(time_short))
	ax_group[condi].set_ylim(ymin, ymax)
	ax_group[condi].set_yticks([ymin, chance, ymax])
	ax_group[condi].set_yticklabels(['%.2f' % ymin, 'Chance', '%.2f' % ymax], fontname=font_name, fontsize=font_size, fontweight=font_weight)

	#Add legend
	if (comp is 'temporal_erp_100') & (condi == 0):
		font = font_manager.FontProperties(family=font_name, weight=font_weight, style='normal', size=font_size)

		leg = ax_group[condi].legend(['Temporal', 'Frontal', 'All'], prop=font, frameon=False, loc='best')
		leg.legendHandles[0].set_color('black')
		leg.legendHandles[1].set_color('black')
		leg.legendHandles[2].set_color('black')

	#Add stats
	scores_sem1 = scores_m - 2*sem
	scores_sem2 = scores_sem1 - .008
	scores_sem3 = scores_sem1 - .008

	if len(time_short[p_values_diag_score1[condi] < stat_alpha]) > 0: 
		#ax_group[condi].scatter(time_short[p_values_diag_score1[condi] < stat_alpha], np.repeat(min(scores_sem[p_values_diag_score1[condi] < stat_alpha]), len(time_short[p_values_diag_score1[condi] < stat_alpha])), time_short[p_values_diag_score1[condi] < stat_alpha], color='k')
		ax_group[condi].scatter(time_short[p_values_diag_score1[condi] < stat_alpha], np.repeat(min(scores_sem1), len(time_short[p_values_diag_score1[condi] < stat_alpha])), s=1, color='k', alpha=1)
	
	if len(time_short[p_values_diag_score2[condi] < stat_alpha]) > 0: 
		#ax_group[condi].scatter(time_short[p_values_diag_score1[condi] < stat_alpha], np.repeat(min(scores_sem[p_values_diag_score1[condi] < stat_alpha]), len(time_short[p_values_diag_score1[condi] < stat_alpha])), time_short[p_values_diag_score1[condi] < stat_alpha], color='k')
		ax_group[condi].scatter(time_short[p_values_diag_score2[condi] < stat_alpha], np.repeat(min(scores_sem2), len(time_short[p_values_diag_score2[condi] < stat_alpha])), s=1, color='darkgray', alpha=1)
	
	if len(time_short[p_values_diag_score3[condi] < stat_alpha]) > 0: 
		#ax_group[condi].scatter(time_short[p_values_diag_score1[condi] < stat_alpha], np.repeat(min(scores_sem[p_values_diag_score1[condi] < stat_alpha]), len(time_short[p_values_diag_score1[condi] < stat_alpha])), time_short[p_values_diag_score1[condi] < stat_alpha], color='k')
		ax_group[condi].scatter(time_short[p_values_diag_score3[condi] < stat_alpha], np.repeat(min(scores_sem3), len(time_short[p_values_diag_score3[condi] < stat_alpha])), s=1, color='dimgray', alpha=1)

	#Add event markers
	if (fmethod is 'erp_100') | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100'):
		if (decCond[0] == 'cue') | (fdecoding is 'perChannel'):
			ax_group[condi].axvline(1.500, color='dimgray', zorder=-3) #indicates item onset
		else:
			ax_group[ax_tmp1, ax_tmp2].axvline(1.500, color='dimgray', zorder=-3) #indicates item onset

	elif (fmethod is 'probeLocked_erp_100_longEpoch') | (fmethod is 'frontal_probeLocked_erp_100_longEpoch') | (fmethod is 'temporal_probeLocked_erp_100_longEpoch'):
		ax_group[condi].axvline(0, color='dimgray', zorder=-3) #indicates probe onset
		ax_group[condi].axvline(-3.0, color='dimgray', zorder=-3) #indicates item onset
		ax_group[condi].axvline(-4.5, color='dimgray', zorder=-3) #indicates cue onset

	if (decCond[0] == 'cue') | (fdecoding is 'perChannel'):
		if condi == 0:
			ax_group[condi].set_ylabel('AUC', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
		else:
			ax_group[condi].set_ylabel('')
	else:
		if (condi == 0) | (condi == 2):
			ax_group[ax_tmp1, ax_tmp2].set_ylabel('AUC', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
		else:
			ax_group[ax_tmp1, ax_tmp2].set_ylabel('')

	if (decCond[0] == 'cue') | (fdecoding is 'perChannel'):
		if (fmethod is 'erp_100') | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100'):	
			if condi < len(decCond)-1:
				ax_group[condi].set_xticks(np.arange(0., 4.3, .5)), 
				ax_group[condi].set_xticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[condi].set_xlabel('')
			else:
				ax_group[condi].set_xticks(np.arange(0., 4.3, .5)), 
				ax_group[condi].set_xticklabels(['Cue', '0.5', '1.0', 'Item', '2.0', '2.5', '3.0', '3.5', '4.0'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[condi].set_xlabel('Time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
		elif (fmethod is 'respLocked_erp_100') | (fmethod is 'frontal_respLocked_erp_100') | (fmethod is 'temporal_respLocked_erp_100'):
			if condi < len(decCond)-1:
				ax_group[condi].set_xticks(np.arange(-3.5, -.35, .5)), 
				ax_group[condi].set_xticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[condi].set_xlabel('')
			else:
				ax_group[condi].set_xticks(np.arange(-3.5, -.35, .5)), 
				ax_group[condi].set_xticklabels(['-3.5', '-3.0', '-2.5', '-2.0', '-1.5', '-1.0', '-0.5'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[condi].set_xlabel('Time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
		elif (fmethod is 'probeLocked_erp_100_longEpoch') | (fmethod is 'frontal_probeLocked_erp_100_longEpoch') | (fmethod is 'temporal_probeLocked_erp_100_longEpoch'):
			if condi < len(decCond)-1:
				ax_group[condi].set_xticks(np.arange(-4.5, .5, .5)), 
				ax_group[condi].set_xticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[condi].set_xlabel('')
			else:
				ax_group[condi].set_xticks(np.arange(-4.5, .5, .5)), 
				ax_group[condi].set_xticklabels(['Cue', '-4.0', '-3.5', 'Item', '-2.5', '-2.0', '-1.5', '-1.0', '-0.5', 'Probe', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[condi].set_xlabel('Time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
	else:
		if (fmethod is 'erp_100') | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100'):	
			if (condi == 0) | (condi == 1):
				ax_group[ax_tmp1, ax_tmp2].set_xticks(np.arange(0., 4.3, .5)), 
				ax_group[ax_tmp1, ax_tmp2].set_xticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[ax_tmp1, ax_tmp2].set_xlabel('')
			else:
				ax_group[ax_tmp1, ax_tmp2].set_xticks(np.arange(0., 4.3, .5)), 
				ax_group[ax_tmp1, ax_tmp2].set_xticklabels(['Cue', '0.5', '1.0', 'Item', '2.0', '2.5', '3.0', '3.5', '4.0'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[ax_tmp1, ax_tmp2].set_xlabel('Time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)

	#Titles
	if (decCond[0] == 'cue') | (fdecoding is 'perChannel'):
		ax_group[condi].set_title(figTitles[condi], fontname=font_name, fontsize=font_size+2, fontweight='bold')
	else:
		if (condi == 0) | (condi == 1):
			ax_group[ax_tmp1, ax_tmp2].set_title(figTitles[condi], fontname=font_name, fontsize=font_size+2, fontweight='bold')

	fig_group.tight_layout()

#Save
if (fmethod is 'erp_100') | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100'):
	plt.savefig(result_path + 'erp_100/Figures/Group_BroadbandERP_StimLocked_' + cond + '_' + gen_filename + '_erp_100_comp_' + ListFilenames[0] + '_' + ListFilenames[1] + '_decodingTimecourse.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + 'erp_100/Figures/Group_BroadbandERP_StimLocked_' + cond + '_' + gen_filename + '_erp_100_comp_' + ListFilenames[0] + '_' + ListFilenames[1] + '_decodingTimecourse.svg')
	renderPDF.drawToFile(tmp, result_path + 'erp_100/Figures/Group_BroadbandERP_StimLocked_' + cond + '_' + gen_filename + '_' + ListFilenames[0] + 'comp_' + ListFilenames[0] + '_' + ListFilenames[1] + '_decodingTimecourse.pdf')
elif (fmethod is 'respLocked_erp_100') | (fmethod is 'frontal_respLocked_erp_100') | (fmethod is 'temporal_respLocked_erp_100'):
	plt.savefig(result_path + 'erp_100/Figures/Group_BroadbandERP_RespLocked_' + cond + '_' + gen_filename + '_erp_100_comp_' + ListFilenames[0] + '_' + ListFilenames[1] + '_decodingTimecourse.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + 'erp_100/Figures/Group_BroadbandERP_RespLocked_' + cond + '_' + gen_filename + '_erp_100_comp_' + ListFilenames[0] + '_' + ListFilenames[1] + '_decodingTimecourse.svg')
	renderPDF.drawToFile(tmp, result_path + 'erp_100/Figures/Group_BroadbandERP_RespLocked_' + cond + '_' + gen_filename + '_' + ListFilenames[0] + 'comp_' + ListFilenames[0] + '_' + ListFilenames[1] + '_decodingTimecourse.pdf')
elif (fmethod is 'probeLocked_erp_100_longEpoch') | (fmethod is 'frontal_probeLocked_erp_100_longEpoch') | (fmethod is 'temporal_probeLocked_erp_100_longEpoch'):
	plt.savefig(result_path + 'erp_100/Figures/Group_BroadbandERP_ProbeLocked_' + cond + '_' + gen_filename + '_erp_100_comp_' + ListFilenames[0] + '_' + ListFilenames[1] + '_decodingTimecourse.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + 'erp_100/Figures/Group_BroadbandERP_ProbeLocked_' + cond + '_' + gen_filename + '_erp_100_comp_' + ListFilenames[0] + '_' + ListFilenames[1] + '_decodingTimecourse.svg')
	renderPDF.drawToFile(tmp, result_path + 'erp_100/Figures/Group_BroadbandERP_ProbeLocked_' + cond + '_' + gen_filename + '_' + ListFilenames[0] + 'comp_' + ListFilenames[0] + '_' + ListFilenames[1] + '_decodingTimecourse.pdf')

plt.show()

