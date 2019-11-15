###Purpose: This file contains all of the parameters to be used for plotting the decoding analyses.
###Project: ECoG_WM
###Author: D.T.
###Date: 15 November 2019

import seaborn as sns

##########################################
#Paths
wkdir = '/media/darinka/Data0/iEEG/'
behavior_path = wkdir + 'Results/Behavior/'
data_path = wkdir + 'Results/Decoding/'
result_path = wkdir + 'Results/Decoding/'
script_path = wkdir + 'ECoG_WM/Python/'

##########################################
#Preprocessing
bl = [-0.14, 0]
blc = 1 #baseline correction or not?

##########################################
#TF parameters
fmethod = 'tfa_wavelet'

##########################################
#Inclusion parameters
acc = 1 #0 = include both correct and incorrect trials, 1 = include only correct trials

##########################################
#Decoding
decCond = 'indItems'

generalization = 0 #0 = diagonal only, 1 = full matrix

trainTime = [bl[0], 4.3]
testTime = [bl[0], 4.3]

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

chance = 0.5
tail = 1 #0 = 2-sided, 1 = 1-sided

##########################################
#Figure
#Data properties
smoothWindow = 2 #Will the data (but not the stats be smoothed?)

#Figure properties
line_thickness = 2
line_color = sns.color_palette("colorblind")

#Font properties
font_name = 'Arial'
font_size = 12
font_weight = 'bold'