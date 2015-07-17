%Example 3b tutorial script
%Updated October 2012

subject = 'S2';
parentfolder = '/Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/';

%Note the spaces before and after subject in the following line 
subjectfolder = [parentfolder subject '/'];


%Load dataset
EEG = pop_loadset('filename',[subject '_EEG.set'],'filepath',subjectfolder);

%Edit Channel locations
EEG=pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');
EEG = pop_editset(EEG, 'setname', [subject '_Chan']);

%Save Dataset
EEG = pop_saveset( EEG, 'filename', [subject '_Chan.set'],'filepath', subjectfolder);

%Create Eventlist
EEG = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'Newboundary', { -99 }, 'Stringboundary', { 'boundary' }, 'Warning', 'on' );

%Assign Bins with Binlister
EEG = pop_binlister( EEG , 'BDF', [parentfolder 'binlister_demo_1.txt'], 'ImportEL', 'no', 'Saveas', 'off', 'SendEL2', 'EEG', 'Warning', 'on' );

%Epoch dataset
EEG = pop_epochbin( EEG , [-200.0 800.0], 'pre');

%Moving window peak to peak Artifact Detection
EEG = pop_artmwppth( EEG , 'Channel', 1:16, 'Flag', 1, 'Review', 'off', 'Threshold', 100, 'Twindow', [ -200 798], 'Windowsize', 200, 'Windowstep', 50 );

%Average ERP
ERP = pop_averager( EEG , 'Criterion', 'good', 'Stdev', 'on' );

%Save ERP
ERP = pop_savemyerp(ERP, 'erpname', [subject '_ERP'], 'filename', [subject '_ERP.erp'], 'filepath', subjectfolder, 'warning', 'off');

%Update EEGLAB and ERPLAB GUI
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
ALLERP = ERP;
eeglab redraw
erplab redraw;
