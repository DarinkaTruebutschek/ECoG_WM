###Purpose: Basic stats functions of interest (adapted from J.R. King)
###Project: MenRot
###Author: Darinka Trubutschek
###Date: 18 December 2017

import numpy as np

from mne.stats import ttest_1samp_no_p
from mne.stats import spatio_temporal_cluster_1samp_test, fdr_correction
from scipy import stats
from scipy.stats import wilcoxon

def _loop(x, function):

	out = list()
	for ii in range(x.shape[1]):
		out.append(function(x[:, ii]))
	return out

def _my_wilcoxon(X):

    out = wilcoxon(X)
    return out[1]


def _stat_fun(x, sigma=0, method='relative'):

    t_values = ttest_1samp_no_p(x, sigma=sigma, method=method)
    t_values[np.isnan(t_values)] = 0
    return t_values


def myStats(X, connectivity=None, n_jobs=-1, tail=0, permutations=5000):

    X = np.array(X)
    X = X[:, :, None] if X.ndim == 2 else X
    T_obs_, clusters, p_values, _ = spatio_temporal_cluster_1samp_test(X, out_type='mask', stat_fun=_stat_fun, n_permutations=permutations, n_jobs=n_jobs, connectivity=connectivity, tail=tail)
    p_values_ = np.ones_like(X[0].T)

    for cluster, pval in zip(clusters, p_values):
        p_values_[cluster.T] = pval

    return np.squeeze(p_values_).T


def parallel_stats(X, function=_my_wilcoxon, correction='FDR', n_jobs=-1, startTime=None, endTime=None):
    
    from mne.parallel import parallel_func

    if correction not in [False, None, 'FDR']:
        raise ValueError('Unknown correction')

    #Reshape to 2D
    X = np.array(X)
    dims = X.shape
    X.resize([dims[0], np.prod(dims[1:])])

    #Prepare parallel
    n_cols = X.shape[1]
    parallel, pfunc, n_jobs = parallel_func(_loop, n_jobs)
    n_chunks = min(n_cols, n_jobs)
    chunks = np.array_split(range(n_cols), n_chunks)
    p_values = parallel(pfunc(X[:, chunk], function) for chunk in chunks)
    p_values = np.reshape(np.hstack(p_values), dims[1:])
    X.resize(dims)

    #Apply correction
    if correction == 'FDR':
        dims = p_values.shape
        if (startTime is None) & (endTime is None):
            _, p_values = fdr_correction(p_values)
            p_values = np.reshape(p_values, dims)
        elif (startTime is not None) & (endTime is None):
            beg =  np.ones(len(p_values[:startTime]))
            _, p_values = fdr_correction(p_values[startTime :])
            p_values = np.concatenate((beg, p_values), axis=0)
        elif (startTime is None) & (endTime is not None):
            end = np.ones(len(p_values[endTime + 1:]))
            _, p_values = fdr_correction(p_values[: endTime + 1])
            p_values = np.concatenate((p_values, end), axis=0)
        else:
            beg =  np.ones(len(p_values[:startTime]))
            end = np.ones(len(p_values[endTime + 1:]))
            _, p_values = fdr_correction(p_values[startTime : endTime + 1])
            p_values = np.concatenate((beg, p_values, end), axis=0) 
    return p_values
