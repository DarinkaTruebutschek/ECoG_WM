###Purpose: This file contains all of the parameters to be used for plotting the final figures.
###Project: ECoG_WM
###Author: D.T.
###Date: 01 December 2020

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import brewer2mpl

from matplotlib.colors import ListedColormap

##########################################
#Paths
wkdir = '/media/darinka/Data0/iEEG/'
behavior_path = wkdir + 'Results/Behavior/'
data_path = wkdir + 'Results/Decoding/'
result_path = wkdir + 'Results/Decoding/'
script_path = wkdir + 'ECoG_WM/Python/'

##########################################
#Necessary parameters
fmethod = 'erp_100_spatialPatterns' #'chanxfreq_tfa_wavelet_final'
fdecoding = False #'perChannel'
plotAverage = 0 #plot average decoding performance or not?

##########################################
#Preprocessing
if (fmethod is 'tfa_wavelet_final_corrected') | (fmethod is 'respLocked_tfa_wavelet') | (fmethod is 'chanxfreq_tfa_wavelet_final') | (fmethod is 'chanxfreq_tfa_wavelet_final_corrected'):
	bl = [-.14, 0]
elif (fmethod is 'erp') | (fmethod is 'erp_100') | (fmethod is 'tfa_wavelet_final') | (fmethod is 'probeLocked_erp_100_longEpoch') | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100') | (fmethod is 'temporal_probeLocked_erp_100_longEpoch') | (fmethod is 'temporal_respLocked_erp_100') | (fmethod is 'erp_100_spatialPatterns'):
	bl = [-.2, 0]

blc = 0 #baseline correction or not?

##########################################
#Inclusion parameters
acc = 1 #0 = include both correct and incorrect trials, 1 = include only correct trials

##########################################
#Decoding
decCond = ['cue', 'itemPos', 'indItems', 'load', 'probeID', 'probe', 'buttonPress'] # 'itemPos', indItems', 'cue', 'load
figTitles = ['Task', 'Item position', 'Item identity', 'Item load', 'Probe identity', 'Probe category', 'Motor response']

#decCond = ['indItems_trainCue0_testCue0', 'indItems_trainCue0_testCue1', 'indItems_trainCue1_testCue0', 'indItems_trainCue1_testCue1']
#figTitles = ['Match', 'Match', 'Mismatch', 'Mismatch']

if fdecoding is 'perChannel':
	decCond = ['cue', 'itemPos', 'indItems', 'load', 'probeID', 'probe', 'buttonPress']
	figTitles = ['Task', 'Item position', 'Item identity', 'Item load', 'Probe identity', 'Probe category', 'Motor  response']

	#decCond = ['cue', 'itemPos', 'indItems', 'load', 'probeID', 'probe', 'buttonPress']
	#figTitles = ['Task', 'Item position', 'Item identity', 'Item load', 'Probe identity', 'Probe category', 'Motor response']
#decCond = ['indItems_trainCue0_testCue0', 'indItems_trainCue0_testCue1', 'indItems_trainCue1_testCue0', 'indItems_trainCue1_testCue1']
#figTitles = ['Match', 'Mismatch', 'Match', 'Mismatch']
#decCond = ['cue', 'itemPos', 'indItems', 'load', 'probeID', 'probe', 'buttonPress']
#figTitles = ['Task', 'Item position',  'Item identity', 'Item load', 'Probe identity', 'Probe category', 'Motor response']

if fdecoding is not 'perChannel':
	if (fmethod is not 'tfa_wavelet_final_corrected') & (fmethod is not 'chanxfreq_tfa_wavelet_final') & (fmethod is not 'chanxfreq_tfa_wavelet_final_corrected') & ('spatialPatterns' not in fmethod):
		generalization = 1 #0 = diagonal only, 1 = full matrix
	else:
		generalization = 0
else:
	generalization = 0

if (fmethod is 'tfa_wavelet_final_corrected') | (fmethod is 'chanxfreq_tfa_wavelet_final') | (fmethod is 'chanxfreq_tfa_wavelet_final_corrected'):
	trainTime = [bl[0], 4.3]
	testTime = [bl[0], 4.3]
elif fmethod is 'erp':
	trainTime = [bl[0], 4.4985]
	testTime = [bl[0], 4.4985]
elif (fmethod is 'erp_100') | (fmethod is 'frontal_erp_100') | (fmethod is 'temporal_erp_100') | (fmethod is 'erp_100_spatialPatterns'):
	trainTime = [bl[0], 4.48]
	testTime = [bl[0], 4.48]
