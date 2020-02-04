function [p2t, allMins, allMinsLat, allMaxes, allMaxesLat] = ...
    peakToTrough(dataFilt, tEpoch, fsData)

    % select the range for EPs from trial averages
    win = peakToTroughWindowGui(mean(dataFilt, 3), tEpoch);
    
    % find min and max from trial average
    twin = tEpoch >= win(1) & tEpoch <= win(2);
    chans = size(dataFilt, 2);
    sigWin = dataFilt(twin, :, :);
    
    avgMins = zeros(chans, 2);
    avgMaxes = zeros(chans, 2);
    for ch = 1:chans
        [locmin, mini] = findpeaks(-mean(sigWin(:, ch, :), 3), 'MinPeakProminence', 2.5e-6);
        [locmax, maxi] = findpeaks(mean(sigWin(:, ch, :), 3), 'MinPeakProminence', 2.5e-6);
        
        locmin = -locmin;
        
        [~, minmin] = min(locmin);
        [~, maxmax] = max(locmax);
        
        avgMins(ch, :) = [locmin(minmin) mini(minmin)];
        avgMaxes(ch, :) = [locmax(maxmax) maxi(maxmax)];
    end
    
    % define windows: defaults to 10% of total window length
    locWin = (win(2) - win(1))*.1;
    locWinSamps = round(fsData*locWin);
    minWin = [avgMins(:, 2) - locWinSamps avgMins(:, 2) + locWinSamps];
    maxWin = [avgMaxes(:, 2) - locWinSamps avgMaxes(:, 2) + locWinSamps];
    
    % run through individual channels
    allMins = nan(size(sigWin, 3), size(sigWin, 2));
    allMaxes = nan(size(sigWin, 3), size(sigWin, 2));
    allMinsLat = nan(size(sigWin, 3), size(sigWin, 2));
    allMaxesLat = nan(size(sigWin, 3), size(sigWin, 2));
    for ch = 1:size(sigWin, 2)
        locWinMin = squeeze(sigWin(minWin(ch, 1):minWin(ch, 2), ch, :));
        locWinMax = squeeze(sigWin(maxWin(ch, 1):maxWin(ch, 2), ch, :));
        
        for trl = 1:size(locWinMin, 2)
%             [allMins(trl, ch), allMinsLat(trl, ch)] = min(locWinMin(:, trl));
%             [allMaxes(trl, ch), allMaxesLat(trl, ch)] = max(locWinMax(:, trl));
            
            [m, l, ~, p] = findpeaks(-locWinMin(:, trl));
            [~, i] = max(p);
            if ~isempty(i)
                allMins(trl, ch) = -m(i);
                allMinsLat(trl, ch) = l(i);
            end
            
            [m, l, ~, p] = findpeaks(locWinMax(:, trl));
            [~, i] = max(p);
            if ~isempty(i)
                allMaxes(trl, ch) = m(i);
                allMaxesLat(trl, ch) = l(i);
            end
            
        end
        
    end
    
    p2t = allMaxes - allMins;

end

