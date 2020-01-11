function output = rereference_flex(data, mode, badChannels, permuteOrder, channelReference, channelsToUse)
% Function to either common average, or median rereference,

%   REQUIRED INPUTS:
%       data: either time x channels, or time x channels x trials
%       mode: what type of rereferencing is requested, options are:
%           'mean': subtracts the mean over all channels from each trial
%           'median': subtracts the median over all channels from each trial
%           'singleChan': subtracts the raw trace of one channel from each
%               other channel for each trial (zeros out channelReference)
%           'bipolarPair': subtract each odd electrode (i) from its
%               neighboring even electrode (i + 1), zeroing out channel i
%               and replacing channel i + 1 with this difference (output
%               will have 1/2 the number of meaningful channels of input)
%           'bipolar': subtract each electrode (i) from its neighbor (i +
%               1), replacing channel i with this difference (output will
%               have 1 less meaningful channel than input)
%           'selectedChannelsMean': similar to 'mean' but only takes the
%               mean over select channels (channelsToUse)
%           'selectedChannelsMedian': similar to 'median' but only takes
%               the median over select channels (channelsToUse) 
%   OPTIONAL INPUTS:
%       bad_channels: a list of bad channels (leaves "bad" channels
%           untouched for output), defaults to none
%       permuteOrder: order if need to permute, like [1 3 2], defaults to
%           original order
%       channelReference: if referencing to a single channel, which
%           channel, defaults to 1
%       channelsToUse: if referencing to multiple (but not all) channels,
%           which channels, a logical channels x 1 array, defaults to all

% David. J.Caldwell 6.12.2017

if (~exist('badChannels','var') || isempty(badChannels))
    badChannels = []; % default no bad channels, this overrides good channels
end

if (~exist('permuteOrder','var') || isempty(permuteOrder))
    permuteOrder = 1:ndims(data);
end

if (~exist('channelReference','var')|| isempty(channelReference))
    channelReference = 1; % default to rereference against single channel if need be
end

if (~exist('channelsToUse','var') || isempty(channelsToUse))
    channelsToUse = true(size(data,2),1);
end

data = permute(data,permuteOrder);

output = data; % default output of data with permute order

channelMask = true(size(data,2),1);
channelMask(badChannels) = 0;

switch(mode)
    case 'mean'
        avg = mean(data(:,channelMask,:),2);
        avg = repmat(avg, 1, size(data(:,channelMask,:),2));
        output(:,channelMask,:) = data(:,channelMask,:) - avg;
        
        % shift data if needed
        output = permute(output,permuteOrder);
    case 'median'
        med = median(data(:,channelMask,:),2);
        med = repmat(med, 1, size(data(:,channelMask,:),2));
        output(:,channelMask,:) = data(:,channelMask,:) - med;
        
        % shift data if needed
        output = permute(output,permuteOrder);
        
    case 'singleChan'
        chan = data(:,channelReference,:);
        repmatChan = repmat(chan,1,size(data,2));
        output = data - repmatChan;
        output = permute(output,permuteOrder);
        
        
    case 'bipolarPair' % do 1 vs 2, 3 vs 4, etc
        for i = 1:2:size(data,2)
            chanOdd = data(:,i,:);
            chanEven = data(:,i+1,:);
            newChan = chanEven-chanOdd;
            output(:,i,:) = zeros(size(newChan));
            output(:,i+1,:) = newChan;
        end
        
        output = permute(output,permuteOrder);
        
        
    case 'bipolar' % do 1 vs 2, 2 vs 3, etc
        for i = 1:size(data, 2) - 1 % for R side , do 8:end
            chanOdd = data(:,i,:);
            chanEven = data(:,i+1,:);
            newChan = chanEven-chanOdd;
            output(:,i,:) = newChan;
        end
        output(:,end,:) = zeros(size(newChan));
        output = permute(output,permuteOrder);
        
    case 'selectedChannelsMean'
        avg = mean(data(:,channelsToUse,:),2);
        avg = repmat(avg, 1, size(data(:,channelMask,:),2));
        output(:,channelMask,:) = data(:,channelMask,:) - avg;
        output = permute(output,permuteOrder);
        
    case 'selectedChannelsMedian'
        avg = median(data(:,channelsToUse,:),2);
        avg = repmat(avg, 1, size(data(:,channelMask,:),2));
        output(:,channelMask,:) = data(:,channelMask,:) - avg;
        output = permute(output,permuteOrder);
        
    case 'none'
        output = data;
        
    case ''
        output = data;
        
end