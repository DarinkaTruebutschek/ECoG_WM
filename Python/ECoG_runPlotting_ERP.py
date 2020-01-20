#Purpose: This function plots the results of the decoding analysis.
#Project: ECoG
#Author: D.T.
#Date: 15 November 2019

##########################################
#Load common libraries
import matplotlib.pyplot as plt
import numpy as np
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
ListSubjects = ['EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'AS', 'AP', 'KR']
ListFilenames = ['erp']


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
	score = np.load(data_path + ListFilenames[0] + '/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_score.npy')
	time = np.load(data_path + ListFilenames[0] + '/' + subject + '_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_time.npy')

	#Include only relevant period of the trial (i.e., baseline + epoch)
	begin_t = find_nearest(time, bl[0])
	score = score[:, begin_t[0] :]

	#######First, plot individual subjects######
	print('Plotting ', subject)

	fig_diag, ax_diag = plt.subplots(1, 1, sharey=True, figsize=[10, 5])

	pretty_decod(np.mean(score, axis=0), times=time[begin_t[0] :], color=line_color[0], sig=None, chance=chance, ax=ax_diag, thickness=line_thickness)

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

	scores.append(np.mean(score, axis=0))
	np.asarray(scores)

	#Close all figures
	plt.close()

#######Then, plot group######	
print('Plotting group')

#Compute stats if wanted
if stats is 'permutation': 
	p_values = myStats(np.array(scores)[:, :, None] - chance, tail=tail, permutations=n_permutations)
	sig = p_values < stat_alpha

	np.save(result_path + ListFilenames[0] + '/Stats/Group_BroadbandERP_' + decCond + '_' + gen_filename + '_' + ListFilenames[0] + '_stats.npy', 'p_values')
else:
	sig = None 

#Preproces data if wanted
if smoothWindow > 0:
	scores_smooth = [my_smooth(sc, smoothWindow) for sc in scores]	
	scores = scores_smooth
	del scores_smooth

fig_group, ax_group = plt.subplots(1, 1, sharey=True, figsize=[10, 5])

pretty_decod(scores, times=time[begin_t[0] :], color=line_color[0], sig=sig, chance=chance, fill=True, ax=ax_group, thickness=line_thickness)

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