elif (fmethod is 'respLocked_erp_100') | (fmethod is 'frontal_respLocked_erp_100') | (fmethod is 'temporal_respLocked_erp_100') | (fmethod is 'respLocked_erp_100_spatialPatterns'):
	trainTime = [-4.0, 0.]
	testTime = [-4.0, 0.]
elif (fmethod is 'probeLocked_erp_100_longEpoch') | (fmethod is 'frontal_probeLocked_erp_100_longEpoch') | (fmethod is 'temporal_probeLocked_erp_100_longEpoch'):
	trainTime = [-4.5, .5]
	testTime = [-4.5, .5]
elif fmethod is 'respLocked_tfa_wavelet':
	trainTime = [-3.5, -0.35]
	testTime = [-3.5, -0.35]

#CV
n_folds = 5
predict_mode = 'cross-validation' #or mean-prediction

#Specific to SVM
proba = True #determines whether or not the output will be continous or not

#Score
score_method = 'auc'

##########################################
#Stats
stats = 'permutation' #compute stats or not? 'permutation_load'
n_permutations = 5000
stat_alpha = .05

chance = .5 #for auc_multiclass: .3, else: .5
tail = 0 #0 = 2-sided, 1 = 1-sided

##########################################
#Figure
#Data properties
sfreq = 100
if fdecoding is not 'perChannel':
	if (fmethod is not 'tfa_wavelet_final_corrected') & (fmethod is not 'chanxfreq_tfa_wavelet_final'):
		smoothWindow = 10 #Will the data (but not the stats be smoothed?)
	else:
		smoothWindow = 3
else:
	smoothWindow = 0


#Figure properties
line_thickness = 2
#line_color = ((0.8901960784313725, 0.10196078431372549, 0.10980392156862745), (1.0, 0.4980392156862745, 0.0), (0.2, 0.6274509803921569, 0.17254901960784313), 
 #(23/255, 190/255, 207/255), (31/255, 120/255, 180/255), (106/255, 61/255, 154/255))

if (decCond[0] is 'cue') & (fdecoding is not 'perChannel'):
	line_color = ((0.8901960784313725, 0.10196078431372549, 0.10980392156862745), (1.0, 0.4980392156862745, 0.0), (253/255, 208/255, 23/255), 
		(60/255, 179/255, 113/255), (23/255, 190/255, 207/255), (31/255, 120/255, 180/255), (106/255, 61/255, 154/255))
	map_color = [sns.light_palette((0.8901960784313725, 0.10196078431372549, 0.10980392156862745), as_cmap=True), 
		sns.light_palette((1.0, 0.4980392156862745, 0.0), as_cmap=True), sns.light_palette((253/255, 208/255, 23/255), as_cmap=True),
		sns.light_palette((60/255, 179/255, 113/255), as_cmap=True), sns.light_palette((23/255, 190/255, 207/255), as_cmap=True), 
		sns.light_palette((31/255, 120/255, 180/255), as_cmap=True), sns.light_palette((106/255, 61/255, 154/255), as_cmap=True)]
elif fdecoding is 'perChannel':
	line_color = ((0.8901960784313725, 0.10196078431372549, 0.10980392156862745), (1.0, 0.4980392156862745, 0.0), (253/255, 208/255, 23/255), 
		(60/255, 179/255, 113/255), (23/255, 190/255, 207/255), (31/255, 120/255, 180/255), (106/255, 61/255, 154/255))
	map_color = [sns.light_palette((0.8901960784313725, 0.10196078431372549, 0.10980392156862745), as_cmap=True), 
		sns.light_palette((1.0, 0.4980392156862745, 0.0), as_cmap=True), sns.light_palette((253/255, 208/255, 23/255), as_cmap=True),
		sns.light_palette((60/255, 179/255, 113/255), as_cmap=True), sns.light_palette((23/255, 190/255, 207/255), as_cmap=True), 
		sns.light_palette((31/255, 120/255, 180/255), as_cmap=True), sns.light_palette((106/255, 61/255, 154/255), as_cmap=True)]
else:
	#tmp = sns.color_palette("YlOrRd", 6)
	tmp = sns.color_palette('Paired')
	line_color = (tmp[1], tmp[0], tmp[2], tmp[3])
	map_color = [sns.light_palette(tmp[1], as_cmap=True), 
		sns.light_palette(tmp[0], as_cmap=True), sns.light_palette(tmp[2], as_cmap=True),
		sns.light_palette(tmp[3], as_cmap=True)]
maskSig = 1 #mask all insignificant values or not
maskThresh = 0
contour_steps = np.linspace(chance+.01, .6, 10)

#Font properties
font_name = 'Arial'
font_size = 9
font_weight = 'normal'

font_name_gen = 'Arial'
font_size_gen = 13
font_weight_gen = 'normal'