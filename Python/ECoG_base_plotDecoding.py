###Purpose: Basic plotting functions specific to decoding (adapted from J.R. King)
###Project: EcoG
###Author: D.T.
###Date: 15 November 2019

import matplotlib.pyplot as plt
import numpy as np
import numpy.ma as ma

from ECoG_base_plot import pretty_plot, plot_sem, plot_widths, pretty_colorbar
from ECoG_plotDecoding_cfg import font_name, font_size, font_weight, font_name_gen, font_size_gen, font_weight_gen


def pretty_gat(scores, times=None, chance=0, ax=None, sig=None, cmap='RdBu_r',
               clim=None, colorbar=True, xlabel='Test Times',
               ylabel='Train Times', sfreq=250, diagonal=None,
               test_times=None, classLines=None, classColors=None, contourPlot=None, steps=None):
    
    #Check if array is masked or not
    if ma.is_masked(scores):
        scores
    else:
        scores = np.array(scores)

    if times is None:
        times = np.arange(scores.shape[0]) / float(sfreq)

    #Setup color range
    if clim is None:
        if ma.is_masked(scores):
            spread = 2 * np.round(np.percentile(
                np.abs(scores.data[~scores.mask] - chance), 99) * 1e2) /1e2
        else:
            spread = 2 * np.round(np.percentile(
                np.abs(scores - chance), 99) * 1e2) / 1e2
        m = chance
        vmin, vmax = m + spread * np.array([-.6, .6])
    elif len(clim) == 1:
        vmin, vmax = clim - chance, clim
    else:
        vmin, vmax = clim

    #Setup time
    if test_times is None:
        if scores.shape[1] == scores.shape[0]:
            test_times = times
        else:
            test_times = np.cumsum(
                np.ones(scores.shape[1])) * np.ptp(times) / len(times)
    extent = [min(test_times), max(test_times), min(times), max(times)]

    #Setup plot
    if ax is None:
        ax = plt.gca()

    #Plot score
    if contourPlot is None:
        im = ax.matshow(scores, extent=extent, cmap=cmap, origin='lower', vmin=vmin, vmax=vmax, aspect='equal')
    else:
        im = ax.contourf(scores, levels=steps, extent=extent, cmap=cmap, origin='lower', vmin=vmin, vmax=vmax, aspect='equal')
        #im.cmap.set_over(maxColor)
        plt.contour(scores, levels=steps, extent=extent, origin='lower', vmin=vmin, vmax=vmax, aspect='equal', linewidths = 0, colors = 'k')
        pretty_colorbar(im=im, ax=None, ticks=steps, ticklabels=None, nticks=np.size(steps))

    #Plot sig
    if sig is not None:
        sig = np.array(sig)

        xx, yy = np.meshgrid(test_times, times, copy=False, indexing='xy')
        ax.contour(xx, yy, sig, colors= 'k', linestyles='solid', linewidths = 0.25)
		
    ax.axhline(0, color='k')
    ax.axvline(0, color='k')
    
    #Add additional lines for classifiers if needed
    if classLines is not None:
		#Loop through all possible lines and plot them
        for t, tp in enumerate(classLines):
            ax.axhline(tp, color = classColors[t], linestyle = 'dashed', linewidth = 1)

    if colorbar:
        pretty_colorbar(
            im, ax=ax, ticks=[vmin, chance, vmax],
            ticklabels=['%.2f' % vmin, 'Chance', '%.2f' % vmax])

    #
    if diagonal is not None:
        ax.plot([np.max([min(times), min(test_times)]),
                 np.min([max(times), max(test_times)])],
                [np.max([min(times), min(test_times)]),
                 np.min([max(times), max(test_times)])], color=diagonal, linestyle = 'dashed', linewidth = 2)

    #Setup ticks
    xticks, xticklabels = _set_ticks(test_times)
    ax.set_xticks(xticks)
    ax.set_xticklabels(xticklabels, fontname=font_name_gen, fontsize=font_size_gen, fontweight=font_weight_gen)
    yticks, yticklabels = _set_ticks(times)
    ax.set_yticks(yticks)
    ax.set_yticklabels(yticklabels, fontname=font_name_gen, fontsize=font_size_gen, fontweight=font_weight_gen)
    if len(xlabel):
        ax.set_xlabel(xlabel, fontname=font_name_gen, fontsize=font_size_gen+1, fontweight=font_weight_gen)
    if len(ylabel):
        ax.set_ylabel(ylabel, fontname=font_name_gen, fontsize=font_size_gen+1, fontweight=font_weight_gen)
    ax.set_xlim(min(test_times), max(test_times))
    ax.set_ylim(min(times), max(times))
    pretty_plot(ax)
    return ax

