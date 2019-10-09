#Purpose: This script contains different functions to run a decoding analysis.
#Project: ECoG
#Author: Darinka Truebutschek
#Date: 08 October 2019

##########################################
#Load common libraries
import numpy as np

#MNE
from mne.decoding import (SlidingEstimator, GeneralizingEstimator, cross_val_multiscore, LinearModel)

#Sklearn
from sklearn import svm
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import make_pipeline
from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import roc_auc_score
from sklearn.feature_selection import SelectKBest, f_classif

#Scikit multilearn
from skmultilearn.problem_transform import BinaryRelevance

def multiLabel_classif(X_train, y_train, X_test, y_test):
	"""
	This function performs a multi-label classification task,
	by treating each label as a separate single-label classifiction problem.
	Both X and y are matrices.
	"""

	##########################################
	#Learning machinery
	model = svm.SVC(C=1, kernel='linear')

	clf = BinaryRelevance(classifier=model)
	##########################################
	#Learning process
	time_gen = GeneralizingEstimator(clf, scoring=None, n_jobs=1, verbose=True)

	time_gen.fit(X_train, y_train)
	predictions = time_gen.predict(X_test)

	return time_gen, predictions



