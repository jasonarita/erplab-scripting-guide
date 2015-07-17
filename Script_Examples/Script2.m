% Example Script
% Steve Luck
% Updated October 2012
%
% Note: This example requires that Matlab's current folder contains the S1_EEG.set file

EEG = pop_loadset('filename','S1_EEG.set');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
eeglab redraw
