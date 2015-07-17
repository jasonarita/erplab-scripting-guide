% Example Script
% Steve Luck
% UC Davis, October 2011
%
% Note: This example involves a specific path, and you will need to edit
% the path so that it specifies the correct folder for the S1_EEG.set file
% on your computer.

%[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename','S1_EEG.set','filepath','/Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/S1/');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG=pop_chanedit(EEG, 'lookup','/Users/luck/Documents/Software_Development/eeglab9_0_8_6b/plugins/dipfit2.2/standard_BESA/standard-10-5-cap385.elp');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_editset(EEG, 'setname', 'S1_Chan');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_saveset( EEG, 'filename','S1_Chan.set','filepath','/Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/S1/');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_creabasiceventlist( EEG , 'Newboundary', { -99 }, 'Stringboundary', { 'boundary' }, 'Warning', 'on' );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
EEG = pop_binlister( EEG , 'BDF', '/Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/S1/binlister_demo_1.txt', 'ImportEL', 'no', 'Saveas', 'on', 'SendEL2', 'EEG', 'Warning', 'on' );
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = pop_epochbin( EEG , [-200.0 800.0], 'pre');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'gui','off'); 
EEG = pop_artmwppth( EEG , 'Channel', 1:16, 'Flag', 1, 'Threshold', 100, 'Twindow', [ -200 798], 'Windowsize', 200, 'Windowstep', 50 );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'gui','off');
ERP = pop_averager( ALLEEG , 'Criterion',1, 'DSindex',4, 'Stdev', 'on' );
ERP = pop_savemyerp(ERP, 'erpname', 'S1_ERP', 'filename', 'S1_ERP.erp', 'pathname', '/ Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/S1', 'warning', 'on');
eeglab redraw;
