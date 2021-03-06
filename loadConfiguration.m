% -------------------------------------------------------------------------
% This function loads the configuration for the PART BRICOLAGE Model 
% INPUTS - None 
% OUTPUTS - config (a structure with various fields)
% Author: Sukrit Shankar
% -------------------------------------------------------------------------
function configPB = loadConfiguration()

% Config Params for which part of the model one wishes to run.
% This  is done since the whole model involves quite heavy computations,
% and in general, one finds it easier to run in parts, store the results,
% and use this storage in the subsequent parts. 
% The params are listed in order that they need to be run in the code. 
configPB.runPartDetectors = 0; 
configPB.runFlow = 0; 
configPB.resolvePartDetectionAmbiguity = 0; 
configPB.utilizeFlow = 1; 
configPB.doTraining = 0;
configPB.formGraphs = 0;
configPB.doDetection = 0;  % Includes Classification  

% Load the config param for the dataset - Never start from zero 
% 1 - Hollywood (for activity detection)
% 2 - MSR Actions (for activity detection) 
configPB.dataset = 2; 

% Load the config param for choosing separation of frames in a video on
% which the part detectors need to be applied
% For 25fps, for every 0.25 sec, it will be almost 6 frames 
configPB.frameSeparation = [20, 6]; % For datasets in order and according to the type of videos in the dataset 

% Load the config param for choosing separation of frames in a video on
% which the flow has to be computed. computign flow in consecutive frames
% might be very expensive for large datasets (like the ones we have).
% For tracking using detection on sparse parts to make perfect sense, make
% sure that frameSeparationForFlow wholly divides frameSeparation
configPB.frameSeparationForFlow = [5, 2]; % For datasets in order and according to the type of videos in the dataset
configPB.normalizeFlow = 0;  % Keep it zero unless you want to experiment 

% Load the config param for the minimum no of torsos detected with poselets
% Can change dependeing on the number of people generally found in the
% datasets being used for evaluation. 
configPB.minTorsosWithPoselets = 2; 

% Load the intermediate param while resolving ambiguity in various part detections
configPB.runDualMode = 1; % 1 = Run with and without Poselets, 0 = Run according to considerOnlyFMP Flag
configPB.considerOnlyFMP = 0; % 1 = consider only FMP (not poselets and torsos)

% Load the configuration variable which decides whether to use flow or not
configPB.useFlowInformation = 1; 

% Load the configuration variable for type of tracking 
% 0 = Max Frequency Flow ; 1 = Median
% Note - For tracking in our case, entire part needs a fixed flow for
% avoiding distortions in shape.
configPB.typeOfTracking = 0; 

% Load the configuration variable for the histogram binsize - For Flow
configPB.histBinSize = 10; 
configPB.histWindowSizeSpatialPercentage = 0.2; 
configPB.histWindowSizeTemporalPixels = 1; 
configPB.binNumberOfFlowAngles = 20;
configPB.thresholdForFlowConsideration = 0.1; 


