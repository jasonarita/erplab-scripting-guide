% Example Script
% Steve Luck
% Updated October 2012
%
% Note: This example involves a specific path, and you will need to edit
% the path so that it specifies the correct folder for the S1_EEG.set file
% on your computer.

EEG = pop_loadset('filename','S1_EEG.set','filepath','/Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/S1/');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
eeglab redraw
