function [processedSig, artrem] = removeArtifacts(dataInt, fsData, varargin)
%REMOVEARTIFACTS Wraps David's artifact rejection package

%   REQUIRED INPUTS
%       dataInt: epoched data
%       fsData: sampling rate in Hz

%   OPTIONAL INPUTS:
%       pre: time (in ms) to include before spike in template
%       post: time (in ms) to include after spike in template
%       distanceMetricDbScan: either 'eucl' or 'corr'
%       bracketRange: for template building
%       minPts: for template building
%       onsetThreshold: minimum zscore required to be considered an
%           artifact (of differential)

%   OUTPUTS:
%       processedSig: despiked signal
%       artrem: artifact removal outputs

    p = inputParser;
    addParameter(p, 'pre', 1);
    addParameter(p, 'post', .2);
    addParameter(p, 'distanceMetricDbscan', 'eucl');
    addParameter(p, 'bracketRange', -2:6);
    addParameter(p, 'minPts', 2);
    addParameter(p, 'onsetThreshold', 5);
    
    p.parse(varargin{:});
    p = p.Results;
    
    pre = p.pre;
    post = p.post;
    distanceMetricDbscan = p.distanceMetricDbscan;
    bracketRange = p.bracketRange;
    minPts = p.minPts;
    onsetThreshold = p.onsetThreshold;

    minDuration = 0.250; % minimum duration of artifact in ms
    dataInt = 4 * dataInt; % do we have to do this?

    type = 'dictionary'; % machine learning paradigm to use

    useFixedEnd = 0; % we don't want to fix the trial emnd 
    fixedDistance = 4; % in ms
    plotIt = 0; % it'll spit out a lot of extra plots if you set this to 1

    % these are the metrics sused if the dictionary method is selected. The
    % options are 'eucl', 'cosine', 'corr', for either euclidean distance,
    % cosine similarity, or correlation for clustering and template matching.
    distanceMetricSigMatch = 'corr';
    amntPreAverage = 3;
    normalize = 'preAverage';
%     onsetThreshold = 5;
    onsetThreshold2 = 1.5;
    recoverExp = 1;
    threshVoltageCut = 75;
    threshDiffCut = 75;
    expThreshVoltageCut = 75;
    expThreshDiffCut = 75;
    chanInt = 1; % use chan 1 for plots
    minClustSize = 1;
    outlierThresh = 0.95; % don't worry too much about most of these, for the machine learning

    stimChans = 17:18; % because the stim is through DBS, not one of our ECoG chans
    
    zs = squeeze(sum(sum(abs(zscore(diff(dataInt))) > onsetThreshold)));
    noArt = zs < 10;
    tEpoch = -1:1/fsData:2;
    
    processedSig = NaN(size(dataInt));
    processedSig(:, :, noArt) = dataInt(:, :, noArt);
    
    % ok now we feed all of this into David's code
    [processedSig(:,  :, ~noArt), artrem.templateDictCell, artrem.templateTrial, artrem.startInds,...
        artrem.endInds, artrem.maxLocation] = analyFunc.template_subtract(dataInt(:, :, ~noArt),'type', type,...
        'fs', fsData, 'plotIt', plotIt, 'pre', pre, 'post', post, 'stimChans', stimChans,...
        'useFixedEnd', useFixedEnd, 'fixedDistance', fixedDistance,...
        'distanceMetricDbscan', distanceMetricDbscan,'distanceMetricSigMatch', distanceMetricSigMatch,...
        'recoverExp', recoverExp,'normalize', normalize,'amntPreAverage', amntPreAverage,...
        'minDuration', minDuration,'bracketRange', bracketRange,'threshVoltageCut', threshVoltageCut,...
        'threshDiffCut', threshDiffCut,'expThreshVoltageCut', expThreshVoltageCut,...
        'expThreshDiffCut', expThreshDiffCut, 'onsetThreshold', onsetThreshold, 'chanInt', chanInt,...
        'minPts', minPts, 'minClustSize', minClustSize, 'outlierThresh', outlierThresh):%,...
%         'onsetThreshold2', onsetThreshold2); % I made a change to David's
%         code a long time ago and idk if it is really necesarry
    
%     badTrials = badtrialgui(processedSig, tEpoch);
end

