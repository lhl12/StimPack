function [params] = stimProcessAllFilesOneSubject(varargin)
%STIMPROCESSALLFILESONESUBJECT runs through all of the files for one
%subject and does the processing requested

%   OPTIONAL INPUTS:
%   path: the folder containing all of the files for a subject of interest
%   out_path: the folder to save results to
%   params: a parameter structure with the following fields:
%       var: a string of the variable name that you would like to extract
%           data from
%       epochs: bool determining if you want to epoch the data
%       pulses: bool determining if you want to pull individual pulses
%       adj: bool determining if you would like to adjust the trials
%           delimiters to match the artifact in the signal
%       fix: bool determining if you would like to adjust all trials by the
%           same amount
%       adj_samps: if fixing the adjustment, by how many samples would you
%           like to shift them all by
%       pre_pulse: time, in seconds, to inlcude before each pulse
%       post_pulse: time, in seconds, to include after each pulse
%       pre_burst: time, in seconds, to include before each burst
%       post_burst: time, in seconds, to include after each burst
%       save_bool: bool determining if you would like to save processed
%           results
%       basename: base file name (will save as outdir/basename00.mat)

%   OUTPUTS:
%   params: so GUI does not need to be rerun for each subject in loop
    
    p = inputParser;
    addParameter(p,'path', [], @isfolder);
    addParameter(p, 'out_path', [], @isfolder);
    addParameter(p, 'params', [], @isstruct);
    
    p.parse(varargin{:});
    
    path = p.Results.path;
    out_path = p.Results.out_path;
    params = p.Results.params;
    
    if isempty(path)
        path = uigetdir([], 'CHOOSE THE FOLDER CONTAINING SUBJECT DATA');
    end
    if isempty(out_path)
        out_path = uigetdir([], 'CHOSE THE FOLDER FOR DATA OUTPUT');
    end
    files = dir([path '\*.mat']);
    
    % loop through all files
    for filenum = 1:length(files)
        
        filename = files(filenum).name;
        % get file number
        num = regexp(filename, '\d*', 'Match');
        num = num{1};
        disp(['--LOADING ' filename '--'])
        
        if filenum == 1 && isempty(params)
            matObj = matfile(fullfile(path, filename));
            params = stimProcessGui(who(matObj));
        end
        
        load(fullfile(path, filename), 'Sing', params.var);
        dataStruct = eval(params.var); % consistent name for data regarless of type
        
        data = dataStruct.data(:, 1:8);
        fsData = dataStruct.info.SamplingRateHz;
        fsSing = Sing.info.SamplingRateHz;

        [burst_limits, pulse_idx, trial_voltage] = getStimIndices(Sing);
        if params.save_bool
            disp('saving trial info')
            save(fullfile(out_path, [params.basename num '.mat']), 'burst_limits', ...
                'pulse_idx', 'trial_voltage', 'fsData');
        end
        
        if params.epochs
            [data_epoched, epoch_indices, adj_by] = pullStimEpochs(data, burst_limits, ...
                fsData, fsSing, params.pre_burst, params.post_burst, ...
                'adjust',  params.adj, 'adj_by', params.adj_samps);
            tEpoch = -params.pre_burst:1/fsData:params.post_burst;
            if params.save_bool
                disp('saving epoched data')
                save(fullfile(out_path, [params.basename num '.mat']), 'data_epoched', ...
                'epoch_indices', 'tEpoch', 'adj_by', '-append');
            end
        end
        
        if params.pulses
            [stim_pulses, adj_by_all] = pullStimPulses(data, pulse_idx, fsData, ...
                fsSing, params.pre_pulse, params.post_pulse, 'adjust', ...
                params.adj, 'adj_by', params.adj_samps);
            tPulse = -params.pre_pulse:1/fsData:params.post_pulse;
            if params.save_bool
                disp('saving stim pulses')
                save(fullfile(out_path, [params.basename num '.mat']), 'stim_pulses', ...
                'adj_by_all', '-append', 'tPulse', '-v7.3');
            end
        end
        
    end
end

