% ======= Biomechanics Zoosystem Toolbox Demo Processing Script ============================

% NOTES:
% - This script demonstrates the basic tools available in the Biomechanics Zoosystem Toolbox 
%   by processing data for a hypothetical study (see ~\Help Files\esmac_2014_poster.pdf)
% - All folders and subfolders of the "Biomechanics Zoosystem Toolbox" folder should be 
%   added to the MatLab path before starting the demo script. Windows users should then 
%   remove the subfolder 'Mac Fixes' from the path.
% - Sample data is contained in the 'raw c3d files' folder.
% - Each processing step should operate on a new folder. This allows the user to retain 
%   the original data. Also, the user can keep track of the changes performed throughout 
%   the processing procedure. All steps are included in the download to help users trouble-
%   shoot individual problems.
% - The user is encouraged to first run through each step to understand the procedure. 
% - The advanced user would also want to explore the underlying code of each function.
% - Further information about the zoosystem can be found in:
%   ~\the zoosystem\Help Files\zoo_presentation.ppt'

% THE STUDY
% - 11 subjects were asked to perform straight walking (Straight) and 90 degree turning 
%   while walking (Turn) trials in a typical motion capture environment while fit with the
%   Plug-in Gait (PiG) markers.
% - Standard gait variables (e.g. joint angles and ground reaction forces) were computed 
%   using the PiG modeller in Vicon Nexus (v1.8.4, Vicon Motion Systems Ltd., Oxford, UK)
% - For the purposes of this demo, we will hypothesize that there are differences between
%   conditons for: 
%   (1) Maximum medio-lateral ground reaction force (GRF_ML)
%   (2) Maximum hip adduction in stance (Hip_ADD)
%   (3) Knee flexion angle at foot-off (Knee_FLX)
%
% - Step 1-5 processes the data for analysis
% - Step 6 (The visualization section) presents the two main graphical user interfaces 
%   (GUIs) of the zoosystem: 'ensembler' and 'director'. 
% - Step 7 (The statistical analysis section) demonstrates how to export data to be read
%   by thrid party statistical programs such as SPSS or R.
%
% Created by Philippe C. Dixon November 2013 
%
% Updated by Philippe C. Dixon February 22nd 2016
% - Improved user interface and help
% - Improved statistical analysis section
%
% see https://github.com/PhilD001/the-zoosystem for more info
 

%% Step 1: Conversion to the Zoosystem format-----------------------------------------------
%
% - In this step, we convert data from origial format (.c3d) to zoosystem format (.zoo).
% - User should create a copy of folder 'raw c3d files' called '1-c3d2zoo'. This will allow 
%   us to return to the original data at any time
% - Explore the structure of a raw zoo file by typing "grab" and selecting any file

fld = uigetfolder;                                                         % '1-c3d2zoo'
del = 'yes';                                                               % delete original

c3d2zoo(fld,del)                                                           % run conversion


%% Step 2: Partitioning the data------------------------------------------------------------
%
% - This step limits the analysis to a single stance phase for the right limb.
% - Data are partitionned based on existing events manually identified in Vicon.
% - The user should create a copy of folder '1-c3d2zoo' called '2-partition'.

fld    = uigetfolder;                                                      % '2-partition'
pstart = 'Right_FootStrike1';                                              % start event  
pend   = 'Right_FootOff1';                                                 % end event 

bmech_partition(pstart,pend,fld)                                           % run function

% User notes
% - After processing, all files show data during stance phase of the right limb only. User 
%   can explore data by typing 'grab' in the command window, selecting a file and plotting 
%   a channel e.g. plot(data.RGroundReactionForce.line). 
% - User can check the data.zoosystem.Video field for updated frame information. 
%   ORIGINAL_START_FRAME and ORIGINAL_END_FRAME refer to the actual frames captured in 
%   Vicon. The ORIGINAL_START_FRAME is considered the first frame in the Zoosystem. Thus, 
%   the CURRENT_START_FRAME indicates how many frames were cut from the start during 
%   partionning.
% - Analog channels sampled at 1000Hz will not be partitionned appropriately. If these 
%   channels are required for analysis, user should downsample these channels prior to 
%   partionning. Full list of analog channels stored in 'data.zoosystem.Analog.Channels'. 
%   The ground reaction force channel used here was automatically downsampled by the PiG
%   modeller in Vicon and is therefore partitioned correctly  


%% Step 3: Cleaning the data----------------------------------------------------------------
%
% - This step cleans up the zoo files by removing unwanted channels and by splitting 
%   (exploding) 3D channels into separate channels for easier analysis.
% - User should create a copy of folder '2-partition' called '3-clean'.

