function [params] = stimFilterAllFilesOneSubject(varargin)
%STIMPROCESSALLFILESONESUBJECT runs through all of the files for one
%subject and does the referencing and smoothing, and artifact removal if
%desired

%   OPTIONAL INPUTS:
%   path: the folder containing all of the files for a subject of interest
%   out_path: the folder to save results to
%   params: a parameter structure with the following fields: (the output of
%   stimFilterGui)
%       reference_mode: '' (no rereferencing), 'mean' (common average reference), 
%           'median', (common median reference), 'bipolarPairs' (1 v 2, 3 v
%           4, etc.), or 'bipolar' (1 v 2, 2 v 3, etc.)
%       smooth_bool: bool determining if you would like to Savitsky-Golay
%           smooth the data
%       order: order for SG filter
%       framelen: framelength for SG
%       downsample_bool: bool determining if you would like to downsample
%       downsample_by: factor by which you would like to downsample
%       save_bool: bool determining if you would like to save filtered
%           results
%       basename: base file name (will save as outdir/basename00.mat)
%       hp_bool, lp_bool, notch_bool: bool determining if you will
%           highpass, lowpass, and notch (+ 2 harmonics) respectively
%       hp, lp, notch: numbers in Hz specifying highpass and lowpass cutoff
%           frequency and notch center frequency
%       artrem_bool: bool detrtmining if artifact removal should be run
%       artrem: parameters to use for artifact removal

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
    for filenum = 1%:length(files)
        
        filename = files(filenum).name;
        % get file number
        num = regexp(filename, '\d*', 'Match');
        num = num{1};
        disp(['--LOADING ' filename '--'])

        load(fullfile(path, filename), 'dataEpoched', 'fsData', 'tEpoch');
        
        dataFilt = dataEpoched;
        
        % David's artifact removal package must be on your Matlab path
        % NOTE: currently includes a legacy 4*data, do we need that still?
        if params.artrem_bool
            if isempty(fields(p.artrem))
                [dataFilt, artrem] = removeArtifacts(dataFilt, fsData);
            else
                [dataFilt, artrem] = removeArtifacts(dataFilt, fsData, 'pre', ...
                    params.artrem.pre, 'post', params.artrem.post, 'distanceMetricDbScan', ...
                    params.artrem.distanceMetricDbScan, 'bracketRange', ...
                    params.artrem.bracketRange, 'minPts', params.artrem.minpts,...
                    'onsetThreshold', params.artrem.onsetThreshold);
            end
        end
        
        if ~isempty(params.reref_mode)
            dataFilt = rereference_flex(dataFilt, params.reref_mode); % ADD BAD CHANNEL FUNCTIONALITY
        end
        
        if params.smooth
            dataFilt = sgolayfilt_complete(dataFilt, params.order, params.framelen);
        end
        
        if params.downsample
            % new sampling rate
            fsDataNew = round(fsData/params.downsample_by);
            % first, lowpass to avoid aliasing
            dataFilt = ecogFilter(dataFilt, 0, [], 0, [], 1, round(fsDataNew/2), ...
                fsData); % defaults to order of 4
            dataFilt = downsample(dataFilt, params.downsample_by);
            fsData = fsDataNew;
            tEpoch = (1:size(dataFilt, 1))/fsData + min(tEpoch);
        end
        
        if params.lp_bool || params. hp_bool || params.notch_bool
            dataFilt = ecogFilter(dataFilt, params.lp_bool, params.lp, ...
                params.hp_bool, params.hp, params.notch_bool, [params.notch, ...
                params.notch*2, params.notch*3], fsData);
        end
        
        if params.save_bool
            if params.artrem_bool
                save(fullfile(out_path, [params.basename num '.mat']), ...
                    'dataFilt', 'fsData', 'tEpoch', 'artrem');
            else
                save(fullfile(out_path, [params.basename num '.mat']), ...
                    'dataFilt', 'fsData', 'tEpoch');
            end
        end
        
    end
end
