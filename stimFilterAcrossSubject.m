subjList = {}; % fill in names of subjects to run through

path = uigetdir(['Choose directory containing individual folders with files'...
    ' for each subject']);
out_path = uigetdir(['Choose directory containing output folders for each' ...
	' subject']);

for subjnum = 1:length(subjList)
    subj = subjList{subjnum};
    disp(['****WORKING ON SUBJECT ' subj '****']);
    
    loc_path = fullfile(path, subj);
    loc_outpath = fullfile(out_path, subj);
    
    if subjnum == 1
        params = stimFilterAllFilesOneSubject('path', loc_path, 'out_path', ...
            loc_outpath); % will require UI to set params for first run
    else
        stimProcessAllFilesOneSubject('path', loc_path, 'out_path', loc_outpath, ...
            'params', params);
    end
    clearvars -except subjlist subjnum params path out_path
end