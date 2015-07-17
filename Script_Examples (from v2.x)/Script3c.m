% Example Script
% Steve Luck
% UC Davis, October 2011
%

% This defines the set of subjects
subject_list = {'S1', 'S2', 'S3', 'S4', 'S5', 'S6'};
numsubjects  = length(subject_list); % number of subjects
parentfolder = '/Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/';

% Loop through all subjects
for s=1:numsubjects 

    subject = subject_list{s};
    subjectfolder = [parentfolder subject '/'];
    fprintf('\n\n\n*** Processing subject %d (%s) ***\n\n\n', s, subject);

    
    EEG = pop_loadset('filename', [subject '_EEG.set'],'filepath', subjectfolder);
    %[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG=pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');
    %[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = eeg_checkset( EEG );
    EEG = pop_editset(EEG, 'setname', [subject '_Chan']);
    %[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    %EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename', [subject '_Chan.set'],'filepath', subjectfolder);
    %[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = pop_creabasiceventlist(EEG, '', {'boundary'}, {-99}, 1);
    %[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
    EEG = pop_binlister( EEG, [parentfolder 'binlister_demo_1.txt'], 'no', '', 0, [], [], 0, 0, 0);
    %[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
    EEG = pop_epochbin( EEG , [-200.0  800.0],  'pre');
    %[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'gui','off'); 
    EEG = pop_artmwppth( EEG, [-200  798], 100, 200, 50,  1:16,  1);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'gui','off');
    ERP = pop_averager( EEG,1, 1, 1 );
    ERP = pop_savemyerp(ERP, 'erpname', [subject '_ERP'], 'filename', [subjectfolder subject '_ERP.erp']);

end;

    eeglab redraw;
