% -------------------------------------------------------------------------
% This file visualizes tracking of the parts
% -------------------------------------------------------------------------
clc; clear all; close all; 

% Add paths 
addpath ('/home/sukrit/Desktop/ECCV_FULL/eccv_code_final/code'); 
addpath('libsvm-3.12/matlab/');
addpath('use_libsvm/');

% Load the configuration 
global configPB; 
configPB = loadConfiguration(); 

% Go to the folder 
folderPath = '../datasets/action-detection-dataset/msr/videos/vid_1'; 
cd (folderPath); 

% Load flow information 
load ('flow_motion_info.mat'); 
for i = 1:1:size(outputOpticalFlow,4)
    [normalizedOutputOpticalFlow(:,:,1,i),normalizedOutputOpticalFlow(:,:,2,i)] = normalizeFlow(outputOpticalFlow(:,:,:,i)); 
end
%normalizedOutputOpticalFlow = normalizedOutputOpticalFlow ./ max(normalizedOutputOpticalFlow(:)); 
normalizedOutputOpticalFlow = normalizedOutputOpticalFlow * configPB.frameSeparationForFlow(1,configPB.dataset); 

% Visualize the tracked parts 
for i = 0:2:682
    fileName = strcat ('vid_1-',num2str(i),'-INFO_TRACKED_PARTS.mat'); 
    if(exist(fileName))
        load (fileName); 
        if (size(infoTrackedParts{1,2},1) > 0)
            % Normal Code 
            if (1)
                img = im2double(imread (strcat('vid_1-',num2str(i),'.jpg')));
                imgNameSave = strcat('vid_1-',num2str(i),'-PAR_FULL_TRACKED.jpg'); 
                draw_rectangle(img,infoTrackedParts{1,2},imgNameSave); 
                clear fileName img imgNameSave; 
            end
            
            % Temporary Code 
            if (0)
                img1 = im2double(imread(strcat('vid_1-',num2str(i),'-PAR_FULL_TRACKED.jpg'))); 
                img2 = outputOpticalFlow(:,:,1,(i/2)+1); 
                img3 = outputOpticalFlow(:,:,2,(i/2)+1); 
                img4 = normalizedOutputOpticalFlow(:,:,1,(i/2)+1); 
                img5 = normalizedOutputOpticalFlow(:,:,2,(i/2)+1); 
                h  = figure; 
                subplot (2,3,1); imshow (img1);  
                subplot (2,3,2); imshow (img2);  
                subplot (2,3,3); imshow (img3);  
                subplot (2,3,4); imshow (img4);  
                subplot (2,3,5); imshow (img5);  

                imgNameSave = strcat('vid_1-',num2str(i),'-PAR_FULL_TRACKED_OVERLAY.jpg'); 
                saveas (h,imgNameSave,'jpg');
                clf(h); 
                close all; 
                clear img1 img2 img3 img4 img5 imgNameSave; 
            end
            
        end
    end
end

% Back to the code folder
cd ('../../../../../code'); 
