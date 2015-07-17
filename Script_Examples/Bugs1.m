% Example Script for bugs
% Steve Luck
% UC Davis, October 2011
%

subject = 'S1';
parentfolder = '/Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/';
subjectfolder = [parentfolder subject ' /'];

%fprintf('subject="%s", filename="%s", subjectfolder="%s"\n', subject, [subject '_EEG.set'], subjectfolder);

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
ERP = pop_savemyerp(ERP, 'erpname', [subject '_ERP'], 'filename', [subjectfolder subject '_ERP.erp'], 'gui', 'erplab');
eeglab redraw;
