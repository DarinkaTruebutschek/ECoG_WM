#Purpose: This function plots the final decoding results for the manuscript.
#Project: ECoG
#Author: D.T.
#Date: 01 December 2020

##########################################
#Load common libraries
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
import scipy.stats as scipy
import scipy.io as sio
import seaborn as sns

#from mpl_toolkits.axes_grid1.inset_locator import inset_axes
from svglib.svglib import svg2rlg
from reportlab.graphics import renderPDF

#Load specific variables and functions
from base import findTimeClust, find_nearest, my_smooth
from ECoG_finalFigs_cfg import *
from ECoG_base_plot import pretty_colorbar, pretty_plot
from ECoG_base_plotDecoding import pretty_decod, pretty_gat 
from ECoG_base_stats import myStats

##########################################
#Define important variables
ListSubjects = ['EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP']
#ListSubjects = ['HS', 'KJ_I', 'LJ', 'MG', 'WS', 'KR', 'AP']
ListFilenames = 'erp_100_TimDim_timeBin-100ms_nomeanSubtraction'#'erp_100_TimDim_timeBin-100ms_nomeanSubtraction'

if generalization:
	gen_filename = 'timeGen'
else:
	gen_filename = 'diag'

if 'load1' in decCond[0]:
	ListSubjects = ['EG_I', 'KJ_I', 'MG', 'WS', 'AP']

##########################################
#Initialize variables
scores = []

#Loop over conditions and subjects
for condi, cond in enumerate(decCond):
	for subi, subject in enumerate(ListSubjects):

		#Load all of the data 
		if (cond is not 'indItems') & (cond is not 'itemPos') & (cond is not 'indItems_trainCue0_testCue0') & (cond is not 'indItems_trainCue1_testCue1') & (cond is not 'indItems_trainCue0_testCue1') & (cond is not 'indItems_trainCue1_testCue0') & (cond is not 'itemPos_load1') & (cond is not 'indItems_load1'):
			if fdecoding is not 'perChannel':
				score = np.squeeze(np.load(data_path + ListFilenames + '/' + subject + '_BroadbandERP_' + cond + '_' + gen_filename + '_' + ListFilenames + '_acc' + str(acc) + '_score.npy'))
			else:
				score = np.squeeze(np.load(data_path + ListFilenames + '/' + subject + '_erp_timDim_' + cond + '_diag_' + ListFilenames + '_acc' + str(acc) + '_score.npy'))
				score = np.mean(score, axis=1)
			#y_pred = np.load(data_path + ListFilenames + '/' + subject + '_BroadbandERP_' + cond + '_' + gen_filename + '_' + ListFilenames + '_acc' + str(acc) + '_y_pred.npy', allow_pickle=True)
		elif (cond is 'indItems') | (cond is 'indItems_trainCue0_testCue0') | (cond is 'indItems_trainCue1_testCue1') | (cond is 'indItems_trainCue1_testCue0') | (cond is 'itemPos_load1') | (cond is 'indItems_load1'):
			if fdecoding is not 'perChannel':
				score = np.squeeze(np.load(data_path + ListFilenames + '/' + subject + '_BroadbandERP_' + cond + '_' + gen_filename + '_' + ListFilenames + '_acc' + str(acc) + '_average_score.npy'))
			else:
				if (cond is 'indItems') & (fmethod is 'erp_100') & (fmethod is 'erp_100_spatialPatterns'):
					if ('TimDim' not in ListFilenames):
						score = np.squeeze(np.load(data_path + ListFilenames + '/' + subject + '_erp_timDim_' + cond + '_diag_' + ListFilenames + '_acc' + str(acc) + '_average_score.npy'))
						score = np.mean(score, axis=1)
					else:
						score = np.squeeze(np.load(data_path + ListFilenames + '/forMatlab/' + subject + '_erp_timDim_' + cond + '_diag_' + ListFilenames + '_scores.npy'))
				elif (cond is 'indItems') & (fmethod is not 'erp_100') & (fmethod is 'erp_100_spatialPatterns'):
					score = np.squeeze(np.load(data_path + ListFilenames + '/' + subject + '_erp_timDim_' + cond + '_diag_' + ListFilenames + '_acc' + str(acc) + '_average_score.npy'))
					score = np.mean(score, axis=1)
		elif (cond is 'itemPos') | (cond is 'indItems_trainCue0_testCue1'):
			if fdecoding is not 'perChannel':
				score = np.mean(np.load(data_path + ListFilenames + '/' + subject + '_BroadbandERP_' + cond + '_' + gen_filename + '_' + ListFilenames + '_acc' + str(acc) + '_score.npy'), axis=0)
				score = np.squeeze(score)	#score_old = np.squeeze(np.load(data_path + ListFilenames[0] + '/orig_' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_score.npy'))
			else:
				score = np.squeeze(np.load(data_path + ListFilenames + '/' + subject + '_erp_timDim_' + cond + '_diag_' + ListFilenames + '_acc' + str(acc) + '_average_score.npy'))
				score = np.mean(score, axis=1)

		if fdecoding is not 'perChannel':
			time = np.load(data_path + ListFilenames + '/' + subject + '_BroadbandERP_' + cond + '_' + gen_filename + '_' + ListFilenames + '_acc' + str(acc) + '_time.npy')
		else:
			if (fmethod is 'erp_100') | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100') | (fmethod is 'erp_100_spatialPatterns') | (fmethod is 'HGP_100'):
				time = np.arange(-.2, 4.5, .1)
			elif (fmethod is 'probeLocked_erp_100_longEpoch') | (fmethod is 'frontal_probeLocked_erp_100_longEpoch') | (fmethod is 'temporal_probeLocked_erp_100_longEpoch') | (fmethod is 'probeLocked_erp_100_longEpoch_spatialPatterns') | (fmethod is 'probeLocked_HGP_100_longEpoch'):
				time =  np.arange(-4.5, .5, .1)
			elif (fmethod is 'respLocked_erp_100') | (fmethod is 'frontal_respLocked_erp_100') | (fmethod is 'temporal_respLocked_erp_100') | (fmethod is 'respLocked_erp_100_spatialPatterns'):
				time = np.arange(-4.0, .0, .1)

		if 'spatialPatterns' in fmethod:
			if (cond is not 'indItems') & (cond is not 'itemPos'):
				coef = np.load(data_path + ListFilenames + '/' + subject + '_BroadbandERP_' + cond + '_' + gen_filename + '_' + ListFilenames + '_acc' + str(acc) + '_coefs.npy')
			else:
				coef = np.load(data_path + ListFilenames + '/' + subject + '_BroadbandERP_' + cond + '_' + gen_filename + '_' + ListFilenames + '_acc' + str(acc) + '_average_coefs.npy')
			coef = np.squeeze(coef)

			sio.savemat(data_path + ListFilenames + '/forMatlab/' + subject + '_erp_timDim_' + cond + '_' + gen_filename + '_' + ListFilenames + '_scores.mat', mdict={'data': coef})
		
		#Include only relevant period of the trial (i.e., baseline + epoch)
		if fdecoding is not 'perChannel':
			if (ListFilenames != 'respLocked_erp_100') & (fmethod != 'frontal_respLocked_erp_100') & (fmethod != 'temporal_respLocked_erp_100') & (fmethod != 'respLocked_tfa_wavelet') & (ListFilenames != 'probeLocked_erp_100_longEpoch') & (fmethod != 'frontal_probeLocked_erp_100_longEpoch') & (fmethod != 'temporal_probeLocked_erp_100_longEpoch') & (fmethod != 'respLocked_erp_100_spatialPatterns') & (fmethod != 'probeLocked_erp_100_longEpoch_spatialPatterns') & (fmethod != 'probeLocked_HGP_100_longEpoch') & (fmethod != 'respLocked_HGP_100'):
				begin_t = find_nearest(time, bl[0])
			else:
				begin_t = find_nearest(time, trainTime[0])

			if gen_filename is 'diag':
				#score = score[:, begin_t[0] :]
				score = score[begin_t[0] :]
			else:
				score = score[begin_t[0] :, begin_t[0] :]

		#print(np.shape(score))

		scores.append(score)
		np.asarray(scores)

