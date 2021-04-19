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
from mne.epochs import EpochsArray
from mne.time_frequency.tfr import EpochsTFR

def ECoG_fldtrp2mne(filename, var, data_type):
	"This function converts data from a fieldtrip structure to mne epochs"

	#Load Matlab/fieldtrip data
	#mat = hdf5storage.loadmat(filename)
	ft_data = pymatreader.read_mat(filename)
	ft_data = ft_data[var]

	if data_type is 'tfa':
		#Identify basic parameters
		n_trials, n_channels, n_freqs, n_time = np.shape(ft_data['powspctrm']) #ATTENTION: This presumes equal epoch length!

		#Initialize data array
		data = np.zeros((n_trials, n_channels, n_freqs, n_time))

		for triali in range(n_trials):
			data[triali, :, :, :] = ft_data['powspctrm'][triali, :, :, :]

		#Initialize channel array
		chan_types = list(range(n_channels))

		#Add necessary info
		sfreq = float(1000) 
		times = ft_data['time']
		freqs = ft_data['freq']
		method = 'morlet wavelet'
		chan_names = ft_data['label']

		for chani in chan_types:
			chan_types[chani] = 'ecog'

		#Create info and epochs
		info = create_info(chan_names, sfreq, chan_types)
		power = EpochsTFR(info, data, times, freqs)

		return power

	elif data_type is 'chanxfreq_tfa':
		#Identify basic parameters
		n_trials, n_features, n_time = np.shape(ft_data['powspctrm']) #ATTENTION: This presumes equal epoch length!

		#Initialize data array
		data = np.zeros((n_trials, n_features, n_time))

		for triali in range(n_trials):
			data[triali, :, :] = ft_data['powspctrm'][triali, :, :]

		#Initialize channel array
		chan_types = list(range(n_features))

		#Add necessary info
		sfreq = float(100) 
		times = ft_data['time']
		#freqs = ft_data['freq']
		#method = 'morlet wavelet'
		#chan_names = ft_data['label']

		for chani in chan_types:
			chan_types[chani] = 'ecog'

		#Create info and epochs
		#info = create_info(chan_names, chan_types)
		#Create info and epochs
		info = create_info(ch_names=chan_types, sfreq=sfreq, ch_types=chan_types)
		epochs = EpochsArray(data, info, events=None, tmin=np.min(times), verbose=False)

		return epochs

	elif data_type is 'erp':
		#Identify basic parameters
		n_trials, n_channels, n_time = np.shape(ft_data['trial']) #ATTENTION: This presumes equal epoch length!

		#Initialize data array
		data = np.zeros((n_trials, n_channels, n_time))

		for triali in range(n_trials):
			data[triali, :, :] = ft_data['trial'][triali]

		#Initialize channel array
		chan_types = list(range(n_channels))

		#Add necessary info
		sfreq = float(ft_data['fsample']) 
		times = ft_data['time']
		chan_names = ft_data['label']

		for chani in chan_types:
			chan_types[chani] = 'ecog'

		#Create info and epochs
		info = create_info(chan_names, sfreq, chan_types)
		epochs = EpochsArray(data, info, events=None, tmin=np.min(times), verbose=False)

		return epochs
