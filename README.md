# StimPack
__Functions for processing and analyzing direct cortical stimulation data collected on the TDT, particularly for analysis of evoked potentials.__ Last edited: LL 01/07/2020

# Definitions
### pulse: 
an individual stimulation pulse (tested primarily on bipolar/biphasic pulses, but should be able to handle any).
### burst: 
a series of stimulation pulses delivered in sequence. These functions assume that anything 10 Hz or faster is a burst and anything slower than 10 Hz is a single-pulse trial.
### Sing: 
an output of all current (OpenEx, 01/2020) TDT protocols that involve stimulation. *Sing* is a record of when the TDT sends stimulation signals to the stim box, not of the stimulation output itself. For all tested protocols (DBS parameter sweep, sensory parameter sweep, sensory staircase, EP measure, EP screen, stim geometry), the stim impulses are recorded in channel one of Sing.data. *Will need to make alterations for functionality with paired pulse protocols.*


# SCRIPTS
### stimProcessAcrossSubjects: a wrapper for stimProcessAllFilesOneSubject
#### TO USE
Fill in subjList, a cell array, with the names of the subjects desired and name one file within each directory named for each subject. Each folder should only have raw files for processing.
### stimFilterAcrossSubjects: a wrapper for stimFilterAllFilesOneSubject
#### TO USE
Fill in subjList, a cell array, with the names of the subjects desired and name one file within each directory named for each subject. Each folder should only have pre-processed files for processing (i.e. files generated by the stimProcess scripts).

# HIGH LEVEL FUNCTIONS
#### stimProcessAllFilesOneSubject(): processes all files in one folder
#### OPTIONAL INPUTS:
* path: the folder containing all of the *raw* files for a subject of interest
* out_path: the folder to save results to
* params: a parameter structure with the following fields: (the output of stimProcessGui)
    * var: a string of the variable name that you would like to extract data from
    * epochs: bool determining if you want to epoch the data
    * pulses: bool determining if you want to pull individual pulses
    * adj: bool determining if you would like to adjust the trial delimiters to match the artifact in the signal
    * fix: bool determining if you would like to adjust all trials by the same amount
    * adj_samps: if fixing the adjustment, by how many samples would you like to shift them all by
    * pre_pulse: time, in seconds, to inlcude before each pulse
    * post_pulse: time, in seconds, to include after each pulse
    * pre_burst: time, in seconds, to include before each burst
    * post_burst: time, in seconds, to include after each burst
    * save_bool: bool determining if you would like to save processed results
    * basename: base file name (will save as outdir/basename00.mat)
##### if any inputs are unspecified, user input will be prompted
#### OUTPUTS:
* params (same as input, for if UI is used)

### stimFilterAllFilesOneSubject(): processes all files in one folder
#### OPTIONAL INPUTS:
* path: the folder containing all of the *processed* files for a subject of interest
* out_path: the folder to save results to
* params: a parameter structure with the following fields
      * reref_mode: '' (default; no rereferencing), 'mean' (common average reference), 'median', (common median reference), 'bipolarPairs' (1 v 2, 3 v 4, etc.), or 'bipolar' (1 v 2, 2 v 3, etc.)
      * smooth_bool: bool determining if you would like to use a Savitsky-Golay filter to smooth the data, defaults to false
      * order: order of SG filter, defaults to 3
      * framelen: framelength of SG filter, defaults to 51
      * downsample_bool: bool determining if you would like to downsample your data, defaults to false
      * downsample_by: factor to downsample data by, defaults to 2 (only if downsample_bool == true)
      * hp_bool/lp_bool/notch_bool: bools determining if you would like to highpass, lowpass, or notch (respectively), all default to false
      * hp/lp/notch: frequencies, in Hz, for highpass, lowpass, and center of notch (respectively), all default to []
      * artrem_bool: bool determining if you would like to run artifact removal on your data, defaults to false
      * artrem: a struct with parameters for artifact removal, defaults to empty unless artrem_bool == true
         * pre: time (in ms) to include before spike in template, defaults to 1
         * post: time (in ms) to include after spike in template
         * distanceMetricDbScan: either 'eucl' or 'corr'
         * bracketRange: for template building
         * onsetThreshold: minimum zscore (of differentiated signal) required to be considered an artifact
         * minPts: for template building
##### if any inputs are unspecified, user input will be prompted
#### OUTPUTS:
* params (same as input, for if UI is used)

