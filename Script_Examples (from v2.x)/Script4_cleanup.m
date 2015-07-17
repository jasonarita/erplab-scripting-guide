    
% This defines the set of subjects
subject = {'S1', 'S2', 'S3', 'S4', 'S5', 'S6'};

% Path to the folder containing the current subject's data
home_path  = '/Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/';

% number of subjects
nsubj = length(subject); 

% Loop through all subjects
for s=1:nsubj
    
    % Path to the folder containing the current subject's data
    data_path  = [home_path subject{s} '/'];
    
    delete([data_path subject{s} '_Chan*']);
    delete([data_path subject{s} '_ERPs*']);
    delete([data_path subject{s} '_event*']);

end

fprintf('Cleanup done\n');