def pretty_decod(scores, times=None, chance=0, ax=None, sig=None, width=3.,
                 color='k', fill=False, ylabel='AUC', xlabel='Time (s)', sfreq=250, alpha=.75, scat=False, line=False, lim=None, thickness=4,
                 thicknessScat=20):

    if (scores.ndim == 1) or (scores.shape[1] <= 1): 
        scores = scores[:, None].T
    if times is None:
        times = np.arange(scores.shape[1]) / float(sfreq)

    #Setup plot
    if ax is None:
        ax = plt.gca()

    #Plot SEM
    if scores.ndim == 2 and scores.shape[0] > 1:
        scores_m = np.mean(scores, axis=0)
        sem = scores.std(0) / np.sqrt(len(scores))
        plot_sem(times, scores_m, sem, color=color, ax=ax, line_args = {'linewidth': thickness})
    else:
        scores_m = np.squeeze(scores)
        sem = np.zeros_like(scores_m)
        plot_sem(times, scores_m, sem, color=color, ax=ax, line_args = {'linewidth': thickness})

    #Plot significance
    if sig is not None:
        sig = np.squeeze(sig)		
        widths = width * sig
        if fill:
            scores_sig = (chance + (scores_m - chance) * sig)
            ax.fill_between(times, chance, scores_sig, color=color,
                            alpha=alpha, linewidth=0)
            ax.plot(times, scores_m, color='k')
            plot_widths(times, scores_m, widths, ax=ax, color='k')
        elif scat: #Added by Darinka Feb 8th 2016 to easily plot significance
            #scores_sig = scores_m[sig < .05]
            #times_sig = times[sig < .05]
            
            times_sig = np.intersect1d(times[sig < .05], times[scores_m > chance]) #used to be .5
            #scores_sig = np.intersect1d(scores_m[sig < .05], scores_m[scores_m > .5]) 
            dummy1 = scores_m[sig < .05]
            scores_sig = dummy1[dummy1 > chance]
            plt.scatter(times_sig, scores_sig, s=thicknessScat, color=color)
        elif line: #Added by Darinka Feb 9th 2016 to plot significance as separate horizontal line
            times_sig = np.intersect1d(sig, times[scores_m > chance]) #select all those time points in which the significance is less than .05 & the accuracy above .5
            plt.scatter(times_sig, np.repeat(min(scores_m - sem)+0.004, len(times_sig)), s=thicknessScat, color=color)
        else:
            plot_widths(times, scores_m, widths, ax=ax, color=color)

    #Pretty
    if lim is not None: #in order to be able to flexibly adjust limits of y axis
        ymin, ymax = lim
    else:
        ymin, ymax = min(scores_m - sem), max(scores_m + sem)
    ax.axhline(chance, linestyle='dotted', color='dimgray', zorder=-3)
    ax.axvline(0, color='dimgray', zorder=-3)
    ax.set_xlim(np.min(times), np.max(times))
    ax.set_ylim(ymin, ymax)
    ax.set_yticks([ymin, chance, ymax])
    #ax.set_yticklabels(['%.2f' % ymin, 'Chance', '%.2f' % ymax], fontdict={'fontname': 'Times New Roman', 'fontsize': schrift})
    ax.set_yticklabels(['%.2f' % ymin, 'Chance', '%.2f' % ymax], fontname=font_name, fontsize=font_size, fontweight=font_weight)
    xticks, xticklabels = _set_ticks(times)
    ax.set_xticks(xticks)
    ax.set_xticklabels(xticklabels, fontname=font_name, fontsize=font_size, fontweight=font_weight)
    if len(xlabel):
        ax.set_xlabel(xlabel, fontname=font_name, fontsize=font_size+1, fontweight=font_weight)
    if len(ylabel):
        ax.set_ylabel(ylabel, rotation=0, fontname=font_name, fontsize=font_size+1, fontweight=font_weight)
        ax.yaxis.set_label_coords(-.04, 1.025)
    pretty_plot(ax)
    return ax