# LOW-LEVEL FUNCTIONS
## For Epoching
### getStimIndices(): Pulls relevant stimulation information from TDT output *Sing*.
#### REQUIRED INPUTS
* Sing: an output of the TDT that indicates when the TDT sent the signal to stimulate to the stim box - not a recording of the stimulation itself, but the software's output
#### OUTPUTS
* burst_limits: the index of the first and last point of each burst (a trials x 2 matrix)
* pulse_idx: the indices of each individual pulse within a burst (a trials x 1 cell array, each cell contains a pulses x 1 matrix, indexing is *not* within the burst but over the full time series)
* trial_voltage: the voltage of stimulation (in mV) for each trial (a trials x 1 matrix)
#### ASSUMPTIONS:
* stim does not occur at exactly 10V
* within-burst frequency is greater than 10Hz
* at least 100ms is allowed between trials
* only one stimulation voltage is used within a trial/burst
* relevant Sing info is in first column (true of DBS parameter sweep, sensory parameter sweep, sensory staircase, EP measure, EP screen, stim geometry)

### pullStimEpochs(): pulls epochs of identical size from provided data based on provided limits and trial starts
#### REQUIRED INPUTS:
* data: data to be split into epochs (a time x channels array)
* burst_limits: the start indices of each stimulation burst, as generated by getStimIndices(). Will ignore everything except the first column
* fsData: the sampling rate of data
* fsSing: the sampling rate of the Sing TDT output that was used to generate burst_limits
* pre: the number of seconds to include in epoch prior to burst start
* post: the number of seconds to include in epoch after burst start (this will include the rest of the burst window to account for potential differences in burst length
#### OPTIONAL INPUTS:
* adjust: a boolean determining if you would like to adjust for differences between TDT stimulation signal and stimulation artifact in the data (defaults to false)
* adj_by: a round double stating the number of samples you want to use toadjust for differences between TDT stimulation signal and stimulation artifact in the data, for instance if you would like this value to be the same across all runs. If adjust is set to true and no adj_by is specified, adj_by is calculated based on estimates of the stim artifact in the data
#### OUTPUTS:
* data_epoched: the data split into epochs (a time x channels x trials array)
* epoch_indices: the indices used to pull epochs from the given data, accounting for sampling rate differences and adjustment for lag
* adj_by: the number of samples used to adjust between TDT stimulation signal and stimulation artifact in the data

### pullStimPulses(): A wrapper for pullStimEpochs() to pull individual pulses within a single burst
#### REQUIRED INPUTS:
* data: data to be split into pulses (a time x channels array, NOT epoched)
* pulse_idx: the indices of each individual pulse within a burst (a trials x 1 cell array, each cell contains a pulses x 1 matrix, indexing is *not* within the burst but over the full time series), as generated by getStimIndices()
* fsData: the sampling rate of data
* fsSing: the sampling rate of the Sing TDT output that was used to generate pulse_idx
* pre: the number of seconds to include in epoch prior to pulse start
* post: the number of seconds to include in epoch after pulse start (this will include the rest of the burst window to account for potential differences in burst length
#### OPTIONAL INPUTS:
* adjust: a boolean determining if you would like to adju""st for differences between TDT stimulation signal and stimulation artifact in the data (defaults to false)
* adj_by: a round double stating the number of samples you want to use toadjust for differences between TDT stimulation signal and stimulation artifact in the data, for instance if you would like this value to be the same across all runs. If adjust is set to true and no adj_by is specified, adj_by is calculated based on estimates of the stim artifact in the data
#### OUTPUTS:
* stim_pulses: the data surrounding each individual pulse, a trials x 1 cell array, with each cell containing a time x channels x pulses matrix
* adj_by: the number of samples used to adjust between TDT stimulation signal and stimulation artifact in the data for each trial, a  trials x 1 array
#### NOTES:
* this is not efficient code, but ensures that pulses are identified in the correct burst and in a way that should flexibly accomodate bursts with different numbers of stimulation pulses (only briefly tested the latter)
* if only one pulse per burst, just use pullStimEpochs (the only difference is the output format of the data)

## FOR FILTERING
### removeArtifacts(): A wrapper for David's artifact rejection package
#### REQUIRED INPUTS
* dataInt: epoched data
* fsData: sampling rate in Hz
#### OPTIONAL INPUTS:
* pre: time (in ms) to include before spike in template
* post: time (in ms) to include after spike in template
* distanceMetricDbScan: either 'eucl' or 'corr'
* bracketRange: for template building
* minPts: for template building
* onsetThreshold: minimum zscore required to be considered an artifact (of differential)
#### OUTPUTS:
* processedSig: despiked signal
* artrem: artifact removal outputs

### rereference_flex(): A function (adapted from David Caldwell) to rereference data in a variety of possible ways
#### REQUIRED INPUTS:
* data: either time x channels, or time x channels x trials
* mode: what type of rereferencing is requested, options are:
   * 'mean': subtracts the mean over all channels from each trial
   * 'median': subtracts the median over all channels from each trial
   * 'singleChan': subtracts the raw trace of one channel from each other channel for each trial (zeros out channelReference)
   * 'bipolarPair': subtract each odd electrode (i) from its neighboring even electrode (i + 1), zeroing out channel i and replacing channel i + 1 with this difference (output will have 1/2 the number of meaningful channels of input)
   * 'bipolar': subtract each electrode (i) from its neighbor (i + 1), replacing channel i with this difference (output will have 1 less meaningful channel than input)
   * 'selectedChannelsMean': similar to 'mean' but only takes the mean over select channels (channelsToUse)
   * 'selectedChannelsMedian': similar to 'median' but only takes the median over select channels (channelsToUse) 
#### OPTIONAL INPUTS:
* bad_channels: a list of bad channels (leaves "bad" channels untouched for output), defaults to none *currently need to specify separately, not included in GUI)*
* permuteOrder: order if need to permute, like [1 3 2], defaults to original order
* channelReference: if referencing to a single channel, whichbchannel, defaults to 1
* channelsToUse: if referencing to multiple (but not all) channels, which channels, a logical channels x 1 array, defaults to all
#### OUTPUTS:
* output: rereferenced data

### ecogFilter(): A function from GridLab code base for generic filtering (JDW2011)
#### REQUIRED INPUTS:
* signals: signals to be filtered.  If signals is an MxN array, the vectors of length M, indexed by the N dimension will be treated as independent signals and filtered as such.
* lnReject: a boolean value that, if true indicates that the signals should be filtered with notch filters centered around lnFreqs
* lnFreqs: the frequencies that will be used for notch filters if lnReject is true
* hp: a boolean value that, if true indicates that the signals should be filtered with a high pass filter
* hpFreq: the highpass cutoff frequency
* lp: a boolean value that, if true indicates that the signals should be filtered with a low pass filter
* lpFreq: the lowpass cutoff frequency
* fSamp; the sampling rate of signals
#### OPTIONAL INPUTS:
* filterOrder (optional): the filter order of the butterworth filter to be used. The default value is 4th order.
#### OUTPUTS:
* filteredSignals: the filtered signals

# GUIs
### stimProcessGui(): a GUI to choose parameters for multi-subject or within-subject batch processing
#### INPUTS:
* var_choice: a cell array containing strings with the names of all variables in one subject's files
#### OUTPUTS
* params: a parameter structure with the following fields:
    * var: a string of the variable name that you would like to extract data from (defaults to empty, which will crash the program)
    * epochs: bool determining if you want to epoch the data, defaults to false
    * pulses: bool determining if you want to pull individual pulses, defaults to false
    * adj: bool determining if you would like to adjust the trial delimiters to match the artifact in the signal, defaults to false
    * fix: bool determining if you would like to adjust all trials by the same amount, defaults to false
    * adj_samps: if fixing the adjustment, by how many samples would you like to shift them all by, defaults to NaN
    * pre_pulse: time, in seconds, to inlcude before each pulse, defaults to 1
    * post_pulse: time, in seconds, to include after each pulse, defaults to 2
    * pre_burst: time, in seconds, to include before each burst, defaults to .0045
    * post_burst: time, in seconds, to include after each burst, defaults to .0045
    * save_bool: bool determining if you would like to save processed results, defaults to true
    * basename: base file name (will save as outdir/basename00.mat), defaults to 'output'
    
### stimFilterGui(): a GUI to choose parameters for multi-subject or within-subject batch filtering
#### INPUTS:
* fsData: the sampling rate of the data in Hz
#### OUTPUTS:
* params: a parameter structure with the following fields
      * reref_mode: '' (default; no rereferencing), 'mean' (common average reference), 'median', (common median reference), 'bipolarPairs' (1 v 2, 3 v 4, etc.), or 'bipolar' (1 v 2, 2 v 3, etc.)
      * smooth_bool: bool determining if you would like to use a Savitsky-Golay filter to smooth the data, defaults to false
      * order: order of SG filter, defaults to 3
      * framelen: framelength of SG filter, defaults to 51
      * downsample_bool: bool determining if you would like to downsample your data, defaults to false
      * downsample_by: factor to downsample data by, defaults to 2 (only if downsample_bool == true)
      * hp_bool/lp_bool/notch_bool: bools determining if you would like to highpass, lowpass, or notch (respectively), all default to false
      * hp/lp/notch: frequencies, in Hz, for highpass, lowpass, and center of notch (respectively), all default to []
      * artrem_bool: bool determining if you would like to run artifact removal on your data, defaults to false
      * artrem: a struct with parameters for artifact removal, defaults to empty unless artrem_bool == true
         * pre: time (in ms) to include before spike in template, defaults to 1
         * post: time (in ms) to include after spike in template
         * distanceMetricDbScan: either 'eucl' or 'corr'
         * bracketRange: for template building
         * onsetThreshold: minimum zscore (of differentiated signal) required to be considered an artifact
         * minPts: for template building
