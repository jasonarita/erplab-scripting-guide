% Example Script
% Steve Luck, Eric Foo, & Javier Lopez-Calderon
% UC Davis, Updated October 2012

% Clear memory and the command window
clear
clc

% Initialize the ALLERP structure and CURRENTERP
ALLERP = buildERPstruct([]);
CURRENTERP = 0;

% This defines the set of subjects
subject_list = {'S1', 'S2', 'S3', 'S4', 'S5', 'S6'};
nsubj = length(subject_list); % number of subjects

% Path to the parent folder, which contains the data folders for all subjects
home_path  = '/Users/luck/Documents/Software_Development/ERPLAB_Toolbox/Test_Data/';

% Set the save_everything variable to 1 to save all of the intermediate files to the hard drive
% Set to 0 to save only the initial and final dataset and ERPset for each subject
save_everything  = 1;

% Set the plot_PDFs variable to 1 to create PDF files with the waveforms
% for each subject (set to 0 if you don't want to create the PDF files).
plot_PDFs = 1;

% Loop through all subjects
for s=1:nsubj
    
    fprintf('\n******\nProcessing subject %s\n******\n\n', subject_list{s});

    % Path to the folder containing the current subject's data
    data_path  = [home_path subject_list{s} '/'];

    % Check to make sure the dataset file exists
    % Initial filename = path plus Subject# plus _EEG.set
    sname = [data_path subject_list{s} '_EEG.set'];
    if exist(sname, 'file')<=0
        
            fprintf('\n *** WARNING: %s does not exist *** \n', sname);
            fprintf('\n *** Skip all processing for this subject *** \n\n');

    else


        %
        % Load original dataset
        %
        fprintf('\n\n\n**** %s: Loading dataset ****\n\n\n', subject_list{s});
        EEG = pop_loadset('filename', [subject_list{s} '_EEG.set'], 'filepath', data_path);



        %
        % Add the channel locations
        % We're assuming the file 'standard-10-5-cap385.elp' is somewhere
        % in the path.  This can be copied from
        % plugins/dipfit2.2/standard_BESA/ inside the eeglab
        % folder.
        %
        fprintf('\n\n\n**** %s: Adding channel location info ****\n\n\n', subject_list{s});
        EEG = pop_chanedit(EEG, 'lookup','standard-10-5-cap385.elp');
        % Save dataset with _Chan suffix instead of _EEG
        EEG.setname = [subject_list{s} '_Chan']; % name for the dataset menu
        if (save_everything)
            EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', data_path);
        end


        %
        % Create EVENTLIST and save (pop_editeventlist adds _elist suffix)
        %
        fprintf('\n\n\n**** %s: Creating eventlist ****\n\n\n', subject_list{s});
        EEG = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'Newboundary', { -99 }, 'Stringboundary', { 'boundary' }, 'Warning', 'on' );
        EEG.setname = [EEG.setname '_elist']; % name for the dataset menu

        if (save_everything) 
            EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', data_path);
        end



        %
        % High-pass filter the EEG
        % Channels = 1 to 16; High-pass cutoff at 0.1 Hz;
        % No lowpass filter; Order of the filter = 2.
        % Type of filter = "Butterworth"; Remove DC offset; Filter
        % "between" boundary events
        %
        fprintf('\n\n\n**** %s: High-pass filtering EEG at 0.1 Hz ****\n\n\n', subject_list{s});               
        EEG  = pop_basicfilter( EEG,  1:16 , 'Cutoff', 0.1, 'Design', 'butter', 'Filter', 'highpass', 'Order',  2, 'RemoveDC', 'on' );
        EEG.setname = [EEG.setname '_hpfilt'];
        if (save_everything) 
            EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', data_path);               
        end



        %
        % Use Channel operations to insert a bipolar EOG channel
        % and re-reference to the average of the earlobes
        % Equations are stored in 'chanops_reref_biveog.txt', which
        % must be in the home directory for the experiment.
        % Save output with _ref suffix.
        %
        EEG = pop_eegchanoperator(EEG, [home_path 'chanops_reref_biveog.txt']);
        EEG.setname = [EEG.setname '_ref'];
        if (save_everything) 
            EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', data_path);
        end

        %
        % Use Binlister to sort the bins and save with _bins suffix
        % We are assuming that 'binlister_demo_1.txt' is present in the
        % home folder.
        %
        fprintf('\n\n\n**** %s: Running BinLister ****\n\n\n', subject_list{s});        
        EEG  = pop_binlister( EEG , 'BDF', [home_path 'binlister_demo_1.txt'], 'ImportEL', 'no', 'Saveas', 'off', 'SendEL2', 'EEG', 'Warning', 'off' );
        EEG.setname = [EEG.setname '_bins'];
        if (save_everything) 
            EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', data_path);
        end

        %
        % Extracts bin-based epochs (200 ms pre-stim, 800 ms post-stim. Baseline correction by pre-stim window)
        % Then save with _be suffix
        %
        fprintf('\n\n\n**** %s: Bin-based epoching ****\n\n\n', subject_list{s});
        EEG = pop_epochbin( EEG , [-200.0  800.0],  'pre');
        EEG.setname = [EEG.setname '_epochs'];
        if (save_everything) 
            EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', data_path); 
        end



        % Two rounds of artifact detection, then export eventlist just for fun
        % Save the processed EEG to disk because the next step will be averaging
        fprintf('\n\n\n**** %s: Artifact detection (moving window peak-to-peak and step function) ****\n\n\n', subject_list{s});               
        %
        % Artifact detection. Moving window. Test window = [-200
        % 798]; Threshold = 100 uV; Window width = 200 ms;
        % Window step = 50 ms; Channels = 1 to 17; Flags to be activated = 1 & 4
        %
        EEG = pop_artmwppth( EEG , 'Channel',  1:17, 'Flag', [ 1 4], 'Review', 'off', 'Threshold',  100, 'Twindow', [ -200 798], 'Windowsize',  200, 'Windowstep',  50 );
        %
        % Artifact detection. Step-like artifacts in the bipolar
        % VEOG channel (channel 14, created earlier with Channel Operations)
        % Threshold = 30 uV; Window width = 400 ms;
        % Window step = 10 ms; Flags to be activated = 1 & 3
        EEG = pop_artstep( EEG , 'Channel',  14, 'Flag', [ 1 3], 'Review', 'off', 'Threshold',  30, 'Twindow', [ -200 798], 'Windowsize',  400, 'Windowstep',  10 );
        EEG.setname = [EEG.setname '_ar'];
        EEG = pop_saveset(EEG, 'filename', [EEG.setname '.set'], 'filepath', data_path);
        EEG = pop_exporteegeventlist(EEG, [data_path subject_list{s} '_eventlist_ar.txt']);

        % Report percentage of rejected trials (collapsed across all bins)
        artifact_proportion = getardetection(EEG);
        fprintf('%s: Percentage of rejected trials was %1.2f\n', subject_list{s}, artifact_proportion);

        
        %
        % Averaging. Only good trials.  Include standard deviation.  Save to disk.
        %
        fprintf('\n\n\n**** %s: Averaging ****\n\n\n', subject_list{s});               
        ERP = pop_averager( EEG, 'Criterion', 'good', 'Stdev', 'on');
        ERP.erpname = [subject_list{s} '_ERPs'];  % name for erpset menu
        pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', [ERP.erpname '.erp'], 'filepath', data_path, 'warning', 'off');


        %
        % Filtering ERP. Channels = 1 to 17; No high-pass;
        % Lowpass cutoff at 30 Hz; Order of the filter = 2.
        % Type of filter = "Butterworth"; Do not remove DC offset
        %
        fprintf('\n\n\n**** %s: Low-pass filtering ERP at 30 Hz ****\n\n\n', subject_list{s});               
        ERP = pop_filterp( ERP,1:17 , 'Cutoff',30, 'Design', 'butter', 'Filter', 'lowpass', 'Order',2 ); 
        ERP.erpname = [ERP.erpname '_30Hz'];  % name for erpset menu
        if (save_everything) 
            pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', [ERP.erpname '.erp'], 'filepath', data_path, 'warning', 'off');
        end


        %
        % Bin Operations. Create a difference wave and save with _diff suffix
        % Do this on the unfiltered data, so first reload unfiltered file
        % Then do a second round of bin operations and save with _plus suffix
        %
        fprintf('\n\n\n**** %s: Bin Operations (two passes) ****\n\n\n', subject_list{s});               
        fname = [subject_list{s} '_ERPs.erp'];  % Re-create filename for unfiltered ERP
        ERP = pop_loaderp( 'filename', fname, 'filepath', data_path );   % Load the file   
        % Now make the difference wave, directly specifying the
        % equation that modifies the existing ERPset
        ERP = pop_binoperator( ERP, {'b3= b2-b1 label Rare minus Frequent difference wave' });
        ERP.erpname = [ERP.erpname '_diff'];  % name for erpset menu
        if (save_everything) 
            pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', [ERP.erpname '.erp'], 'filepath', data_path, 'warning', 'off');
        end
        % Now we will do bin operations using a set of equations
        % stored in the file 'bin_equations.txt', which must be in
        % the home folder for the experiment
        ERP = pop_binoperator( ERP, [home_path 'bin_equations.txt']);
        ERP.erpname = [ERP.erpname '_plus'];  % name for erpset menu
        pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', [ERP.erpname '.erp'], 'filepath', data_path, 'warning', 'off');
        
        % Save this final ERP in the ALLERP structure.  This is not
        % necessary unless you want to see the ERPs in the GUI or if you
        % want to access them with another function (e.g., pop_gaverager)
        CURRENTERP = CURRENTERP + 1;
        ALLERP(CURRENTERP) = ERP;

        if (plot_PDFs)
            pop_ploterps(ERP, [1 2], 1:17, 'Style', 'ERP1');
            pop_fig2pdf([data_path subject_list{s} '.pdf']);
        end

    end % end of the "if/else" statement that makes sure the file exists
        
