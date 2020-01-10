function [params] = stimFilterAllFilesOneSubject(varargin)
%STIMPROCESSALLFILESONESUBJECT runs through all of the files for one
%subject and does the referencing and smoothing

%   OPTIONAL INPUTS:
%   path: the folder containing all of the files for a subject of interest
%   out_path: the folder to save results to
%   params: a parameter structure with the following fields:
%       reference_mode: 'CAR' (common average reference), 'CMR', (common
%           median reference), '' (or any other input; no referencing)
%       params.smooth: bool determining if you would like to Savitsky-Golay
%           smooth the data
%       save_bool: bool determining if you would like to save filtered
%           results
%       basename: base file name (will save as outdir/basename00.mat)
    
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
        
        if strcmp(params.reference_mode, 'CAR')
            % common average
        elseif strcmp(params.reference_mode, 'CMR')
            % common median
        end
        
        if params.smooth
            % savitsky-golay
        end
        
        if params.downsample
            % downsample and adjust fs and tEpoch
        end
        
        if params.save_bool
            save(fullfile(out_path, [params.basename num '.mat']), 'dataProcessed', ...
                'fsData', 'tEpoch');
        end
        
    end
end
