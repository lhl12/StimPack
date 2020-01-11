function [outputArg1,outputArg2] = peakToTrough(dataFilt, tEpoch, tPkWin)

    % select the range for EPs from trial averages
    win = peakToTroughWindowGui(dataFilt, tEpoch);
    
    % find min and max from trial average
    twin = tEpoch >= win(1) & tEpoch <= win(2);
    chans = size(dataFilt, 2);
    sigWin = dataFilt(twin, :, :);
    
    avgMins = zeros(chans, 2);
    avgMaxes = zeros(chans, 2);
    for ch = 1:chans
        [locmin, mini] = findpeaks(-mean(sigWin(:, ch, :), 3), 'MinPeakProminence', 5e-6);
        [locmax, maxi] = findpeaks(mean(sigWin(:, ch, :), 3), 'MinPeakProminence', 5e-6);
        
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
    
    % run through individual trials
    f

end