#Reshapes
if fdecoding is not 'perChannel':
	if gen_filename is 'diag':
		scores =  np.reshape(scores, (len(decCond), len(ListSubjects), np.shape(score)[0]))
	else:
		scores = np.reshape(scores, (len(decCond), len(ListSubjects), np.shape(score)[0], np.shape(score)[1]))
else:
	scores = np.reshape(scores, (len(decCond), len(ListSubjects), np.shape(score)[0]))

##########################################
#Plot average decoding performance
if plotAverage:
	timeBins = [[-.2, 0], [0, .5], [0.5, 1.5], [1.5, 2.5], [2.5, 4.5]]
	timeBins_titles = ['Baseline', 'Cue presentation', 'Delay 1', 'Item presentation', 'Delay 2']
	indBins = np.empty_like(timeBins)

	#Extract the relevant indices
	if fdecoding is not 'perChannel':
		time_short = time[begin_t[0] :]

	for bini, tbin in enumerate(timeBins):
		for timei, ttime in enumerate(tbin):
			tmp = time_short - ttime
			tmp_ind = np.where(np.abs(tmp) == np.min(np.abs(tmp)))
			indBins[bini, timei] = tmp_ind[0]

	#Extract diagonal
	scores_diag = []
	for condi, cond in enumerate(decCond):
		tmp = [np.diag(sc) for sc in scores[condi]]
		scores_diag.append(tmp)

	scores_diag = np.asarray(scores_diag)

	#Put everything in data frame to facilitate plotting
	df = pd.DataFrame(columns=['Subjects', 'Baseline', 'Cue presentation', 'Delay 1', 'Item presentation', 'Delay 2', 'decCond'])
	conditions = ['Train Match, Test Match', 'Train Match, Test Mismatch', 'Train Mismatch, Test Match', 'Train Mismatch, Test Mismatch']
	F_values_timeBin = np.zeros(len(indBins))
	p_values_timeBin = np.zeros(len(indBins))

	df2 = pd.DataFrame(columns=['Baseline_1', 'Baseline_2',	'Baseline_3', 'Baseline_4',	'Cue_1', 'Cue_2', 'Cue_3', 'Cue_4',	'Del1_1', 'Del1_2',	'Del1_3', 'Del1_4',	'Mem_1', 'Mem_2', 'Mem_3',	'Mem_4', 'Del2_1',	'Del2_2', 'Del2_3',	'Del2_4'])	
	
	for bini, tbin in enumerate(indBins):
		tmp = scores_diag[:, :, int(indBins[bini][0]):int(indBins[bini][1])] #shape = decCond x subjects x timebins
		tmp = np.mean(tmp, axis=2)

		for coli in np.arange(0, 4):
			if bini == 0:
				currentCol = coli
			elif bini == 1:
				currentCol = coli+4
			elif bini == 2:
				currentCol = coli+8
			elif bini == 3:
				currentCol = coli+12
			elif bini == 4:
				currentCol = coli+16
			column_name = df2.columns[currentCol]
			df2[column_name] = tmp[coli]


		#Store stats
		F_values_timeBin[bini],p_values_timeBin[bini] = scipy.f_oneway(tmp[0], tmp[1], tmp[2], tmp[3])

		tmp = np.reshape(tmp, (1, len(decCond)*len(ListSubjects)))
		tmp = np.squeeze(tmp)

		column_name = df.columns[bini+1]

		if bini == 0:
			df.Subjects = np.squeeze(np.tile(np.arange(0, len(ListSubjects), 1), (1, len(decCond))))

		df[column_name] = tmp

		if bini == 0:
			df.decCond = np.squeeze(np.tile(conditions, (1, len(ListSubjects))))

	df2.to_csv(result_path + ListFilenames + '/Stats/Group_BroadbandERP_' + cond + '_' + gen_filename + '_' + ListFilenames + '_compValues.csv')

	#Melt into long dataframe format
	df_long = pd.melt(df, id_vars=['decCond'], value_vars=['Baseline', 'Cue presentation', 'Delay 1', 'Item presentation', 'Delay 2'])

	#Plot
	print(p_values_timeBin)

	cols_tmp = sns.color_palette('Paired')
	cols = [cols_tmp[1], cols_tmp[0], cols_tmp[2], cols_tmp[3]]

	fig_group = plt.figure(figsize=(10, 5))

	ax_group = sns.boxplot(data=df_long, x='variable', y='value', hue='decCond', palette=cols, saturation=.75, fliersize=3)
	ax_group.axhline(0.5, linestyle='--', linewidth=.5, color='dimgray', zorder=-3) #indicates probe onset

	pretty_plot(ax_group)

	xticklabels = ax_group.get_xticklabels()
	ax_group.set_xticklabels(xticklabels, fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
	ax_group.set_xlabel(' ')

	if fmethod is 'frontal_erp_100':
		ax_group.set_yticks(np.linspace(.47, .53, 7))
		ax_group.set_yticklabels(['0.47', '', '', 'Chance', ' ', '',  '0.53'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
	elif fmethod is 'erp_100':
		ax_group.set_yticks(np.linspace(.47, .54, 8))
		ax_group.set_yticklabels(['0.47', '', '', 'Chance', '', '', '', '0.54'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels

	ax_group.set_ylabel('')

	ax_group.set_title('AUC', fontname=font_name, fontsize=font_size+2, fontweight='bold')

	leg_handle,leg_labels = ax_group.get_legend_handles_labels()
	ax_group.legend(handles=leg_handle[0:], labels=leg_labels[0:], prop={'family': font_name, 'size': font_size-2})

	#Save
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_StimLocked_' + gen_filename + '_' + ListFilenames + '_timeBins.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_StimLocked_' + gen_filename + '_' + ListFilenames + '_timBins.tiff',
		format = 'tiff', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames + '/Figures/Group_BroadbandERP_StimLocked_' + gen_filename + '_' + ListFilenames + '_timeBins.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames + '/Figures/Group_BroadbandERP_StimLocked_' + gen_filename + '_' + ListFilenames + '_timeBins.pdf')

	plt.show()

##########################################
#Compute stats if wanted
p_values_diag = []
p_values = []

if stats is 'permutation': 
	if gen_filename is 'diag':
		for condi, cond in enumerate(decCond):
			p_value_diag = myStats(np.array(scores)[condi, :, :, None] - chance, tail=1, permutations=n_permutations)
			#sig_diag = p_values_diag < stat_alpha

			p_values_diag.append(p_value_diag)

		np.savez(result_path + ListFilenames + '/Stats/Group_BroadbandERP_' + cond + '_' + gen_filename + '_' + ListFilenames + '_stats.npz', p_values_diag)
	else:
		for condi, cond in enumerate(decCond):
			tmp = [np.diag(sc) for sc in scores[condi]]
			p_value = myStats(np.array(scores[condi]) - chance, tail=tail, permutations=n_permutations)
			p_value_diag = myStats(np.array(tmp)[:, :, None] - chance, tail=1, permutations=n_permutations)

			p_values_diag.append(p_value_diag)
			p_values.append(p_value)

			#sig = p_values < stat_alpha
			#sig_diag = p_values_diag < stat_alpha

			del tmp

		np.savez(result_path + ListFilenames + '/Stats/Group_BroadbandERP_' + cond + '_' + gen_filename + '_' + ListFilenames + '_stats.npz', p_value, p_values_diag)
elif stats is 'permutation_load':
	for condi, cond in enumerate(decCond):
		tmp = np.load(result_path + ListFilenames + '/Stats/Group_BroadbandERP_' + cond + '_' + gen_filename + '_' + ListFilenames + '_stats.npz')
		p_value = tmp['arr_0']
		p_value_diag = tmp['arr_1']

		p_values_diag.append(p_value_diag)
		p_values.append(p_value)

##########################################
#Smooth if need be (for visualization only)
scores_smooth = np.empty_like(scores)
if smoothWindow > 0:
	for condi, cond in enumerate(decCond):
		scores_smooth[condi] = [my_smooth(sc, smoothWindow) for sc in scores[condi]]
else:
	scores_smooth = scores	

##########################################
#Plot all conditions seperately as subplot & retrieve the necessary info for the stats
if fdecoding is not 'perChannel':
	time_short = time[begin_t[0] :]
else:
	time_short = time

sig_times = []
peaks = []
peaks_time = []
peaks_sem = []
peaks_sig = []

if (decCond[0] is 'cue') | (fdecoding is 'perChannel') | (decCond[0] is 'cue_load1'):
	fig_group, ax_group = plt.subplots(len(decCond), 1, sharey=False, figsize=[5, 10])
else:
	fig_group, ax_group = plt.subplots(2, 2, sharey=False, figsize=[10, 5])

for condi, cond in enumerate(decCond):
	if (decCond[0] is not 'cue') & (decCond[0] is not 'cue_load1') & (fdecoding is not 'perChannel'):
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
	#Significant time windows & clusters
	sig_time = (time_short[p_values_diag[condi] < stat_alpha])
	sig_time_indices = p_values_diag[condi] < stat_alpha

	sig_times.append(sig_time)

	if sig_time.size > 0:
		onset_time, offset_time = findTimeClust(sig_times[condi])
		print (onset_time)

		#Peak decoding 
		#peak = np.max(np.mean([np.diag(sc) for sc in scores[condi]], axis=0))
		#peak_time = np.where((np.mean([np.diag(sc) for sc in scores[condi]], axis=0)) == np.max(np.mean([np.diag(sc) for sc in scores[condi]], axis=0)))
		#peak_sem = scipy.sem(np.asarray([np.diag(sc) for sc in scores[condi]])[:, peak_time[0][0]])
		#peak_sig = p_values_diag[condi][peak_time[0][0]]
		
		peak_tmp = (np.mean([np.diag(sc) for sc in scores[condi]], axis=0))
		peak = np.max(peak_tmp[sig_time_indices])

		peak_time = np.where((np.mean([np.diag(sc) for sc in scores[condi]], axis=0)) == np.max(peak_tmp[sig_time_indices]))
		peak_sem = scipy.sem(np.asarray([np.diag(sc) for sc in scores[condi]])[:, peak_time[0][0]])
		peak_sig = p_values_diag[condi][peak_time[0][0]]

		peaks.append(peak)
		peaks_time.append(time_short[peak_time[0][0]])
		peaks_sem.append(peak_sem)
		peaks_sig.append(peak_sig)

	#Save necessary info in one convenient file
	if sig_time.size > 0:
		if isinstance(onset_time, np.floating):
			df_tmp = pd.DataFrame([[onset_time, offset_time]], columns=['Onset', 'Offset'])
			df_tmp2 = pd.DataFrame([[peak, time_short[peak_time[0][0]], peak_sem, peak_sig]], columns=['PeakVal', 'PeakTime', 'PeakSem', 'PeakSig'])
		else:
			df_tmp = pd.DataFrame(np.transpose([onset_time, offset_time]), columns=['Onset', 'Offset'])
			df_tmp2 = pd.DataFrame([[peak, time_short[peak_time[0][0]], peak_sem, peak_sig]], columns=['PeakVal', 'PeakTime', 'PeakSem', 'PeakSig'])

		df = pd.concat([df_tmp, df_tmp2], ignore_index=True, axis=0)
		df.to_csv(result_path + ListFilenames + '/Stats/Group_BroadbandERP_' + cond + '_' + gen_filename + '_' + ListFilenames + '_statValues.csv')

		del(onset_time, offset_time)

	#Plot
	if ((decCond[0] == 'cue') & (fdecoding is not 'perChannel')) | ((decCond[0] == 'cue_load1') & (fdecoding is not 'perChannel')):
		if ('spatialPatterns' in fmethod) | (decCond[0] is 'cue_load1'):
			dat2plot = scores_smooth[condi]
		else:
			dat2plot = [np.diag(sc) for sc in scores_smooth[condi]]
		pretty_decod(np.asarray(dat2plot), times=time[begin_t[0] :], ax=ax_group[condi], color=line_color[condi], sig=p_values_diag[condi] < stat_alpha, chance=chance,
			alpha=1, fill=True, thickness=0)
	elif (fdecoding is 'perChannel'):
		pretty_decod(np.asarray(scores_smooth[condi]), times=time, ax=ax_group[condi], color=line_color[condi], sig=p_values_diag[condi]<stat_alpha, chance=chance,
			alpha=1, fill=True, thickness=0)
	else:
		pretty_decod(np.asarray([np.diag(sc) for sc in scores_smooth[condi]]), times=time[begin_t[0] :], ax=ax_group[ax_tmp1, ax_tmp2], color=line_color[condi], sig=p_values_diag[condi] < stat_alpha, chance=chance,
			alpha=1, fill=True, thickness=0)

	#Add event markers
	if (fmethod is 'erp_100') | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100') | (fmethod is 'erp_100_spatialPatterns') | (fmethod is 'HGP_100'):
		if (decCond[0] == 'cue') | (fdecoding is 'perChannel') | (decCond[0] == 'cue_load1'):
			ax_group[condi].axvline(1.500, color='dimgray', zorder=-3) #indicates item onset
		else:
			ax_group[ax_tmp1, ax_tmp2].axvline(1.500, color='dimgray', zorder=-3) #indicates item onset

	elif (fmethod is 'probeLocked_erp_100_longEpoch') | (fmethod is 'frontal_probeLocked_erp_100_longEpoch') | (fmethod is 'temporal_probeLocked_erp_100_longEpoch') | (fmethod is 'probeLocked_erp_100_longEpoch_spatialPatterns') | (fmethod is 'probeLocked_HGP_100_longEpoch'):
		ax_group[condi].axvline(0, color='dimgray', zorder=-3) #indicates probe onset
		ax_group[condi].axvline(-3.0, color='dimgray', zorder=-3) #indicates item onset
		ax_group[condi].axvline(-4.5, color='dimgray', zorder=-3) #indicates cue onset

	if (decCond[0] == 'cue') | (fdecoding is 'perChannel') | (decCond[0] == 'cue_load1'):
		if condi == 0:
			ax_group[condi].set_ylabel('AUC', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
		else:
			ax_group[condi].set_ylabel('')
	else:
		if (condi == 0) | (condi == 2):
			ax_group[ax_tmp1, ax_tmp2].set_ylabel('AUC', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
		else:
			ax_group[ax_tmp1, ax_tmp2].set_ylabel('')

	if (decCond[0] == 'cue') | (fdecoding is 'perChannel') | (decCond[0] == 'cue_load1'):
		if (fmethod is 'erp_100') | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100') | (fmethod is 'erp_100_spatialPatterns') | (fmethod is 'HGP_100'):	
			if condi < len(decCond)-1:
				ax_group[condi].set_xticks(np.arange(0., 4.3, .5)), 
				ax_group[condi].set_xticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[condi].set_xlabel('')
			else:
				ax_group[condi].set_xticks(np.arange(0., 4.3, .5)), 
				ax_group[condi].set_xticklabels(['Cue', '0.5', '1.0', 'Item', '2.0', '2.5', '3.0', '3.5', '4.0'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[condi].set_xlabel('Time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
		elif (fmethod is 'respLocked_erp_100') | (fmethod is 'frontal_respLocked_erp_100') | (fmethod is 'temporal_respLocked_erp_100') | (fmethod is 'respLocked_erp_100_spatialPatterns') | (fmethod is 'respLocked_HGP_100'):
			if condi < len(decCond)-1:
				ax_group[condi].set_xticks(np.arange(-3.5, -.35, .5)), 
				ax_group[condi].set_xticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[condi].set_xlabel('')
			else:
				ax_group[condi].set_xticks(np.arange(-3.5, -.35, .5)), 
				ax_group[condi].set_xticklabels(['-3.5', '-3.0', '-2.5', '-2.0', '-1.5', '-1.0', '-0.5'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[condi].set_xlabel('Time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
		elif (fmethod is 'probeLocked_erp_100_longEpoch') | (fmethod is 'frontal_probeLocked_erp_100_longEpoch') | (fmethod is 'temporal_probeLocked_erp_100_longEpoch') | (fmethod is 'probeLocked_erp_100_longEpoch_spatialPatterns') | (fmethod is 'probeLocked_HGP_100_longEpoch'):
			if condi < len(decCond)-1:
				ax_group[condi].set_xticks(np.arange(-4.5, .5, .5)), 
				ax_group[condi].set_xticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[condi].set_xlabel('')
			else:
				ax_group[condi].set_xticks(np.arange(-4.5, .5, .5)), 
				ax_group[condi].set_xticklabels(['Cue', '-4.0', '-3.5', 'Item', '-2.5', '-2.0', '-1.5', '-1.0', '-0.5', 'Probe', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[condi].set_xlabel('Time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
	else:
		if (fmethod is 'erp_100') | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100') | (fmethod is 'HGP_100'):	
			if (condi == 0) | (condi == 1):
				ax_group[ax_tmp1, ax_tmp2].set_xticks(np.arange(0., 4.3, .5)), 
				ax_group[ax_tmp1, ax_tmp2].set_xticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[ax_tmp1, ax_tmp2].set_xlabel('')
			else:
				ax_group[ax_tmp1, ax_tmp2].set_xticks(np.arange(0., 4.3, .5)), 
				ax_group[ax_tmp1, ax_tmp2].set_xticklabels(['Cue', '0.5', '1.0', 'Item', '2.0', '2.5', '3.0', '3.5', '4.0'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
				ax_group[ax_tmp1, ax_tmp2].set_xlabel('Time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)


	#Titles
	if (decCond[0] == 'cue') | (fdecoding is 'perChannel') | (decCond[0] == 'cue_load1'):
		ax_group[condi].set_title(figTitles[condi], fontname=font_name, fontsize=font_size+2, fontweight='bold')
	#else:
		#if (condi == 0) | (condi == 1):
			#ax_group[ax_tmp1, ax_tmp2].set_title(figTitles[condi], fontname=font_name, fontsize=font_size+2, fontweight='bold')
		#elif (condi == 2) | (condi == 3):
			#ax_group[ax_tmp1, ax_tmp2].set_ylabel(figTitles[condi], fontname=font_name, fontsize=font_size+2, fontweight='bold')

	fig_group.tight_layout()

#Save
if (fmethod is 'erp_100')  | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100') | (fmethod is 'erp_100_spatialPatterns') | (fmethod is 'HGP_100'):
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_StimLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames + '/Figures/Group_BroadbandERP_StimLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames + '/Figures/Group_BroadbandERP_StimLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.pdf')
elif (fmethod is 'respLocked_erp_100') | (fmethod is 'frontal_respLocked_erp_100') | (fmethod is 'temporal_respLocked_erp_100') | (fmethod is 'respLocked_erp_100_spatialPatterns') | (fmethod is 'respLocked_HGP_100'):
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_RespLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames + '/Figures/Group_BroadbandERP_RespLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames + '/Figures/Group_BroadbandERP_RespLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.pdf')
elif (fmethod is 'probeLocked_erp_100_longEpoch') | (fmethod is 'frontal_probeLocked_erp_100_longEpoch') | (fmethod is 'temporal_probeLocked_erp_100_longEpoch') | (fmethod is 'probeLocked_erp_100_longEpoch_spatialPatterns') | (fmethod is 'probeLocked_HGP_100_longEpoch'):
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_ProbeLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames + '/Figures/Group_BroadbandERP_ProbeLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames + '/Figures/Group_BroadbandERP_ProbeLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.pdf')

plt.show()

##########################################
#Plot all conditions seperately as subplot & retrieve the necessary info for the stats
if decCond[0] == 'cue':
	fig_group, ax_group = plt.subplots(1, len(decCond), sharey=False, figsize=[20, 5])
else:
	fig_group, ax_group = plt.subplots(2, 2, sharey=False, figsize=[8, 4])

for condi, cond in enumerate(decCond):

	if decCond[0] is not 'cue':
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

	scores_m = np.mean(scores_smooth[condi], axis=0)
	sig = p_values[condi] < stat_alpha

	if maskSig:
		#Mask array with significance < stats_alpha
		scores_m[~sig] = np.nan #decoding score is bounded between 0/1

	if maskThresh:
		scores_m[scores_m <= chance] = np.nan

	if (fmethod is 'erp_100') | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100') | (fmethod is 'erp_100_spatialPatterns') | (fmethod is 'HGP_100'):
		if decCond[0] == 'cue':
			_, im = pretty_gat(scores_m, times=time[begin_t[0] :], ax=ax_group[condi], cmap = map_color[condi], chance=chance, clim =[chance, np.nanmax(scores_m)], sig=None, colorbar=None, 
							xlabel='Test times (in s)', ylabel='Train times (in s)', sfreq=sfreq, diagonal=None, test_times=time[begin_t[0] :], classLines=None, classColors=None, contourPlot=None, steps=None)
		else:
			_, im = pretty_gat(scores_m, times=time[begin_t[0] :], ax=ax_group[ax_tmp1, ax_tmp2], cmap = map_color[condi], chance=chance, clim =[chance, np.nanmax(scores_m)], sig=None, colorbar=None, 
							xlabel='Test times (in s)', ylabel='Train times (in s)', sfreq=sfreq, diagonal=None, test_times=time[begin_t[0] :], classLines=None, classColors=None, contourPlot=None, steps=None)
	elif (fmethod is 'respLocked_erp_100') | (fmethod is 'frontal_respLocked_erp_100') | (fmethod is 'temporal_respLocked_erp_100') | (fmethod is 'probeLocked_erp_100_longEpoch') | (fmethod is 'frontal_probeLocked_erp_100_longEpoch') | (fmethod is 'temporal_probeLocked_erp_100_longEpoch') | (fmethod is 'respLocked_erp_100_spatialPatterns') | (fmethod is 'probeLocked_HGP_100_longEpoch') | (fmethod is 'respLocked_HGP_100'):
		_, im = pretty_gat(scores_m, times=time[begin_t[0] :], ax=ax_group[condi], cmap = map_color[condi], chance=chance, clim =[chance, np.nanmax(scores_m)], sig=None, colorbar=None, 
						xlabel='Test times (in s)', ylabel='Train times (in s)', sfreq=sfreq, diagonal=None, test_times=time[begin_t[0] :], classLines=None, classColors=None, contourPlot=None, steps=None, 
						markOnset=False)

	#Colorbar
	#axins = inset_axes(ax_group[condi], width=.5, height=.5, loc = 'lower right')
	shiftX = 0#.003
	shiftY = 0 #.099
	
	if len(np.unique(sig)) == 2:
		if decCond[0] == 'cue':
			cb = pretty_colorbar(im, ax=ax_group[condi], ticks=[np.nanmax(scores_m)],
        		ticklabels=['%.2f' % np.nanmax(scores_m)], shrink=.1, aspect=10, pad=0)
		else:
			cb = pretty_colorbar(im, ax=ax_group[ax_tmp1, ax_tmp2], ticks=[np.nanmax(scores_m)],
        		ticklabels=['%.2f' % np.nanmax(scores_m)], shrink=.1, aspect=10, pad=0)
		cb_pos = cb.ax.get_position()
		cb.ax.set_yticklabels(['%.2f' % np.nanmax(scores_m)], fontname=font_name, fontsize=font_size, fontweight=font_weight)
	elif len(np.unique(sig)) == 1:
		if decCond[0] == 'cue':
			cb = pretty_colorbar(im, ax=ax_group[condi], ticks=[.1],
        		ticklabels=['0.57'], shrink=.1, aspect=10, pad=0)
		else:
			cb = pretty_colorbar(im, ax=ax_group[ax_tmp1, ax_tmp2], ticks=[.1],
        		ticklabels=['0.57'], shrink=.1, aspect=10, pad=0)
		cb_pos = cb.ax.get_position()
		cb.ax.set_yticklabels(['0.57'], fontname=font_name, fontsize=font_size, fontweight=font_weight, color='white')
	cb.ax.set_position([cb_pos.x0--shiftX, cb_pos.y0--shiftY, cb_pos.width, cb_pos.height])
	

	#Add event markers
	if (fmethod is 'erp_100') | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100') | (fmethod is 'erp_100_spatialPatterns') | (fmethod is 'HGP_100'):
		if decCond[0] == 'cue':
			ax_group[condi].axhline(1.500, color='dimgray', zorder=-3) #indicates item onset
			ax_group[condi].axvline(1.500, color='dimgray', zorder=-3) #indicates item onset
		else:
			ax_group[ax_tmp1, ax_tmp2].axhline(1.500, color='dimgray', zorder=-3) #indicates item onset
			ax_group[ax_tmp1, ax_tmp2].axvline(1.500, color='dimgray', zorder=-3) #indicates item onset
	elif (fmethod is 'probeLocked_erp_100_longEpoch') | (fmethod is 'frontal_probeLocked_erp_100_longEpoch') | (fmethod is 'temporal_probeLocked_erp_100_longEpoch') | (fmethod is 'probeLocked_erp_100_longEpoch_spatialPatterns') | (fmethod is 'probeLocked_HGP_100_longEpoch'):
		ax_group[condi].axvline(0, color='dimgray', zorder=-3) #indicates probe onset
		ax_group[condi].axhline(0, color='dimgray', zorder=-3) #indicates probe onset
		ax_group[condi].axvline(-3.0, color='dimgray', zorder=-3) #indicates item onset
		ax_group[condi].axhline(-3.0, color='dimgray', zorder=-3) #indicates item onset
		ax_group[condi].axvline(-4.5, color='dimgray', zorder=-3) #indicates cue onset
		ax_group[condi].axhline(-4.5, color='dimgray', zorder=-3) #indicates cue onset


	if decCond[0] == 'cue':
		if (fmethod is 'erp_100') | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100') | (fmethod is 'erp_100_spatialPatterns') | (fmethod is 'HGP_100'):
			if condi == 0:
				ax_group[condi].set_ylabel('Train time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
				ax_group[condi].set_yticks(np.arange(0., 4.3, .5)), 
				ax_group[condi].set_yticklabels(['Cue', ' ', ' ', 'Item', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
			else:
				ax_group[condi].set_ylabel('')
				ax_group[condi].set_yticks(np.arange(0., 4.3, .5)), 
				ax_group[condi].set_yticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels

			ax_group[condi].set_xlabel('Test time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
			ax_group[condi].set_xticks(np.arange(0., 4.3, .5)), 
			ax_group[condi].set_xticklabels(['Cue', ' ', ' ', 'Item', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
		elif (fmethod is 'respLocked_erp_100') | (fmethod is 'frontal_respLocked_erp_100') | (fmethod is 'temporal_respLocked_erp_100') | (fmethod is 'respLocked_erp_100_spatialPatterns') | (fmethod is 'respLocked_HGP_100'):
			if condi == 0:
				ax_group[condi].set_ylabel('Train time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
				ax_group[condi].set_yticks(np.arange(-3.5, 0, .5)), 
				ax_group[condi].set_yticklabels(['-3.5', ' ', ' ', ' ', ' ', ' ', '-0.5', 'R'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
			else:
				ax_group[condi].set_ylabel('')
				ax_group[condi].set_yticks(np.arange(-3.5, 0, .5)), 
				ax_group[condi].set_yticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels

			ax_group[condi].set_xlabel('Test time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
			ax_group[condi].set_xticks(np.arange(-3.5, 0, .5)), 
			ax_group[condi].set_xticklabels(['-3.5', ' ', ' ', ' ', ' ', ' ', '-0.5', 'R'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
	
		elif (fmethod is 'probeLocked_erp_100_longEpoch') | (fmethod is 'frontal_probeLocked_erp_100_longEpoch') | (fmethod is 'temporal_probeLocked_erp_100_longEpoch') | (fmethod is 'probeLocked_erp_100_longEpoch_spatialPatterns') | (fmethod is 'probeLocked_HGP_100_longEpoch'):
			if condi == 0:
				ax_group[condi].set_ylabel('Train time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
				ax_group[condi].set_yticks(np.arange(-4.5, .5, .5)), 
				ax_group[condi].set_yticklabels(['Cue', ' ', ' ', 'Item', ' ', ' ', ' ', ' ', ' ', 'Probe'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
			else:
				ax_group[condi].set_ylabel('')
				ax_group[condi].set_yticks(np.arange(-4.5, .5, .5)), 
				ax_group[condi].set_yticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
		
			ax_group[condi].set_xlabel('Test time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
			ax_group[condi].set_xticks(np.arange(-4.5, .5, .5)), 
			ax_group[condi].set_xticklabels(['Cue', ' ', ' ', 'Item', ' ', ' ', ' ', ' ', ' ', 'Probe'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
	else:
		if (fmethod is 'erp_100') | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100')  | (fmethod is 'erp_100_spatialPatterns'):
			if (condi == 0) | (condi == 2):
				ax_group[ax_tmp1, ax_tmp2].set_ylabel('Train time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
				ax_group[ax_tmp1, ax_tmp2].set_yticks(np.arange(0., 4.3, .5)), 
				ax_group[ax_tmp1, ax_tmp2].set_yticklabels(['Cue', ' ', ' ', 'Item', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
			else:
				ax_group[ax_tmp1, ax_tmp2].set_ylabel('')
				ax_group[ax_tmp1, ax_tmp2].set_yticks(np.arange(0., 4.3, .5)), 
				ax_group[ax_tmp1, ax_tmp2].set_yticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels

			if (condi == 2) | (condi == 3):
				ax_group[ax_tmp1, ax_tmp2].set_xlabel('Test time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
				ax_group[ax_tmp1, ax_tmp2].set_xticks(np.arange(0., 4.3, .5)), 
				ax_group[ax_tmp1, ax_tmp2].set_xticklabels(['Cue', ' ', ' ', 'Item', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
			else:
				ax_group[ax_tmp1, ax_tmp2].set_xticks(np.arange(0., 4.3, .5)), 
				ax_group[ax_tmp1, ax_tmp2].set_xticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick 
	
	#Titles
	if decCond[0] == 'cue':
		ax_group[condi].set_title(figTitles[condi], fontname=font_name, fontsize=font_size+2, fontweight='bold')
	else:
		if (condi == 0) | (condi == 1):
			ax_group[ax_tmp1, ax_tmp2].set_title(figTitles[condi], fontname=font_name, fontsize=font_size+2, fontweight='bold')

#Shift positions
'''
if fmethod is 'respLocked_erp_100':
	ax_group[0].set_position([0.125, 0.3206194642857143, 0.09410714285714283, 0.3487610714285714])
	ax_group[1].set_position([0.2578571428571429, 0.3206194642857143, 0.09410714285714283, 0.3487610714285714])
	ax_group[2].set_position([0.39071428571428574, 0.3206194642857143, 0.5235714285714286, 0.3206194642857141])
	ax_group[3].set_position([0.5235714285714286, 0.3206194642857141, 0.5235714285714286, 0.3206194642857141])
	ax_group[4].set_position([0.6564285714285715, 0.3206194642857141, 0.5235714285714286, 0.3206194642857141])
	'''

#fig_group.tight_layout()


#Save
if (fmethod is 'erp_100') | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100') | (fmethod is 'erp_100_spatialPatterns') | (fmethod is 'HGP_100'):
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_StimLocked_' + gen_filename + '_' + ListFilenames + '_gat.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_StimLocked_' + gen_filename + '_' + ListFilenames + '_gat.tiff',
		format = 'tiff', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames + '/Figures/Group_BroadbandERP_StimLocked_' + gen_filename + '_' + ListFilenames + '_gat.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames + '/Figures/Group_BroadbandERP_StimLocked_' + gen_filename + '_' + ListFilenames + '_gat.pdf')
elif (fmethod is 'respLocked_erp_100') | (fmethod is 'frontal_respLocked_erp_100') | (fmethod is 'temporal_respLocked_erp_100') | (fmethod is 'respLocked_erp_100_spatialPatterns') | (fmethod is 'respLocked_HGP_100'):
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_RespLocked_' + gen_filename + '_' + ListFilenames + '_gat.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_RespLocked_' + gen_filename + '_' + ListFilenames + '_gat.tiff',
		format = 'tiff', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames + '/Figures/Group_BroadbandERP_RespLocked_' + gen_filename + '_' + ListFilenames + '_gat.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames + '/Figures/Group_BroadbandERP_RespLocked_' + gen_filename + '_' + ListFilenames + '_gat.pdf')
elif (fmethod is 'probeLocked_erp_100_longEpoch') | (fmethod is 'frontal_probeLocked_erp_100_longEpoch') | (fmethod is 'temporal_probeLocked_erp_100_longEpoch') | (fmethod is 'probeLocked_erp_100_longEpoch_spatialPatterns') | (fmethod is 'probeLocked_HGP_100_longEpoch'):
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_ProbeLocked_' + gen_filename + '_' + ListFilenames + '_gat.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_ProbeLocked_' + gen_filename + '_' + ListFilenames + '_gat.tiff',
		format = 'tiff', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames + '/Figures/Group_BroadbandERP_ProbeLocked_' + gen_filename + '_' + ListFilenames + '_gat.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames + '/Figures/Group_BroadbandERP_ProbeLocked_' + gen_filename + '_' + ListFilenames + '_gat.pdf')

plt.show()


