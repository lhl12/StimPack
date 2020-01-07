% load data
load('C:\Users\lhl12\Documents\MATLAB\DBS_ParamSweep\Data\Raw\50ad9\param_sweep-5.mat')
data = ECOG.data(:, 1:8);
fsData = ECOG.info.SamplingRateHz;
fsSing = Sing.info.SamplingRateHz;
pre = 1;
post = 2;
adjust = 1;
% get indices of trials
[burst_limits, pulse_idx, trial_voltage] = getStimIndices(Sing);
% epoch data
[data_epoched, epoch_indices, adj_by] = pullStimEpochs(data, burst_limits, ...
    fsData, fsSing, pre, post, 'adjust', adjust);
% get individual pulse data
[stim_pulses, adj_by_all] = pullStimPulses(data, pulse_idx, fsData, fsSing, ...
    .0025, .0025, 'adjust', adjust);