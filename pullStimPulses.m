function [stimPulses] = pullStimPulses(data, pulse_idx, fsData, fsSing, pre, post, adjust)
%PULLSTIMPULSES Summary of this function goes here
%   Detailed explanation goes here

    %%
    stimPulses = cell(size(pulse_idx));
    numsamps = length(find(data))/sum(cellfun(@length, pulse_idx));
    
    for trl = 1:length(pulse_idx)
        
        pid = pulse_idx{trl};
        lims = [pid pid + numsamps];
        stimPulses{trl} = pullStimEpochs(data, lims, fsData, fsSing, pre, post, adjust);
        
    end

end

