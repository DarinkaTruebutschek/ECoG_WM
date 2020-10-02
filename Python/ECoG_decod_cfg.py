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
#TF parameters
fmethod = 'erp_100'
#fmethod = 'respLocked_erp_100' #erp_100: downsampled to 100 Hz, erp: downsampled to 250 Hz

##########################################
#Preprocessing
blc = 0 #baseline correction or not?
rel_blc = 0 #relative baseline correction or not?

if fmethod is 'tfa_wavelet':
	bl = [-0.14, 0] #baseline window
	trainTime = [bl[0], 4.3]
	testTime = [bl[0], 4.3]
elif fmethod is 'respLocked_tfa_wavelet':
	bl = [-3.5, -3.3] #there is no appropriate baseline in this case
	trainTime = [-3.5, -0.35]
	testTime = [-3.5, -0.35]
else:
	bl = (-0.2, 0)
	if fmethod is 'erp':
		trainTime = [bl[0], 4.4985]
		testTime = [bl[0], 4.4985]
	elif fmethod is 'erp_100':
		trainTime = [bl[0], 4.48]
		testTime = [bl[0], 4.48]
	elif fmethod is 'respLocked_erp_100':
		trainTime = [-1., 0.]
		testTime = [-1., 0.]

##########################################
#Slice definition
coi = 'all' #which specific channels will be included

if fmethod is 'erp':
	toi = [bl[0], 4.4985] #which time window will be considered (i.e., default: beginning of baseline until end of epoch)
elif fmethod is 'erp_100':
	toi = [bl[0], 4.48]
elif fmethod is 'respLocked_erp_100':
	toi = [-1.0, 0] #[-4.0, 0]

win_size = False#0.5 #how many time points will be added as feature dimensions; in sec; if decoding is to be done independently on each time point, set to False
step_size = 1.0#0.5 #where to begin with this

##########################################
#Inclusion parameters
acc = 1 #0 = include both correct and incorrect trials, 1 = include only correct trials

##########################################
#Decoding
decCond = 'load' #other options: 'indItems', 'cue'

generalization = 1 #0 = diagonal only, 1 = full matrix

#CV
n_folds = 5
predict_mode = 'cross-validation' #or mean-prediction

#Specific to SVM
proba = True #determines whether or not the output will be continous or not

#Score
score_method = 'auc_multiclass'
