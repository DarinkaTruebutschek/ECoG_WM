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
from base import my_smooth
from ECoG_plotDecoding_cfg import *
from ECoG_base_plotDecoding import pretty_decod, pretty_gat 
from ECoG_base_stats import myStats

##########################################
#Define important variables
ListSubjects = ['EG_I', 'HS', 'KJ_I', 'LJ', 'MG', 'MKL', 'SB', 'WS', 'AS', 'AP', 'HL', 'KR']
ListFreqs = [[8, 12], [13, 30], [31, 70], [71, 160]]
ListFilenames = ['alpha', 'beta', 'lowGamma', 'highGamma']

#ListSubjects = ['EG_I', 'HS']
#ListFreqs = [[8, 12]]
#ListFilenames = ['alpha']

if generalization:
	gen_filename = 'timeGen'
else:
	gen_filename = 'diag'

##########################################
#Loop over subjects and frequencies
for freqi, freq in enumerate(ListFreqs):

	#Initialize variables
	scores = []

	for subi, subject in enumerate(ListSubjects):

		#Load all of the data 
		score = np.load(data_path + ListFilenames[freqi] + '/' + subject + '_WavDec_' + decCond + '_' + gen_filename + '_' + ListFilenames[freqi] + '_score.npy')
		time = np.load(data_path + ListFilenames[freqi] + '/' + subject + '_WavDec_' + decCond + '_' + gen_filename + '_' + ListFilenames[freqi] + '_time.npy')

		#######First, plot individual subjects######
		print('Plotting ', subject, 'in frequency band: ', freq)

		fig_diag, ax_diag = plt.subplots(1, 1, sharey=True, figsize=[10, 5])

		pretty_decod(np.mean(score, axis=0), times=time, color=line_color[0], sig=None, chance=chance, ax=ax_diag, thickness=line_thickness)

		#Add relevant info
		ax_diag.axvline(1.500, color='dimgray', zorder=-3) #indicates item onset

		ax_diag.set_xticks(np.arange(0., 4.3, .5)), 
		ax_diag.set_xticklabels(['Cue', '0.5', '1.0', 'Item', '2.0', '2.5', '3.0', '3.5', '4.0'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels

		ax_diag.set_title('Average ' + ListFilenames[freqi] + ' for subject ' + subject, fontname=font_name, fontsize=font_size+2, fontweight=font_weight)

		#Save
		plt.savefig(result_path + ListFilenames[freqi] + '/Figures/' + subject + '_WavDec_' + decCond + '_' + gen_filename + '_' + ListFilenames[freqi] + '_decodingTimecourse.svg',
		 format = 'svg', dpi = 300, bbox_inches = 'tight')
		tmp = svg2rlg(result_path + ListFilenames[freqi] + '/Figures/' + subject + '_WavDec_' + decCond + '_' + gen_filename + '_' + ListFilenames[freqi] + '_decodingTimecourse.svg')
		renderPDF.drawToFile(tmp, result_path + ListFilenames[freqi] + '/Figures/' + subject + '_WavDec_' + decCond + '_' + gen_filename + '_' + ListFilenames[freqi] + '_decodingTimecourse.pdf')

		scores.append(np.mean(score, axis=0))
		np.asarray(scores)


		#Close all figures
		plt.close()

	#######Then, plot group######	
	print('Plotting group average in frequency band: ', freq)

	#Compute stats if wanted
	if stats is 'permutation': 
		p_values = myStats(np.array(scores)[:, :, None] - chance, tail=tail, permutations=n_permutations)
		sig = p_values < stat_alpha

		np.save(result_path + ListFilenames[freqi] + '/Stats/Group_WavDec_' + decCond + '_' + gen_filename + '_' + ListFilenames[freqi] + '_stats.npy', 'p_values')
	else:
		sig = None 

	#Preproces data if wanted
	if smoothWindow > 0:
		scores_smooth = [my_smooth(sc, smoothWindow) for sc in scores]	
		scores = scores_smooth
		del scores_smooth

	fig_group, ax_group = plt.subplots(1, 1, sharey=True, figsize=[10, 5])

	pretty_decod(scores, times=time, color=line_color[0], sig=sig, chance=chance, fill=True, ax=ax_group, thickness=line_thickness)

	#Add relevant info
	ax_group.axvline(1.500, color='dimgray', zorder=-3) #indicates item onset

	ax_group.set_xticks(np.arange(0., 4.3, .5)), 
	ax_group.set_xticklabels(['Cue', '0.5', '1.0', 'Item', '2.0', '2.5', '3.0', '3.5', '4.0'], fontname=font_name, fontsize=font_size, fontweight=font_weight) #set x_tick labels

	ax_group.set_title('Average ' + ListFilenames[freqi], fontname=font_name, fontsize=font_size+2, fontweight=font_weight)

	#Save
	plt.savefig(result_path + ListFilenames[freqi] + '/Figures/Group_WavDec_' + decCond + '_' + gen_filename + '_' + ListFilenames[freqi] + '_decodingTimecourse.svg',
		format = 'svg', dpi = 300, bbox_inches = 'tight')
	tmp = svg2rlg(result_path + ListFilenames[freqi] + '/Figures/Group_WavDec_' + decCond + '_' + gen_filename + '_' + ListFilenames[freqi] + '_decodingTimecourse.svg')
	renderPDF.drawToFile(tmp, result_path + ListFilenames[freqi] + '/Figures/Group_WavDec_' + decCond + '_' + gen_filename + '_' + ListFilenames[freqi] + '_decodingTimecourse.pdf')





