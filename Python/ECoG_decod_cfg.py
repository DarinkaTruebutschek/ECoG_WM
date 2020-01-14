###Purpose: This file contains all of the parameters to be used in the decoding analyses.
###Project: ECoG_WM
###Author: D.T.
###Date: 4 October 2019

##########################################
#Paths
wkdir = '/media/darinka/Data0/iEEG/'
behavior_path = wkdir + 'Results/Behavior/'
data_path = wkdir + 'Results/Data/'
result_path = wkdir + 'Results/Decoding/'
script_path = wkdir + 'ECoG_WM/Python/'

##########################################
#Preprocessing
blc = 1 #baseline correction or not?

##########################################
#TF parameters
#fmethod = 'tfa_wavelet'
fmethod = 'erp'

##########################################
#Inclusion parameters
acc = 1 #0 = include both correct and incorrect trials, 1 = include only correct trials

##########################################
#Decoding
decCond = 'indItems'

generalization = 0 #0 = diagonal only, 1 = full matrix

if fmethod is 'tfa_wavelet':
	bl = [-0.14, 0] #baseline window
	trainTime = [bl[0], 4.3]
	testTime = [bl[0], 4.3]
else:
	bl = (-0.2, 0)
	trainTime = [bl[0], 4.4985]
	testTime = [bl[0], 4.4985]

#CV
n_folds = 5
predict_mode = 'cross-validation' #or mean-prediction

#Specific to SVM
proba = True #determines whether or not the output will be continous or not

#Score
score_method = 'auc'
