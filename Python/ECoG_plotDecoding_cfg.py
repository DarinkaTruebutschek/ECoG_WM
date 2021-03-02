###Purpose: This file contains all of the parameters to be used for plotting the decoding analyses.
###Project: ECoG_WM
###Author: D.T.
###Date: 15 November 2019

import numpy as np
import seaborn as sns

from matplotlib.colors import ListedColormap

##########################################
#Paths
wkdir = '/media/darinka/Data0/iEEG/'
behavior_path = wkdir + 'Results/Behavior/'
data_path = wkdir + 'Results/Decoding/'
result_path = wkdir + 'Results/Decoding/'
script_path = wkdir + 'ECoG_WM/Python/'

##########################################
#TF parameters
fmethod = 'tfa_wavelet_final'

##########################################
#Preprocessing
if (fmethod is 'tfa_wavelet_final') | (fmethod is 'respLocked_tfa_wavelet'):
	bl = [-.14, 0]
elif (fmethod is 'erp') | (fmethod is 'erp_100') | (fmethod is 'tfa_wavelet_final'):
	bl = [-.2, 0]

blc = 0 #baseline correction or not?

##########################################
#Inclusion parameters
acc = 1 #0 = include both correct and incorrect trials, 1 = include only correct trials

##########################################
#Decoding
decCond = 'indItems' # 'itemPos', indItems', 'cue', 'load'

generalization = 0 #0 = diagonal only, 1 = full matrix

if fmethod is 'tfa_wavelet_final':
	trainTime = [bl[0], 4.3]
	testTime = [bl[0], 4.3]
elif fmethod is 'erp':
	trainTime = [bl[0], 4.4985]
	testTime = [bl[0], 4.4985]
elif fmethod is 'erp_100':
	trainTime = [bl[0], 4.48]
	testTime = [bl[0], 4.48]
elif fmethod is 'respLocked_erp_100':
	trainTime = [-4.0, 0.]
	testTime = [-4.0, 0.]
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
stats = 'permutation' #compute stats or not?
n_permutations = 5000
stat_alpha = .05

chance = .5 #for auc_multiclass: .3, else: .5
tail = 0 #0 = 2-sided, 1 = 1-sided

##########################################
#Figure
#Data properties
sfreq = 100
smoothWindow = False#4 #Will the data (but not the stats be smoothed?)

#Figure properties
line_thickness = 2
line_color = sns.color_palette("Spectral", 11) #sns.color_palette("colorblind")

map_color = ListedColormap(sns.color_palette("RdBu_r", 10))
maskSig = 1 #mask all insignificant values or not
contour_steps = np.linspace(chance+.01, .6, 10)

#Font properties
font_name = 'Arial'
font_size = 6
font_weight = 'normal'

font_name_gen = 'Arial'
font_size_gen = 12
font_weight_gen = 'normal'