function [outputArg1,outputArg2] = stimProcessAllFilesOneSubject(varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    path = uigetdir([], 'CHOOSE THE FOLDER CONTAINING SUBJECT DATA');
    files = dir([path '\*.mat']);
    
    % loop through all files
    for filenum = 1%:length(files)
        
        filename = files(filenum).name;
        disp(['--LOADING ' filename '--'])
        if filenum == 1
            matObj = matfile(fullfile(path, filename));
            params = stimProcessGui(who(matObj));
        end
        
        load(fullfile(path, filename), 'Sing', params.var);
        dataStruct = eval(params.var); % consistent name for data regarless of type
        
        data = dataStruct.data(:, 1:8);
        fsData = dataStruct.info.SamplingRateHz;
        fsSing = Sing.info.SamplingRateHz;

        [burst_limits, pulse_idx, trial_voltage] = getStimIndices(Sing);
        save(fullfile(path, 'test.mat'), 'burst_limits', 'pulse_idx');
        
        if params.epochs
            [data_epoched, epoch_indices, adj_by] = pullStimEpochs(data, burst_limits, ...
                fsData, fsSing, params.pre_burst, params.post_burst, ...
                'adjust',  params.adj, 'adj_by', params.adj_samps);
            save(fullfile(path, 'test.mat'), 'data_epoched', 'epoch_indices', ...
                'adj_by', '-append');
        end
        
        if params.pulses
            [stim_pulses, adj_by_all] = pullStimPulses(data, pulse_idx, fsData, ...
                fsSing, params.pre_pulse, params.post_pulse, 'adjust', ...
                params.adj, 'adj_by', params.adj_samps);
            save(fullfile(path, 'test.mat'), 'stim_pulses', 'adj_by_all', '-append');
        end
        
    end
end

