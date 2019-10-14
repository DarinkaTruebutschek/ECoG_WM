#Purpose: This contains some important basic functions.
#Project: ECoG
#Author: Darinka Truebutschek
#Date: 14 October 2019

import numpy as np
import pandas as pd

from scipy.io import loadmat
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