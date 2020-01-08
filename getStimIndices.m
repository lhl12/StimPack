function [burst_limits, pulse_idx, trial_voltage] = getStimIndices(Sing)
%EPOCHSTIMDATA pulls relevant stimulation information from TDT outputs

%   INPUTS:
%   Sing: an output of the TDT that indicates when the TDT sent the signal
%       to stimulate to the stim box - not a recording of the stimulation
%       itself, but the software's output

%   OUTPUTS:
%   burst_limits: the index of the first and last point of each burst (a
%       trials x 2 matrix)
%   pulse_idx: the indices of each individual pulse within a burst (a
%       trials x 1 cell array, each cell contains a pulses x 1 matrix,
%       indexing is *not* within the burst but over the full time series)
%   trial_voltage: the voltage of stimulation (in mV) for each trial (a
%       trials x 1 matrix)

%   ASSUMPTIONS:
%   -stim does not occur at exactly 10V
%   -within-burst frequency is greater than 10Hz
%   -at least 100ms is allowed between trials
%   -only one stimulation voltage is used within a trial/burst
%   -relevant Sing info is in first column

    %% Standardize stimulation markers
    % this makes the Sing from staircase and EP_Measure match the Sing from
    % paramSweep: no stim = 0, stim on = |voltage| of stim output
    
    sing = abs(Sing.data(:, 1)); % pulls TDT record of stim impulse
    fsData = Sing.info.SamplingRateHz;
    
    % staircase and EP_Measure data have a start/end value of 10000 - this
    % should be higher than any voltage we use (!) so zero out all values
    % that are equal to 10000
    sing(sing == 10000) = 0;
    
    %% Get trial indices

    pks = find(sing);
    diff_pks = diff(pks);
    
    % defines a burst as a group of stimulation pulses that are within
    % 100ms of each other (i.e. 10Hz stimulation or faster) - each burst
    % defines one trial
    % bursts start at the first time point the TDT signals for stim and end
    % at the last time point the TDT signals for stim
    burst_limits = [[pks(1); pks(find(diff_pks >= fsData/10) + 1)], ... % start of burst
        [pks(diff_pks >= fsData/10); pks(end)]]; % end of burst
    num_trials = length(burst_limits);
    
    pulse_idx = cell(num_trials, 1);
    trial_voltage = zeros(num_trials, 1);
    for trl = 1:num_trials
        loc = sing(burst_limits(trl, 1):burst_limits(trl, 2));
        locpks = find(loc);
        diff_locpks = diff(locpks);
        % saves indices of each pulse, indexed over the full time series
        pulse_idx{trl} = [locpks(1); locpks(find(diff_locpks ~=1) + 1)] + ...
            burst_limits(trl, 1) - 1; %ERROR
        % saves voltage of stimulation for this trial (in mV)
        trial_voltage = median(loc(locpks));
    end
    
end