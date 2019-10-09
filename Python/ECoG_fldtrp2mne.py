###Purpose: This functions converts ECoG data from a fieldtrip structure into  mne epochs.
###Project: ECoG_WM
###Author: D.T.
###Date: 1 October 2019

#Load libraries
#import hdf5storage
import mne
import numpy as np
import pymatreader
import scipy.io as sio

from mne.io.meas_info import create_info
from mne.time_frequency import EpochsTFR

def ECoG_fldtrp2mne(filename, var, type):
	"This function converts data from a fieldtrip structure to mne epochs"

	#Load Matlab/fieldtrip data
	#mat = hdf5storage.loadmat(filename)
	ft_data = pymatreader.read_mat(filename)
	ft_data = ft_data[var]

	if type is 'tfa':
		#Identify basic parameters
		n_trials, n_channels, n_freqs, n_time = np.shape(ft_data['powspctrm']) #ATTENTION: This presumes equal epoch length!

		data = np.zeros((n_trials, n_channels, n_freqs, n_time))

		for triali in range(n_trials):
			data[triali, :, :, :] = ft_data['powspctrm'][triali, :, :, :]

