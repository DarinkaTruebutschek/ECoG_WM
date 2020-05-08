#Purpose: This function plots the results of the decoding analysis.
#Project: ECoG
#Author: D.T.
#Date: 15 November 2019

##########################################
#Load common libraries
import matplotlib.pyplot as plt
import numpy as np
import numpy.ma as ma
import os

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
#ListSubjects = ['EG_I', 'HS']
ListFilenames = ['erp_100']


if generalization:
	gen_filename = 'timeGen'
else:
	gen_filename = 'diag'

##########################################
#Loop over subjects 

#Initialize variables
scores = []

for subi, subject in enumerate(ListSubjects):

	#Load all of the data 
	score = np.squeeze(np.load(data_path + ListFilenames[0] + '/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_score.npy'))
	time = np.load(data_path + ListFilenames[0] + '/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_time.npy')

	#Include only relevant period of the trial (i.e., baseline + epoch)
	begin_t = find_nearest(time, bl[0])

	if gen_filename is 'diag':
		score = score[:, begin_t[0] :]
	else:
		score = score[begin_t[0] :, begin_t[0] :]

	#######First, plot decoding timecourse for individual subjects######
	print('Plotting diagonal for subject: ', subject)

	fig_diag, ax_diag = plt.subplots(1, 1, sharey=True, figsize=[10, 5])

	if gen_filename is 'diag':
		pretty_decod(np.mean(score, axis=0), times=time[begin_t[0] :], color=line_color[0], sig=None, chance=chance, ax=ax_diag, thickness=line_thickness)
	else:
		pretty_decod(np.diagonal(score), times=time[begin_t[0] :], color=line_color[0], sig=None, chance=chance, ax=ax_diag, thickness=line_thickness)

	#Add relevant info
	ax_diag.axvline(1.500, color='dimgray', zorder=-3) #indicates item onset

	ax_diag.set_xticks(np.arange(0., 4.5, .5)), 
	ax_diag.set_xticklabels(['Cue', '0.5', '1.0', 'Item', '2.0', '2.5', '3.0', '3.5', '4.0'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels

	ax_diag.set_title('Average ' + ListFilenames[0] + ' for subject ' + subject, fontname=font_name, fontsize=font_size+2, fontweight=font_weight)

	#Save
	plt.savefig(result_path + ListFilenames[0] + '/Figures/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_decodingTimecourse.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames[0] + '/Figures/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_decodingTimecourse.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames[0] + '/Figures/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_decodingTimecourse.pdf')

	#Close all figures
	#plt.close()

	#######Then, plot generalization for individual subjects######
	if gen_filename is 'timeGen':
		print('Plotting generalization for subject: ', subject)

		fig_gen, ax_gen = plt.subplots(1, 1, sharey=True, figsize=[10, 10])

		pretty_gat(score, times=time[begin_t[0] :], chance=chance, ax=ax_gen, sig=None, cmap=map_color, clim=None, colorbar=True, 
			xlabel='Test times (in s)', ylabel='Train times (in s)', sfreq=sfreq, diagonal='dimgrey', test_times=None, classLines=None, classColors=None, contourPlot=None, steps=None)

		#Add relevant info
		ax_gen.axvline(1.500, color='k') #indicates item onset
		ax_gen.axhline(1.500, color='k') #indicates item onset

		ax_gen.set_xticks(np.arange(0., 4.5, .5)), 
		ax_gen.set_xticklabels(['Cue', '0.5', '1.0', 'Item', '2.0', '2.5', '3.0', '3.5', '4.0'], fontname=font_name_gen, fontsize=font_size_gen, fontweight=font_weight_gen) #set x_tick labels

		ax_gen.set_yticks(np.arange(0., 4.5, .5)), 
		ax_gen.set_yticklabels(['Cue', '0.5', '1.0', 'Item', '2.0', '2.5', '3.0', '3.5', '4.0'], fontname=font_name_gen, fontsize=font_size_gen, fontweight=font_weight_gen) #set x_tick labels

		#Save
		plt.savefig(result_path + ListFilenames[0] + '/Figures/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_gat.svg',
			format = 'svg', dpi = 300, bbox_inches = 'tight')
		tmp = svg2rlg(result_path + ListFilenames[0] + '/Figures/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_gat.svg')
		renderPDF.drawToFile(tmp, result_path + ListFilenames[0] + '/Figures/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_gat.pdf')

	if gen_filename is 'diag':
		scores.append(np.mean(score, axis=0))
	else:
		scores.append(score)

	np.asarray(scores)

	#Close all figures
	#plt.close()

#######Then, plot group######	
scores = np.array(scores)

print('Plotting group')

#Compute stats if wanted
if stats is 'permutation': 
	if gen_filename is 'diag':
		p_values_diag = myStats(np.array(scores)[:, :, None] - chance, tail=tail, permutations=n_permutations)
		sig_diag = p_values_diag < stat_alpha
	else:
		p_values = myStats(np.array(scores) - chance, tail=tail, n_jobs=10, permutations=n_permutations)
		p_values_diag = p_values.diagonal() / 2 #to get 1-tailed significance

		sig = p_values < stat_alpha
		sig_diag = p_values_diag < stat_alpha

	np.save(result_path + ListFilenames[0] + '/Stats/Group_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_stats.npy', 'p_values')
else:
	sig = None 

#Preproces data if wanted
if smoothWindow > 0:
	scores_smooth = [my_smooth(sc, smoothWindow) for sc in scores]	
	scores = scores_smooth
	del scores_smooth

fig_group, ax_group = plt.subplots(1, 1, sharey=True, figsize=[10, 5])

if gen_filename is 'diag':
	pretty_decod(scores, times=time[begin_t[0] :], color=line_color[0], sig=sig_diag, chance=chance, fill=True, ax=ax_group, thickness=line_thickness)
else:
	pretty_decod(np.asarray([np.diag(sc) for sc in scores]), times=time[begin_t[0] :], color=line_color[0], sig=sig_diag, chance=chance, fill=True, ax=ax_group, thickness=line_thickness)

#Add relevant info
ax_group.axvline(1.500, color='dimgray', zorder=-3) #indicates item onset

ax_group.set_xticks(np.arange(0., 4.5, .5)), 
ax_group.set_xticklabels(['Cue', '0.5', '1.0', 'Item', '2.0', '2.5', '3.0', '3.5', '4.0'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels

ax_group.set_title('Average ' + ListFilenames[0], fontname=font_name, fontsize=font_size+2, fontweight=font_weight)

#Save
plt.savefig(result_path + ListFilenames[0] + '/Figures/Group_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_decodingTimecourse.svg',
	format = 'svg', dpi = 300, bbox_inches = 'tight')
tmp = svg2rlg(result_path + ListFilenames[0] + '/Figures/Group_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_decodingTimecourse.svg')
renderPDF.drawToFile(tmp, result_path + ListFilenames[0] + '/Figures/Group_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_decodingTimecourse.pdf')

if gen_filename is 'timeGen':
	fig_group_gen, ax_group_gen = plt.subplots(1, 1, sharey=True, figsize=[10, 10])

	scores_m = np.mean(scores, axis=0)

	if maskSig:
		#Mask array with significance < stats_alpha
		scores_m[~sig] = -300 #decoding score is bounded between 0/1
		scores_m = np.ma.masked_where(scores_m == -300, scores_m)

		#Set color scale to just one value (such that the entire figure will be plotted in that color)
		for coli, col in enumerate(map_color.colors):
			map_color.colors[coli] = map_color.colors[0]

		pretty_gat(scores_m, times=time[begin_t[0] :], chance=chance, ax=ax_group_gen, sig=None, cmap=map_color, clim=None, colorbar=None, 
			xlabel='Test times (in s)', ylabel='Train times (in s)', sfreq=sfreq, diagonal='dimgrey', test_times=None, classLines=None, classColors=None, contourPlot=None, steps=None)
	else:
		range_min = chance+.001
		range_max = np.max(np.mean(scores, axis=0))
		contour_steps = np.linspace(range_min, range_max, 10)
		
		pretty_gat(scores_m, times=time[begin_t[0] :], chance=chance, ax=ax_group_gen, sig=sig, cmap=map_color, clim=None, colorbar=None, 
			xlabel='Test times (in s)', ylabel='Train times (in s)', sfreq=sfreq, diagonal='dimgrey', test_times=None, classLines=None, classColors=None, contourPlot=True, steps=contour_steps)

	#Add relevant info
	ax_group_gen.axvline(1.500, color='k') #indicates item onset
	ax_group_gen.axhline(1.500, color='k') #indicates item onset

	ax_group_gen.set_xticks(np.arange(0., 4.5, .5)), 
	ax_group_gen.set_xticklabels(['Cue', '0.5', '1.0', 'Item', '2.0', '2.5', '3.0', '3.5', '4.0'], fontname=font_name_gen, fontsize=font_size_gen, fontweight=font_weight_gen) #set x_tick labels

	ax_group_gen.set_yticks(np.arange(0., 4.5, .5)), 
	ax_group_gen.set_yticklabels(['Cue', '0.5', '1.0', 'Item', '2.0', '2.5', '3.0', '3.5', '4.0'], fontname=font_name_gen, fontsize=font_size_gen, fontweight=font_weight_gen) #set x_tick labels

	#Save
	plt.savefig(result_path + ListFilenames[0] + '/Figures/Group_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_gat.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames[0] + '/Figures/Group_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_gat.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames[0] + '/Figures/Group_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_gat.pdf')