def _set_ticks(times):
    ticks = np.arange(min(times), max(times), .100)
    if np.round(max(times) * 10.) / 10. == max(times):
        ticks = np.append(ticks, max(times))
    ticks = np.round(ticks * 10.) / 10.
    dis = np.where(ticks == 0) #find out what the distance between the individual listings will have to be
    dis = int(dis[0][0])
    tickmarks = ticks[dis : : 5]
    #ticklabels = ([int(ticks[0] * 1e3)] +
                  #['' for ii in ticks[1:-1]] +
                  #[int(ticks[-1] * 1e3)])
    #ticklabels = (['' if ii % dis  != 0 else float(ticks[ii]) for ii in range(len(ticks[0:(-1)]))] + #modified by Darinka 8 Feb. 2016  to get equal spacing
                  #[float(ticks[-1])])
    ticklabels = ([float(ii) if ii in tickmarks else '' for ii in ticks[0 :]])
    #ticklabels[dis] = float(0.)
    return ticks, ticklabels


def pretty_slices(scores, times=None, sig=None, sig_diagoff=None, tois=None,
                  chance=0, axes=None, width=3., colors=['k', 'b'], sfreq=250,
                  sig_invdiagoff=None, fill_color='yellow'):
    scores = np.array(scores)
    # Setup times
    if times is None:
        times = np.arange(scores.shape[0]) / float(sfreq)
	#times = np.arange(scores.shape[1]) /float(sfreq) #modified by Darinka Feb. 8th 2016 to fit my data
    #Setup TOIs
    if tois is None:
        tois = np.linspace(min(times), max(times), 5)
    #Setup Figure
    if axes is None:
        fig, axes = plt.subplots(len(tois), 1, figsize=[5, 6])
    ymin = np.min(scores.mean(0) - scores.std(0)/np.sqrt(len(scores)))
    ymax = np.max(scores.mean(0) + scores.std(0)/np.sqrt(len(scores)))
    #Diagonalize
    scores_diag = np.array([np.diag(ii) for ii in scores]) #this just computes the diagonal
    if sig is not None:
        sig = np.array(sig)
        sig_diag = np.diag(sig) #these are the two-sided p-values for the diagonal
    else:
        sig_diag = None
    for sel_time, ax in zip(tois, reversed(axes)):
        #Select TOI
        idx = np.argmin(abs(times - sel_time))
        scores_off = scores[:, idx, :] #averages over training time
        sig_off = sig[idx, :] if sig is not None else None
        if sig_diagoff is not None:
            scores_sig = (scores_diag.mean(0) * (~sig_diagoff[idx]) +
                          scores_off.mean(0) * (sig_diagoff[idx]))
            ax.fill_between(times, scores_diag.mean(0), scores_sig,
                            color=fill_color, alpha=.5, linewidth=0)
        if sig_invdiagoff is not None:
            scores_sig = (scores_diag.mean(0) * (~sig_invdiagoff[idx]) +
                          scores_off.mean(0) * (sig_invdiagoff[idx]))
            ax.fill_between(times, scores_diag.mean(0), scores_sig,
                            color='red', alpha=.5, linewidth=0)
        pretty_decod(scores_off, times, chance, sig=sig_off,
                     width=width, color=colors[1], fill=False, ax=ax)
        pretty_decod(scores_diag, times, chance, sig=sig_diag,
                     width=0, color=colors[0], fill=False, ax=ax)
        pretty_decod(scores_diag.mean(0), times, chance, sig=sig_diag,
                     width=width, color='k', fill=False, ax=ax)
        ax.set_ylim(ymin, ymax)
        ax.set_yticks([ymin, chance, ymax])
        ax.set_yticklabels(['%.2f' % ymin, 'chance', '%.2f' % ymax])
        ax.plot([sel_time] * 2, [ymin, scores_off.mean(0)[idx]],
                color=colors[1], zorder=-2)
        #Add indicator
        ax.text(sel_time, ymin + .05 * np.ptp([ymin, ymax]),
                '%i ms' % (np.array(sel_time) * 1e3),
                color=colors[1], backgroundcolor='w', ha='center', zorder=-1)
        pretty_plot(ax)
        if ax != axes[-1]:
            ax.set_xticklabels([])
            ax.set_xlabel('')
            ax.spines['bottom'].set_visible(False)
    return axes