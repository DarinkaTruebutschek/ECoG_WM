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
fmethod = 'respLocked_erp_100'
#fmethod = 'erp_100' #erp_100: downsampled to 100 Hz, erp: downsampled to 250 Hz

##########################################
#Preprocessing
blc = 0 #baseline correction or not?
rel_blc = 0 #relative baseline correction or not?

if (fmethod is 'tfa_wavelet') | (fmethod is 'tfa_wavelet_final') | (fmethod is 'chanxfreq_tfa_wavelet_final'):
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
		trainTime = [-4., 0.]
		testTime = [-4., 0.]
	elif fmethod is 'probeLocked_erp_100':
		trainTime = [-4.5, .15]
		testTime = [-4.5, .15]
	elif fmethod is 'probeLocked_erp_100_longEpoch':
		trainTime = [-4.5, .5]
		testTime = [-4.5, .5]


##########################################
#Slice definition
coi = 'all' #which specific channels will be included

if fmethod is 'erp':
	toi = [bl[0], 4.4985] #which time window will be considered (i.e., default: beginning of baseline until end of epoch)
elif fmethod is 'erp_100':
	toi = [bl[0], 4.48]
elif fmethod is 'respLocked_erp_100':
	toi = [-4.0, 0] #[-4.0, 0]
elif fmethod is 'probeLocked_erp_100':
	toi = [-4.5, .15]
elif fmethod is 'probeLocked_erp_100_longEpoch':
	toi = [-4.5, .5]
elif (fmethod is 'tfa_wavelet_final') | (fmethod is 'chanxfreq_tfa_wavelet_final'):
	toi = [bl[0], 4.3]

if fmethod is 'erp_100':
	#win_size = False8
	#win_size = [[-.2, 0], [0, .5], [0.5, 1.5], [1.5, 2.5], [2.5, 4.5]]#False#0.5 #how many time points will be added as feature dimensions; in sec; if decoding is to be done independently on each time point, set to False
	win_size = ([[-.2, -.1], [-.1, 0], [0, .1], [.1, .2], [.2, .3], [.3, .4], [.4, .5], [.5, .6], [.6, .7], [.7, .8], [.8, .9], [.9, 1.],
		[1., 1.1], [1.1, 1.2], [1.2, 1.3], [1.3, 1.4], [1.4, 1.5], [1.5, 1.6], [1.6, 1.7], [1.7, 1.8], [1.8, 1.9], [1.9, 2.0], 
		[2., 2.1], [2.1, 2.2], [2.2, 2.3], [2.3, 2.4], [2.4, 2.5], [2.5, 2.6], [2.6, 2.7], [2.7, 2.8], [2.8, 2.9], [2.9, 3.0],
		[3., 3.1], [3.1, 3.2], [3.2, 3.3], [3.3, 3.4], [3.4, 3.5], [3.5, 3.6], [3.6, 3.7], [3.7, 3.8], [3.8, 3.9], [3.9, 4.0],
		[4., 4.1], [4.1, 4.2], [4.2, 4.3], [4.3, 4.4], [4.4, 4.5]])
	step_size = 1.0#0.5 #where to begin with this
elif fmethod is 'respLocked_erp_100':
	#win_size = False
	win_size = ([[-4.0, -3.9], [-3.9, -3.8], [-3.8, -3.7], [-3.7, -3.6], [-3.6, -3.5], [-3.5, -3.4], [-3.4, -3.3], [-3.3, -3.2], [-3.2, -3.1], [-3.1, -3.0], 
		[-3.0, -2.9], [-2.9, -2.8], [-2.8, -2.7], [-2.7, -2.6], [-2.6, -2.5], [-2.5, -2.4], [-2.4, -2.3], [-2.3, -2.2], [-2.2, -2.1], [-2.1, -2.0],
		[-2.0, -1.9], [-1.9, -1.8], [-1.8, -1.7], [-1.7, -1.6], [-1.6, -1.5], [-1.5, -1.4], [-1.4, -1.3], [-1.3, -1.2], [-1.2, -1.1], [-1.1, -1.0],
		[-1.0, -0.9], [-0.9, -0.8], [-0.8, -0.7], [-0.7, -0.6], [-0.6, -0.5], [-0.5, -0.4], [-0.4, -0.3], [-0.3, -0.2], [-0.2, -0.1], [-0.1, 0.0]])
	#win_size = [[-4, -3], [-3, -2], [-2, -1], [-1, -.5], [-.5, 0]] #False#0.5 #how many time points will be added as feature dimensions; in sec; if decoding is to be done independently on each time point, set to False
	#step_size = 1.0#0.5 #where to begin with this
