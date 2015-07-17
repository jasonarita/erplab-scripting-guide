% Example Script
% Steve Luck
% UC Davis, October 2011
%
% Note: This example requres that the file be in Matlab's current directory
% (or somwhere in the path)

EEG = pop_loadset('filename','S1_EEG.set');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
