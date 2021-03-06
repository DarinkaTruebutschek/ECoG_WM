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

#from mpl_toolkits.axes_grid1.inset_locator import inset_axes
from svglib.svglib import svg2rlg
from reportlab.graphics import renderPDF

#Load specific variables and functions
from base import findTimeClust, find_nearest, my_smooth
from ECoG_finalFigs_cfg import *
from ECoG_base_plot import pretty_colorbar
from ECoG_base_plotDecoding import pretty_decod, pretty_gat, pretty_plot 
from ECoG_base_stats import myStats

##########################################
#Define important variables
ListSubjects = ['EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'KR', 'AS', 'AP']
ListFilenames = 'tfa_wavelet_final'

if generalization:
	gen_filename = 'timeGen'
else:
	gen_filename = 'diag'

##########################################
#Initialize variables
scores = []

#Loop over conditions and subjects
for condi, cond in enumerate(decCond):
	for subi, subject in enumerate(ListSubjects):

		#Load all of the data 
		if (cond is not 'indItems') & (cond is not 'itemPos') & (cond is not 'indItems_trainCue0_testCue0') & (cond is not 'indItems_trainCue1_testCue1') & (cond is not 'indItems_trainCue0_testCue1') & (cond is not 'indItems_trainCue1_testCue0'):
			score = np.squeeze(np.load(data_path + ListFilenames + '/' + subject + '_SpecPat_' + cond + '_' + gen_filename + '_' + ListFilenames + '_acc' + str(acc) + '_score.npy'))
			#y_pred = np.load(data_path + ListFilenames + '/' + subject + '_BroadbandERP_' + cond + '_' + gen_filename + '_' + ListFilenames + '_acc' + str(acc) + '_y_pred.npy', allow_pickle=True)
		elif (cond is 'indItems') | (cond is 'itemPos') | (cond is 'indItems_trainCue0_testCue0') | (cond is 'indItems_trainCue1_testCue1') | (cond is 'indItems_trainCue1_testCue0'):
			score = np.squeeze(np.load(data_path + ListFilenames + '/' + subject + '_SpecPat_' + cond + '_' + gen_filename + '_' + ListFilenames + '_acc' + str(acc) + '_average_score.npy'))
		elif (cond is 'indItems_trainCue0_testCue1'):
			score = np.mean(np.load(data_path + ListFilenames + '/' + subject + '_SpecPat_' + cond + '_' + gen_filename + '_' + ListFilenames + '_acc' + str(acc) + '_score.npy'), axis=0)
			score = np.squeeze(score)	#score_old = np.squeeze(np.load(data_path + ListFilenames[0] + '/orig_' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_acc' + str(acc) + '_score.npy'))
		
		time = np.load(data_path + ListFilenames + '/' + subject + '_SpecPat_' + cond + '_' + gen_filename + '_' + ListFilenames + '_acc' + str(acc) + '_time.npy')
		
		if fmethod is 'tfa_wavelet_final':
			freq = np.load(data_path + ListFilenames + '/SpecPat_' + gen_filename + '_' + ListFilenames + '_acc' + str(acc) + '_freqs.npy')

		#Include only relevant period of the trial (i.e., baseline + epoch)
		if (ListFilenames != 'respLocked_erp_100') & (fmethod != 'respLocked_tfa_wavelet') & (ListFilenames != 'probeLocked_erp_100_longEpoch'):
			begin_t = find_nearest(time, bl[0])
		else:
			begin_t = find_nearest(time, trainTime[0])

		if gen_filename is 'diag':
			if fmethod is 'tfa_wavelet_final':
				score = score[:, begin_t[0] :]
			#elif fmethod is 'chanxfreq_tfa_wavelet_final':
				#score = [begin_t[0] :]
		else:
			score = score[begin_t[0] :, begin_t[0] :]

		scores.append(score)
		np.asarray(scores)

#Reshape
if fmethod is 'tfa_wavelet_final':
	scores = np.reshape(scores, (len(decCond), len(ListSubjects), np.shape(score)[0], np.shape(score)[1]))
elif fmethod is 'chanxfreq_tfa_wavelet_final':
	scores = np.reshape(scores, (len(decCond), len(ListSubjects), np.shape(score)[0]))

##########################################
#Compute stats if wanted
p_values_diag = []
p_values = []

if stats is 'permutation': 
	for condi, cond in enumerate(decCond):
		if gen_filename is 'diag':
			if fmethod is 'tfa_wavelet_final':
				p_value_diag = myStats(np.array(np.mean(scores, axis=3))[condi, :, :, None] - chance, tail=tail, permutations=n_permutations)
			elif fmethod is 'chanxfreq_tfa_wavelet_final':
				p_value_diag = myStats(np.array(scores[condi, :, :]) - chance, tail=tail, permutations=n_permutations)
			sig_diag = p_value_diag < stat_alpha
			p_values_diag.append(p_value_diag)

			if fmethod is 'tfa_wavelet_final':
				p_value = myStats(np.array(scores[condi]) - chance, tail=tail, permutations=n_permutations)
				sig_gen = p_value < stat_alpha
				p_values.append(p_value)
		else:
			tmp = [np.diag(sc) for sc in scores[condi]]
			p_value = myStats(np.array(scores[condi]) - chance, tail=tail, permutations=n_permutations)
			p_value_diag = myStats(np.array(tmp)[:, :, None] - chance, tail=1, permutations=n_permutations)

			p_values_diag.append(p_value_diag)
			p_values.append(p_value)

			#sig = p_values < stat_alpha
			#sig_diag = p_values_diag < stat_alpha

			del tmp

		if fmethod is 'tfa_wavelet_final':
			np.savez(result_path + ListFilenames + '/Stats/Group_SpecPat_' + cond + '_' + gen_filename + '_' + ListFilenames + '_stats.npz', p_value, p_value_diag)
		elif fmethod is 'chanxfreq_tfa_wavelet_final':
			np.savez(result_path + ListFilenames + '/Stats/Group_SpecPat_' + cond + '_' + gen_filename + '_' + ListFilenames + '_stats.npz', p_value_diag)
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
time_short = time[begin_t[0] :]

sig_times = []
peaks = []
peaks_time = []
peaks_sem = []
peaks_sig = []

fig_group, ax_group = plt.subplots(len(decCond), 1, sharey=False, figsize=[5, 10])
for condi, cond in enumerate(decCond):

	#Get stats
	#Significant time windows & clusters
	sig_time = (time_short[p_values_diag[condi] < stat_alpha])
	sig_times.append(sig_time)

	if sig_time.size > 0:
		onset_time, offset_time = findTimeClust(sig_times[condi])
		print (onset_time)

		#Peak decoding 
		if fmethod is 'chanxfreq_tfa_wavelet_final':
			peak = np.max(np.mean(scores[condi, :, :], axis=0))
			peak_time = np.where(np.mean(scores[condi, :, :], axis=0) == np.max(np.mean(scores[condi, :, :], axis=0)))
			peak_sem = scipy.sem(np.asarray(scores[condi, :, :])[:, peak_time[0][0]])
		elif fmethod is 'tfa_wavelet_final':
			peak = np.max(np.mean(np.mean(scores, axis=3)[condi, :, :], axis=0))
			peak_time = np.where((np.mean(np.mean(scores, axis=3)[condi, :, :], axis=0)) == np.max(np.mean(np.mean(scores, axis=3)[condi, :, :], axis=0)))
			peak_sem = scipy.sem(np.asarray(np.mean(scores, axis=3)[condi, :, :])[:, peak_time[0][0]])
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
		df.to_csv(result_path + ListFilenames + '/Stats/Group_SpecPats_' + cond + '_' + gen_filename + '_' + ListFilenames + '_statValues.csv')

		del(onset_time, offset_time)

	#Plot
	if fmethod is 'tfa_wavelet_final':	
		pretty_decod(np.asarray(np.mean(scores_smooth, axis=3)[condi, :, :]), times=time[begin_t[0] :], ax=ax_group[condi], color=line_color[condi], sig=p_values_diag[condi] < stat_alpha, chance=chance,
		alpha=1, fill=True, thickness=0)
	elif fmethod is 'chanxfreq_tfa_wavelet_final':
		pretty_decod(np.asarray(scores_smooth[condi, :, :]), times=time[begin_t[0] :], ax=ax_group[condi], color=line_color[condi], sig=p_values_diag[condi] < stat_alpha, chance=chance,
		alpha=1, fill=True, thickness=0)

	#Add event markers
	if (fmethod is 'tfa_wavelet_final') | (fmethod is 'chanxfreq_tfa_wavelet_final'):
		ax_group[condi].axvline(1.500, color='dimgray', zorder=-3) #indicates item onset
	elif fmethod is 'probeLocked_erp_100_longEpoch':
		ax_group[condi].axvline(0, color='dimgray', zorder=-3) #indicates probe onset
		ax_group[condi].axvline(-3.0, color='dimgray', zorder=-3) #indicates item onset
		ax_group[condi].axvline(-4.5, color='dimgray', zorder=-3) #indicates cue onset

	if condi == 0:
		ax_group[condi].set_ylabel('AUC', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
	else:
		ax_group[condi].set_ylabel('')

	if (fmethod is 'tfa_wavelet_final') | (fmethod is 'chanxfreq_tfa_wavelet_final'):	
		if condi < len(decCond)-1:
			ax_group[condi].set_xticks(np.arange(0., 4.3, .5)), 
			ax_group[condi].set_xticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
			ax_group[condi].set_xlabel('')
		else:
			ax_group[condi].set_xticks(np.arange(0., 4.3, .5)), 
			ax_group[condi].set_xticklabels(['Cue', '0.5', '1.0', 'Item', '2.0', '2.5', '3.0', '3.5', '4.0'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
			ax_group[condi].set_xlabel('Time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
	elif fmethod is 'respLocked_erp_100':
		if condi < len(decCond)-1:
			ax_group[condi].set_xticks(np.arange(-3.5, -.35, .5)), 
			ax_group[condi].set_xticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
			ax_group[condi].set_xlabel('')
		else:
			ax_group[condi].set_xticks(np.arange(-3.5, -.35, .5)), 
			ax_group[condi].set_xticklabels(['-3.5', '-3.0', '-2.5', '-2.0', '-1.5', '-1.0', '-0.5'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
			ax_group[condi].set_xlabel('Time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
	elif fmethod is 'probeLocked_erp_100_longEpoch':
		if condi < len(decCond)-1:
			ax_group[condi].set_xticks(np.arange(-4.5, .5, .5)), 
			ax_group[condi].set_xticklabels([' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
			ax_group[condi].set_xlabel('')
		else:
			ax_group[condi].set_xticks(np.arange(-4.5, .5, .5)), 
			ax_group[condi].set_xticklabels(['Cue', '-4.0', '-3.5', 'Item', '-2.5', '-2.0', '-1.5', '-1.0', '-0.5', 'Probe', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
			ax_group[condi].set_xlabel('Time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)

	#Titles
	ax_group[condi].set_title(figTitles[condi], fontname=font_name, fontsize=font_size+2, fontweight='bold')

	fig_group.tight_layout()

#Save
if (fmethod is 'tfa_wavelet_final') | (fmethod is 'chanxfreq_tfa_wavelet_final'):
	plt.savefig(result_path + ListFilenames + '/Figures/Group_SpecPat_StimLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames + '/Figures/Group_SpecPat_StimLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames + '/Figures/Group_SpecPat_StimLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.pdf')
elif fmethod is 'respLocked_erp_100':
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_RespLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames + '/Figures/Group_BroadbandERP_RespLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames + '/Figures/Group_BroadbandERP_RespLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.pdf')
elif fmethod is 'probeLocked_erp_100_longEpoch':
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_ProbeLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames + '/Figures/Group_BroadbandERP_ProbeLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames + '/Figures/Group_BroadbandERP_ProbeLocked_' + gen_filename + '_' + ListFilenames + '_decodingTimecourse.pdf')

plt.show()

##########################################
#Plot all conditions seperately as subplot & retrieve the necessary info for the stats
fig_group, ax_group = plt.subplots(1, len(decCond), sharey=False, figsize=[20, 5])

for condi, cond in enumerate(decCond):

	scores_m = np.mean(scores_smooth[condi], axis=0)
	sig = p_values[condi] < stat_alpha

	if len(np.unique(sig)) > 1: 
		if maskSig:
			#Mask array with significance < stats_alpha
			scores_m[~sig] = np.nan #decoding score is bounded between 0/1

		if maskThresh:
			scores_m[scores_m <= chance] = np.nan
	
	extent = [min(time), max(time), min(freq), max(freq)]
	clim = [chance, np.nanmax(scores_m)]
	vmin, vmax = clim
	im = ax_group[condi].matshow(np.transpose(scores_m), extent=extent, origin='lower', cmap = map_color[condi], vmin=vmin, vmax=vmax, aspect='auto')
	ax_group[condi].xaxis.set_ticks_position('bottom')
	ax_group[condi].set_xticks(time)
	ax_group[condi] = pretty_plot(ax_group[condi])

	#Colorbar
	#axins = inset_axes(ax_group[condi], width=.5, height=.5, loc = 'lower right')
	shiftX = 0#.003
	shiftY = 0 #.099

	cb = pretty_colorbar(im, ax=ax_group[condi], ticks=[np.nanmax(scores_m)],
        ticklabels=['%.2f' % np.nanmax(scores_m)], shrink=.1, aspect=10, pad=0)
	cb_pos = cb.ax.get_position()
	cb.ax.set_yticklabels(['%.2f' % np.nanmax(scores_m)], fontname=font_name, fontsize=font_size, fontweight=font_weight)
	
	'''
	if len(np.unique(sig)) == 2:
		cb = pretty_colorbar(im, ax=ax_group[condi], ticks=[np.nanmax(scores_m)],
        	ticklabels=['%.2f' % np.nanmax(scores_m)], shrink=.1, aspect=10, pad=0)
		cb_pos = cb.ax.get_position()
		cb.ax.set_yticklabels(['%.2f' % np.nanmax(scores_m)], fontname=font_name, fontsize=font_size, fontweight=font_weight)
	elif len(np.unique(sig)) == 1:
		cb = pretty_colorbar(im, ax=ax_group[condi], ticks=[.1],
        	ticklabels=['0.57'], shrink=.1, aspect=10, pad=0)
		cb_pos = cb.ax.get_position()
		cb.ax.set_yticklabels(['0.57'], fontname=font_name, fontsize=font_size, fontweight=font_weight, color='white')
	cb.ax.set_position([cb_pos.x0--shiftX, cb_pos.y0--shiftY, cb_pos.width, cb_pos.height])
	'''

	if fmethod is 'tfa_wavelet_final':
		if condi == 0:
			ax_group[condi].set_ylabel('Frequency (in Hz)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
			ax_group[condi].set_yticks(freq[0 : :3]), 
			ax_group[condi].set_yticklabels([str(freqs) for freqs in np.round(freq[0 : :3])], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
		else:
			ax_group[condi].set_ylabel('')
			ax_group[condi].set_yticks(freq[0 : :3])
			ax_group[condi].set_yticklabels('', fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
		
		ax_group[condi].set_xlabel('Test time (in s)', fontname=font_name, fontsize=font_size+2, fontweight=font_weight)
		ax_group[condi].set_xticks(np.arange(0., 4.3, .5)), 
		ax_group[condi].set_xticklabels(['Cue', ' ', ' ', 'Item', ' ', ' ', ' ', ' ', ' '], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels
	elif fmethod is 'respLocked_erp_100':
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
	
	elif fmethod is 'probeLocked_erp_100_longEpoch':
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

	#Add event markers
	ax_group[condi].axvline(0., color='dimgray') #indicates cue onset
	ax_group[condi].axvline(1.5, color='dimgray') #indicates item onset

	#Titles
	ax_group[condi].set_title(figTitles[condi], fontname=font_name, fontsize=font_size+2, fontweight='bold')


#Save
if fmethod is 'tfa_wavelet_final':
	plt.savefig(result_path + ListFilenames + '/Figures/Group_SpecPat_StimLocked_' + gen_filename + '_' + ListFilenames + '_freqxtime.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	plt.savefig(result_path + ListFilenames + '/Figures/Group_SpecPat_StimLocked_' + gen_filename + '_' + ListFilenames + '_freqxtime.tiff',
		format = 'tiff', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames + '/Figures/Group_SpecPat_StimLocked_' + gen_filename + '_' + ListFilenames + '_freqxtime.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames + '/Figures/Group_SpecPat_StimLocked_' + gen_filename + '_' + ListFilenames + '_freqxtime.pdf')
elif fmethod is 'respLocked_erp_100':
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_RespLocked_' + gen_filename + '_' + ListFilenames + '_gat.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_RespLocked_' + gen_filename + '_' + ListFilenames + '_gat.tiff',
		format = 'tiff', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames + '/Figures/Group_BroadbandERP_RespLocked_' + gen_filename + '_' + ListFilenames + '_gat.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames + '/Figures/Group_BroadbandERP_RespLocked_' + gen_filename + '_' + ListFilenames + '_gat.pdf')
elif fmethod is 'probeLocked_erp_100_longEpoch':
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_ProbeLocked_' + gen_filename + '_' + ListFilenames + '_gat.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	plt.savefig(result_path + ListFilenames + '/Figures/Group_BroadbandERP_ProbeLocked_' + gen_filename + '_' + ListFilenames + '_gat.tiff',
		format = 'tiff', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames + '/Figures/Group_BroadbandERP_ProbeLocked_' + gen_filename + '_' + ListFilenames + '_gat.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames + '/Figures/Group_BroadbandERP_ProbeLocked_' + gen_filename + '_' + ListFilenames + '_gat.pdf')

plt.show()


