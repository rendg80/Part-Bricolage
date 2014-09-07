% -------------------------------------------------------------------------
% Plot the figures for the optical and streak flows
% -------------------------------------------------------------------------
clc; clear all; close all; 

% Add Paths 
addpath ('/home/sukrit/Desktop/ECCV_FULL/eccv_code_final/code'); 
addpath (genpath('/home/sukrit/Desktop/ECCV_FULL/eccv_code_final/code/flow/code_v1')); 

% Load the configuration 
global configPB; 
configPB = loadConfiguration(); 

% Visualize the Flow Motion Information for the datasets 
% ----------------------------
% Hollywood dataset (For Activity Detection)
if (configPB.dataset == 1)
    mainPath = '../datasets/hollywood/hollywood/'; 
    [subFolderNames,numberOfsubfolders] = getFiles(strcat(mainPath,'/videoclips'),''); % Extract sub Folder names
    for i = 4:1:numberOfsubfolders  % Neglect first two folder names since they indicate navigation
        fprintf ('DOING ----- Video Index = %d',i-3);
        folderPath = strcat(mainPath,'/videoclips/',subFolderNames{i,1}); 
        cd(folderPath); % Go to the folder of the video
        
        % Load the Flow Motion Info File 
        load ('flow_motion_info.mat'); 
        for j = 1:1:size(outputOpticalFlow,4)
            flow_im = flowToColor(outputOpticalFlow(:,:,:,j));
            
            imgFlowName = strcat(subFolderNames{i,1},'-',num2str(j),'-OPTICAL_FLOW_INFO'); 
            h = figure; imshow (flow_im);
            saveas (h,imgFlowName,'jpg');
            clf(h); 
            close all; 
            
            clear flow_im imgFlowName; 
        end
        
        for j = 1:1:size(outputStreakFlow,4)
            flow_im = flowToColor(outputStreakFlow(:,:,:,j));
            
            imgFlowName = strcat(subFolderNames{i,1},'-',num2str(j),'-STREAK_FLOW_INFO'); 
            h = figure; imshow (flow_im);
            saveas (h,imgFlowName,'jpg');
            clf(h); 
            close all; 
            
            clear flow_im imgFlowName; 
        end
        
        cd ('../../../../../code');
    end % End for the subfolder 
end % End for the dataset 


% ----------------------------
% MSR Actions dataset (For Activity Detection)
if (configPB.dataset == 2)
    mainPath = '../datasets/action-detection-dataset/msr/'; 
    [subFolderNames,numberOfsubfolders] = getFiles(strcat(mainPath,'/videos'),''); % Extract sub Folder names
    for i = 3:1:3 %numberOfsubfolders  % Neglect first two folder names since they indicate navigation
        fprintf ('DOING ----- Video Index = %d',i-2); 
        folderPath = strcat(mainPath,'/videos/',subFolderNames{i,1}); 
        cd(folderPath); % Go to the folder of the video 

         % Load the Flow Motion Info File 
        load ('flow_motion_info.mat'); 
        for j = 1:1:size(outputOpticalFlow,4)
            flow_im = flowToColor(outputOpticalFlow(:,:,:,j));
            
            imgFlowName = strcat(subFolderNames{i,1},'-',num2str(j),'-OPTICAL_FLOW_INFO'); 
            h = figure; imshow (flow_im);
            saveas (h,imgFlowName,'jpg');
            clf(h); 
            close all; 
            
            clear flow_im imgFlowName; 
        end
        
        for j = 1:1:size(outputStreakFlow,4)
            flow_im = flowToColor(outputStreakFlow(:,:,:,j));
            
            imgFlowName = strcat(subFolderNames{i,1},'-',num2str(j),'-STREAK_FLOW_INFO'); 
            h = figure; imshow (flow_im);
            saveas (h,imgFlowName,'jpg');
            clf(h); 
            close all; 
            
            clear flow_im imgFlowName; 
        end
        cd ('../../../../../code');
    end % End for the subfolder 
end  