elif fmethod is 'probeLocked_erp_100':
	win_size = False
elif fmethod is 'probeLocked_erp_100_longEpoch':
	#win_size = False
	win_size = ([[-4.5, -4.4], [-4.4, -4.3], [-4.3, -4.2], [-4.2, -4.1], [-4.1, -4.0], 
		[-4.0, -3.9], [-3.9, -3.8], [-3.8, -3.7], [-3.7, -3.6], [-3.6, -3.5], [-3.5, -3.4], [-3.4, -3.3], [-3.3, -3.2], [-3.2, -3.1], [-3.1, -3.0], 
		[-3.0, -2.9], [-2.9, -2.8], [-2.8, -2.7], [-2.7, -2.6], [-2.6, -2.5], [-2.5, -2.4], [-2.4, -2.3], [-2.3, -2.2], [-2.2, -2.1], [-2.1, -2.0],
		[-2.0, -1.9], [-1.9, -1.8], [-1.8, -1.7], [-1.7, -1.6], [-1.6, -1.5], [-1.5, -1.4], [-1.4, -1.3], [-1.3, -1.2], [-1.2, -1.1], [-1.1, -1.0],
		[-1.0, -0.9], [-0.9, -0.8], [-0.8, -0.7], [-0.7, -0.6], [-0.6, -0.5], [-0.5, -0.4], [-0.4, -0.3], [-0.3, -0.2], [-0.2, -0.1], [-0.1, 0.0],
		[0.0, 0.1], [0.1, 0.2], [0.2, 0.3], [0.3, 0.4], [0.4, 0.5]])
	step_size = 1.0#0.5 #where to begin with this
elif (fmethod is 'tfa_wavelet_final') | (fmethod is 'chanxfreq_tfa_wavelet_final'):
	win_size = False
	#win_size = [[-0.14, 0], [0, .5], [0.5, 1.5], [1.5, 2.5], [2.5, 4.3]] #False#0.5 #how many time points will be added as feature dimensions; in sec; if decoding is to be done independently on each time point, set to False
	#step_size = 1.0#0.5 #where to begin with this
elif fmethod is 'respLocked_tfa_wavelet':
	#win_size = False
	win_size = [[-3.5, -3], [-3, -2], [-2, -1], [-1, -.5], [-.5, -0.35]]
	step_size = 1

##########################################
#Inclusion parameters
acc = 1 #0 = include both correct and incorrect trials, 1 = include only correct trials

##########################################
#Decoding
decCond = 'buttonPress' #other options: 'probe', 'itemPos', load', indItems', 'cue', indItems_trainCue0_testCue1, 'indItems_load1'

if (win_size is False) & (fmethod is not 'tfa_wavelet_final') & (fmethod is not 'chanxfreq_tfa_wavelet_final'):
	generalization = 1 #0 = diagonal only, 1 = full matrix
else:
	generalization = 0

#CV
if decCond is 'indItems_load1':
	n_folds = 3
else:
	n_folds = 5
predict_mode = 'cross-validation' #or cross-validation or mean-prediction

#Specific to SVM
proba = True #determines whether or not the output will be continous or not

#Score
score_method = 'auc' #or: auc_multiclass (for decoding load & probeID)
