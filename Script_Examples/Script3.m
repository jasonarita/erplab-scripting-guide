%Example 3 Script
%Requires that the data are stored in the folder named below
%Updated October 2012

%Filepath: /Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/S1/
%Filename: filename

%Load dataset
EEG = pop_loadset('filename','S1_EEG.set','filepath','/Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/S1/');

%Edit Channel locations
EEG = pop_chanedit(EEG, 'lookup','/Users/luck/Documents/Software_Development/eeglab9_0_8_6b/plugins/dipfit2.2/standard_BESA/standard-10-5-cap385.elp');
EEG = pop_editset(EEG, 'setname', 'S1_Chan');

%Save Dataset
EEG = pop_saveset( EEG, 'filename','S1_Chan.set','filepath','/Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/S1/');

%Create Eventlist
EEG = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'Newboundary', { -99 }, 'Stringboundary', { 'boundary' }, 'Warning', 'on' );

%Assign Bins with Binlister
EEG = pop_binlister( EEG , 'BDF', '/Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/S1/binlister_demo_1.txt', 'ImportEL', 'no', 'Saveas', 'on', 'SendEL2', 'EEG', 'Warning', 'on' );

%Epoch dataset
EEG = pop_epochbin( EEG , [-200.0 800.0], 'pre');

%Moving window peak to peak Artifact Detection
EEG = pop_artmwppth( EEG , 'Channel', 1:16, 'Flag', 1, 'Review', 'off', 'Threshold', 100, 'Twindow', [ -200 798], 'Windowsize', 200, 'Windowstep', 50 );

%Average ERP
ERP = pop_averager( EEG , 'Criterion', 'good', 'Stdev', 'on', 'Warning', 'on' );

%Save ERP
ERP = pop_savemyerp(ERP, 'erpname', 'S1_ERPs', 'filename', 'S1_ERPs.erp', 'filepath', '/Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/S1', 'warning', 'on');                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         




