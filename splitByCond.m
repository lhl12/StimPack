function [splitData, stims] = splitByCond(dataFilt, stimLevels)
% SPLITDATA splits data by stimulation condition

%   INPUTS:
%   dataFilt: filtered data in a time x chans x trials array
%   stimLevel: a 1 x trials array with discrete doubles for each stim
%       condition

%   OUTPUTS:
%   splitData: a 1 x conditions cell array with time x chans x trials
%       arrays in each with the data for each condition type

%     stims = unique(vertcat(stimLevels{:, 2}));
%     stimBool = vertcat(stimLevels{:, 2}) == stims';
    stims = unique(stimLevels);
    stimBool = stimLevels == stims';
    
    splitData = cell(1, length(stims));
    
    for ii = 1:length(stims)
        splitData{ii} = dataFilt(:, :, stimBool(:, ii));
    end

end

