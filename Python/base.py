#Purpose: This contains some important basic functions.
#Project: ECoG
#Author: D.T.
#Date: 14 October 2019

import numpy as np
import pandas as pd

from scipy.io import loadmat
from scipy.ndimage.filters import generic_filter as gf
##########################################
def find_nearest(a, a0):

	"Element in nd array 'a' closest to the scalar value a0"

	idx = np.abs(a - a0).argmin()
	return idx, a.flat[idx]

##########################################
def loadtablefrommat(matfilename, tablevarname, columnnamesvarname):
    
    "Read a struct-ified table variable (and column names) from a MAT-file and return pandas.DataFrame object."

    #Load file
    mat = loadmat(matfilename)

    #Get table (struct) variable
    tvar = mat.get(tablevarname)
    data_desc = mat.get(columnnamesvarname)
    types = tvar.dtype
    fieldnames = types.names

    #Extract data (from table struct)
    data = None
    for idx in range(len(fieldnames)):
        if fieldnames[idx] == 'data':
            data = tvar[0][0][idx]
            break;

    #Get number of columns and rows
    numcols = data.shape[1]
    numrows = data[0, 0].shape[0]

    #Get column headers as a list (array)
    data_cols = []
    for idx in range(numcols):
        data_cols.append(data_desc[0, idx][0])

    #Create dict out of original table
    table_dict = {}
    for colidx in range(numcols):
        rowvals = []
        for rowidx in range(numrows):
            rowval = data[0,colidx][rowidx][0]
            if type(rowval) == np.ndarray and rowval.size > 0:
                rowvals.append(rowval[0])
            else:
                rowvals.append(rowval)
        table_dict[data_cols[colidx]] = rowvals
    return pd.DataFrame(table_dict)

##########################################
def my_smooth(data, window):
    
    data = np.array(data)

    print('Dimension of data to smooth: ' + str(data.ndim))
    
    #Check whether data is 1D (diagonal) or 2D (GAT)
    if data.ndim == 1:
        for t in range(data.shape[0]): #loop through the entire dataset
            if t <= window: #beginning of data
                data[t] = np.mean(data[t : (t + window + 1)])
            elif t >= data.shape[0] - window: #end of data
                data[t] = np.mean(data[(t - window) : t + 1])
            else:
                data[t] = np.mean(data[(t - window) : (t + window + 1)])
        
    elif data.ndim == 2: #Gat matrix
        kernel = np.ones((2 * window + 1, 2 * window + 1))
        data = gf(data, np.mean, footprint=kernel)
    return data