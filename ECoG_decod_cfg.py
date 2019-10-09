###Purpose: This file contains all of the parameters to be used in the decoding analyses.
###Project: ECoG_WM
###Author: D.T.
###Date: 4 October 2019

##########################################
#Paths
wkdir = '/media/darinka/Data0/iEEG/'
data_path = wkdir + 'Results/Data/'
result_path = wkdir + 'Results/Decoding/'
script_path = wkdir + 'ECoG_WM/Python/'

##########################################
#Preprocessing
bl = [-0.15, 0]
blc = 1 #baseline correction or not?

##########################################
#TF parameters
foi = [8, 12]

##########################################
#Decoding
decCond = 'indItems'

trainTime = [bl[0] : 5.0]
testTime = [bl[0] : 5.0]