end % end of looping through all subjects

% Make a grand average. The final ERP from each subject was saved in
% ALLERP, and we have nsubj subjects, so the indices of the ERPs to be averaged
% together are 1:nsubj
% We'll also create a filtered version and save it
ERP = pop_gaverager( ALLERP , 'Criterion', 100, 'ERPindex', [ 1:nsubj] ); %'Criterion', 100 is left over from a previous version
ERP.erpname = 'grand_avg';  % name for erpset menu
ERP = pop_savemyerp(ERP, 'filename', [ERP.erpname '.erp'], 'filepath', home_path, 'warning', 'off');
CURRENTERP = CURRENTERP + 1;
ALLERP(CURRENTERP) = ERP;
ERP = pop_filterp( ERP,1:17 , 'Cutoff',30, 'Design', 'butter', 'Filter', 'lowpass', 'Order',2 ); 
ERP.erpname = [ERP.erpname '_30Hz'];  % name for erpset menu
ERP = pop_savemyerp(ERP, 'filename', [ERP.erpname '.erp'], 'filepath', home_path, 'warning', 'off');
CURRENTERP = CURRENTERP + 1;
ALLERP(CURRENTERP) = ERP;

% Measure the mean amplitude from 300-600 ms in bins 2 and 3, channels 11-13.
% Save the results in a variable named "values" and in a file named
% "measures.txt" in the home folder for the experiment.
values = pop_geterpvalues( ALLERP, [300 600], [2 3], 11:13 , 'Baseline', 'pre', 'Erpsets', [1:nsubj], 'Filename', [home_path 'measures.txt'], 'Filename', 'measurement', 'Measure', 'meanbl', 'Resolution',1 );


fprintf('\n\n\n**** FINISHED ****\n\n\n');


