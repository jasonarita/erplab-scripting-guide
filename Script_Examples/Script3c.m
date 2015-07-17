%Example 3c tutorial script
%Updated October 2012

subject_list = {'S1', 'S2', 'S3', 'S4', 'S5', 'S6'};
numsubjects = length(subject_list); % number of subjects
% parentfolder = '/Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/';
parentfolder = '~/Desktop/Test_Data/';

% Initialize the ALLERP structure
% ALLERP = buildERPstruct([]);
% CURRENTERP = 0;

for s=1:numsubjects 

subject = subject_list{s};
% subjectfolder = [parentfolder subject '/'];
subjectfolder = fullfile(parentfolder, subject);
fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);

    EEG = pop_loadset('filename',[subject '_EEG.set'],'filepath',subjectfolder);
    EEG = pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');
    EEG = pop_editset(EEG, 'setname', [subject '_Chan']);
    EEG = pop_saveset( EEG, 'filename', [subject '_Chan.set'],'filepath', subjectfolder);
    EEG = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'Newboundary', { -99 }, 'Stringboundary', { 'boundary' }, 'Warning', 'on' );
    EEG = pop_binlister( EEG , 'BDF', [parentfolder 'binlister_demo_1.txt'], 'ImportEL', 'no', 'Saveas', 'off', 'SendEL2', 'EEG', 'Warning', 'on' );
    EEG = pop_epochbin( EEG , [-200.0 800.0], 'pre');
    EEG = pop_artmwppth( EEG , 'Channel', 1:16, 'Flag', 1, 'Review', 'off', 'Threshold', 100, 'Twindow', [ -200 798], 'Windowsize', 200, 'Windowstep', 50 );
    [ALLEEG EEG CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    ERP = pop_averager( EEG , 'Criterion', 'good', 'Stdev', 'on' );
    ERP = pop_savemyerp(ERP, 'erpname', [subject '_ERP'], 'filename', [subject '_ERP.erp'], 'filepath', subjectfolder, 'warning', 'off');
    CURRENTERP = CURRENTERP + 1;
    ALLERP(CURRENTERP) = ERP;


end;

%Update EEGLAB and ERPLAB GUI
eeglab redraw;
erplab redraw;