fld   = uigetfolder;                                                       % '3-clean'
chkp  = {'RGroundReactionForce','RHipAngles','RKneeAngles','SACR','LASI'}; % chns to keep
chexp = {'RGroundReactionForce','RHipAngles','RKneeAngles'};               % chns to analyse
  
bmech_removechannel('fld',fld,'chkp',chkp)                                 % two approaches
bmech_removechannel('fld',fld,'chrm','LASI')                               % to remove chns

bmech_explode(fld,chexp)                                                   % mx3 to 3 mx1

% User notes
% - All files now contain a single channel for marker data (data.SACR) as well as channels
%   for each dependent variable to be analysed (exploded into three mx1 subchannels) 
% - The 'zoosystem' metainformation channel is never removed by 'bmech_removechannel'


%% Step 4: Adding events -------------------------------------------------------------------
%
% - In this step, discrete events along the curves are identified for statistical analysis
%   (see hypotheses).
% - User should create a copy of folder '3-clean' called '4-addevents'.

fld = uigetfolder;                                                         % '4-addevents'

bmech_addevent(fld,'RGroundReactionForce_x','max','max')                   % max val stance
bmech_addevent(fld,'RHipAngles_y','max','max')                             % max val stance

% User notes
% - Local events have been added to the event branch of the channels selected. Users can 
%   explore data by typing 'grab', selecting a file and plotting using 'zplot' 
%   e.g. zplot(data.RHipAngles_y) (see ~\Sample Study\figures\zplot_figure_example.fig' for 
%   an example
% - An event does not need to be added for knee flexion at foot-off because this event 
%   already exists ('Right_Foot_Off1' identified in Vicon). Its index (time) is saved under
%   the 'SACR_x' event branch. This kind of event is referred to as a 'global event'


%% Step 5: Normalizing the data-------------------------------------------------------------
%
% - This step normalizes the data to a given length of 101 frames (0-100% of the stance 
%   phase)
% - User should create a copy of folder '4-addevents' called '5-normalize'
% - Different interpolation methods can be implemented in bmech_normalize via an optional
%   (third) argument

fld = uigetfolder;                                                         % '5-normalize'
nlength = 100;                                                             % 100% of stance

bmech_normalize(fld,nlength)


%% Step 6: Visualization--------------------------------------------------------------------
%
% - Now that the processing is complete, it is important to visualize the data to check for 
%   errors/problems. This can be done using the 'ensembler' and 'director' tools.
%
% ENSEMBLER (PART 1): 
% - The main GUI in the zoosystem is 'ensembler'. For this example, follow instructions: 
%   (1)  Type 'ensembler' in the Matlab command window. A window pops up with some settings  
%   (2)  Change the 'name' field to 'Straight' 'turn', rows to '1', and columns to '3' (all 
%        without quotes) and click 'OK'. This will create two generic figure windows, each 
%        with three empty axes. To resize figure windows and axes to your liking, select 
%        'restart' from the 'File' menu on the main figure window and edit sizing options
%   (3)  Select 'Axes' --> 're-tag'. Choose any zoo file from the step 5 folder. This opens
%        a window for you to select which channel(s) to view in ensembler. Associate 
%        'RHipAngles_y', 'RKneeAngles_x', and 'RGroundReactionForce_x' to the generic axes
%        '1 1', '1 2', '1 3' and select 'ok'. The axes of each figure will be updated.
%   (4)  In the main menu of either figure window, choose 'File'-->'load data' and select
%        the step 5 folder. This will allow ensembler to populate the axes with 
%        corresponding data. For example, the 'RHipAngles_y' axes of figure 'Turn' contains 
%        only the RHipAngle_y data for the turn condition 
%   (5)  For now, ignore the events by selecting 'Events' --> 'clear all events'. Only the 
%        line data remain. 
%   (6)  One line for RGroundReactionForce_x of the Turn condition appears separate from the 
%        others. Left click on the trace to identify the trial (HC002D25.zoo).  We will see 
%        later why this trace is different, but for now let's assume it is an outlier that 
%        should be removed. This could be done by deleting the file in a standard window 
%        explorer (or mac finder) window, but the rest of the data (hip and knee angles) 
%        appear unaffected and should not be deleted. In ensembler, left click on the trial, 
%        press 'delete' on the  keyboard and select 'Delete \ Channel'. This will replace 
%        all line and event data in this channel with 999 values (check using grab).
%   (7)  Select 'Ensembler' --> 'Ensemble (SD)' and the 'Ensembler' --> 'combine data' to 
%        graph the average of both conditions together. Line styles and colors can be 
%        updated via the 'Line' menu. Change the colors and styles to easily differentiate 
%        the conditons. 
%   (8)  Add a legend by selecting 'Insert' --> 'legend'  
%   (9)  Finalize graphs by exploring the menu bar options or by selecting Edit, property 
%        editor on.
%   (10) Save the figure by selecting File, save fig or export to pdf format by selecting 
%        File, export.
%        See ~\Sample Study\figures\ensembler_line_example.fig and .pdf for sample outputs

% DIRECTOR  
% - The other zoosystem GUI is called 'director'. Director is a 3D virtual environment for 
%   visualization of 3D motion data. Out of the box, it can animate motion trials for 
%   plug-in gait data, but can be updated by advanced users for use with other datasets. 
% - Let us explore a few trials from the dataset by following these steps: 
%  (1) Type 'director' (make sure ensembler is closed) from the command window. This opens
%      up a blank 3D canvas. 
%  (2) Select 'Load File' and choose a file from the step 1 folder. 
%  (3) Choose 'lower-limbs' and then select a few markers to display from the list (e.g. 
%      'RP1M','RP5M', and 'RTOE'). This will load a skeleton and markers associated with the
%      trial. Director detects the position of force plates in the file and also displays 
%      them in the 3D environment. Select 'RHipAngles' from the top-left channel list and 
%      click 'Play' to start the animation. 
%  (4) Repeating this process for a number of trials (including our so-called outlier) 
%      reveals that in trial 'HC002D25.zoo' the subject walked in the opposite direction to 
%      the others. This direction change was rsponsible for seemingly incorrect force 
%      profile. A function could be written to rotate GRF to a single orientation in a real
%      study. Visualization helped us save this file from the rubbish bin. 

% ENSEMBLER (PART 2)
% - We are interested in extracting discrete points along the curves (see hypotheses). 
%   Follow the steps below to crete bar graphs for the given events
%  (1) Repeat steps 1-4, but this time only load the RHipAngles_y data
%  (2) Select Ensembler --> Ensemble (CI) then Ensembler, combine data to show a mean and 
%      confidence interval (CI) curve for each condition on a single axis. 
%  (3) Select 'Bar Graph' --> 'bar graph' to display these discrete data. 
%  (4) Finalize, and save graphs using steps 8-10 from the time-series graphing instructions


%% Step 7: Statistical analysis ------------------------------------------------------------
%
% - After analysis and visualization of data is complete, it is now possible to export the
%   data for statistical analysis
%
% METHOD A: Exporting to spreadsheet (using the eventval function)
%
fld = uigetfolder;                                                       % 'Step 4' folder
levts = 'max';                                                           % local events                                            
gevts = 'Right_FootOff1';                                                % global events                                       
aevts = {'none'};                                                        % anthro events
ch = {'RGroundReactionForce_x','RHipAngles_y','RKneeAngles_x'};          % channel to search
dim1 = {'Straight','Turn'};                                              % conditions
dim2 = {'HC002D','HC003B','HC021A','HC030A','HC032A','HC034A',...        % subjects
        'HC038A','HC039A','HC042A','HC050A','HC055A'};
excelserver = 'on';                                                      % use java
extension = '.xls';                                                      % preferred ext

eventval('fld',fld,'dim1',dim1,'dim2',dim2,'localevts',levts,...
         'globalevts',gevts,'anthroevts',aevts,'ch',ch,'excelserver',excelserver,...
         'ext',extension) 
     
% User notes:
% - If you run into problems take a look at the exisiting 'eventval.xls' file
% - Non-existant events (e.g. 'max' for RKneeAngles_x') and outliers will show as 999 values 
%   in the excel sheet
% - Check that data in excel sheet matches zoo data using grab
% - This sheet can be imported into SPSS to test the hypotheses...what do you find?


% METHOD B: Analysis within the Matlab environment (using extractevents.m)
%
%
% RGroundReactionForce_x maximum (GRF_ML)
%
ch = 'RGroundReactionForce_x';
evt = 'max';
r = extractevents(fld,dim1,dim2,ch,evt);
[~,pval_GRF_ML] = ttest(r.Straight,r.Turn,0.05,'both');
disp(['p-value for GRF_ml = ',num2str(pval_GRF_ML)])

% RHipAngle_y maximum (Hip_ADD)
%
ch = 'RHipAngles_y';
evt = 'max';
r = extractevents(fld,dim1,dim2,ch,evt);
[~,pval_Hip_ADD] = ttest(r.Straight,r.Turn,0.05,'both');
disp(['p-value for Hip_ADD = ',num2str(pval_Hip_ADD)])

% RKneeAngle_x at foot off (Knee_FLX)
%
ch = 'RKneeAngles_x';
evt = 'Right_FootOff1';
r = extractevents(fld,dim1,dim2,ch,evt);
[~,pval_Knee_FLX] = ttest(r.Straight,r.Turn,0.05,'both');
disp(['p-value for Knee_FLX = ',num2str(pval_Knee_FLX)])