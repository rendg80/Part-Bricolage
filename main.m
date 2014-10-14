% -------------------------------------------------------------------------
% This is the MAIN File for Part Bricolage 
% NOTE: Please maintain the folder structure, or make appropriate changes
% within the code. 
% Author: Sukrit Shankar 
% -------------------------------------------------------------------------
clc; clear all; close all; 

% Add paths 
addpath ('/home/sukrit/Desktop/ECCV_FULL/eccv_code_final/code'); 
addpath('libsvm-3.12/matlab/');
addpath('use_libsvm/');

% Load the configuration 
global configPB; 
configPB = loadConfiguration(); 

%% PART DETECTION 
% Get into the dataset folder as selected in the config and Extract
% poselets and FMPs for the sparse set of frames in each video. 

if (configPB.runPartDetectors) % In case one wants to run this submodule
    % ----------------------------
    % Hollywood dataset (For Activity Detection)
    if (configPB.dataset == 1)
        mainPath = '../datasets/hollywood/hollywood/'; 
        [subFolderNames,numberOfsubfolders] = getFiles(strcat(mainPath,'/videoclips'),''); % Extract sub Folder names
        for i = 4:1:numberOfsubfolders  % Neglect first two folder names since they indicate navigation
            folderPath = strcat(mainPath,'/videoclips/',subFolderNames{i,1}); 
            cd(folderPath); % Go to the folder of the video
            
            dirList = dir; numFrames = size(dirList,1) - 2; clear dirList; 
            
            % Run Poselets 
            relPathToStore = strcat('../../',folderPath); 
            for j = 0:configPB.frameSeparation(1,1):numFrames-1
                imgName = strcat(subFolderNames{i,1},'-',num2str(j),'.jpg'); 
                if (exist(imgName))
                    img = im2double(imread(imgName)); 
                    cd ../../../../../code/poselets/detector; % Come to the poselets folder 
                    demo_poselets (img, imgName, relPathToStore, configPB.minTorsosWithPoselets); % Run poselets on the image
                end
                clear img imgName; 
            end
            
            % RUN FMPs
            relPathToStore = strcat('../../',folderPath); 
            for j = 0:configPB.frameSeparation(1,1):numFrames-1
                imgName = strcat(subFolderNames{i,1},'-',num2str(j),'.jpg'); 
                img = im2double(imread(imgName)); An enhanced version of th
                cd ../../../../../code/pose_estimate_flexible_mix_parts/code-basic; % Come to the FMP folder 
                demo (img, imgName, relPathToStore); % Run poselets on the image
                clear img imgName; 
            end
            
            % Back to the code folder 
            cd('../../../../../code'); 
        end % End for the subfolder 
    end % End for the dataset 

    % ----------------------------
    % MSR Actions dataset (For Activity Detection)
    if (configPB.dataset == 2)
        mainPath = '../datasets/action-detection-dataset/msr/'; 
        [subFolderNames,numberOfsubfolders] = getFiles(strcat(mainPath,'/videos'),''); % Extract sub Folder names
        for i = 3:1:numberOfsubfolders  % Neglect first two folder names since they indicate navigation
            folderPath = strcat(mainPath,'/videos/',subFolderNames{i,1}); 
            cd(folderPath); % Go to the folder of the video
            
            dirList = dir; numFrames = size(dirList,1) - 2; clear dirList; 
            
            % Run Poselets 
            relPathToStore = strcat('../../',folderPath); 
            for j = 0:configPB.frameSeparation(1,2):numFrames-1
                imgName = strcat(subFolderNames{i,1},'-',num2str(j),'.jpg'); 
                if (exist(imgName))
                    img = im2double(imread(imgName)); 
                    cd ../../../../../code/poselets/detector; % Come to the poselets folder 
                    demo_poselets (img, imgName, relPathToStore, configPB.minTorsosWithPoselets); % Run poselets on the image
                end
                clear img imgName; 
            end
            
            % RUN FMPs
            relPathToStore = strcat('../../',folderPath); 
            for j = 0:configPB.frameSeparation(1,2):numFrames-1
                imgName = strcat(subFolderNames{i,1},'-',num2str(j),'.jpg'); 
                img = im2double(imread(imgName)); 
                cd ../../../../../code/pose_estimate_flexible_mix_parts/code-basic; % Come to the FMP folder 
                demo (img, imgName, relPathToStore); % Run poselets on the image
                clear img imgName; 
            end
            
            % Back to the code folder 
            cd('../../../../../code'); 
        end % End for the subfolder 
    end
end  % End of the submodule If 

%% COMPUTE FLOW 
if (configPB.runFlow == 1) % In case one wants to run this submodule    
   
    % ----------------------------
    % Hollywood dataset (For Activity Detection)
    if (configPB.dataset == 1)
        mainPath = '../datasets/hollywood/hollywood/'; 
        [subFolderNames,numberOfsubfolders] = getFiles(strcat(mainPath,'/videoclips'),''); % Extract sub Folder names
        for i = 3:1:numberOfsubfolders  % Neglect first two folder names since they indicate navigation
            folderPath = strcat(mainPath,'/videoclips/',subFolderNames{i,1}); 
            cd(folderPath); % Go to the folder of the video
            
            dirList = dir; numFrames = size(dirList,1) - 2; clear dirList; 
            
            % Run Flow 
            ss_i = 1; 
            for j = 0:configPB.frameSeparationForFlow(1,1):10000
                imgName = strcat(subFolderNames{i,1},'-',num2str(j),'.jpg'); 
                a = exist (imgName);
                if (a == 2)  % File exists  
                    % Include in the Tensor 
                    img = im2double(imread(imgName)); 
                    T_vidForFlow(:,:,:,ss_i) = img; ss_i = ss_i + 1; 
                    clear img  imgName; 
                else
                    % No more to do and exit the loop for this video
                    clear imgName; 
                    break;  
                end
            end

            % Compute the Flow 
            T_vidForFlow = T_vidForFlow(:,:,:,1:size(T_vidForFlow,4)-2); % To avoid corber cases 
            cd ('../../../../../code/flow/code_v1');
            addpath (genpath('piotr_toolbox')); addpath('colorcodedopticalflow'); addpath('gridfitdir'); 
            [outputStreakFlow, outputSegMasks, outputOpticalFlow, outputStreakLines_x, outputStreakLines_y] = streakline_segmentation_v1 (T_vidForFlow); 
            save (strcat('../../',folderPath,'/flow_motion_info.mat'),'outputStreakFlow','outputSegMasks','outputOpticalFlow','outputStreakLines_x','outputStreakLines_y'); 
            clear T_vidForFlow outputStreakFlow outputSegMasks outputOpticalFlow outputStreakLines_x outputStreakLines_y; 

            % Back to the code folder 
            % cd('../../../../../code'); 
            cd ('../..');   
            
        end % End for the subfolder 
    end % End for the dataset 

    % ----------------------------
    % MSR Actions dataset (For Activity Detection) 
    if (configPB.dataset == 2)
        mainPath = '../datasets/action-detection-dataset/msr/'; 
        [subFolderNames,numberOfsubfolders] = getFiles(strcat(mainPath,'/videos'),''); % Extract sub Folder names
        for i = 3:1:numberOfsubfolders  % Neglect first two folder names since they indicate navigation
            folderPath = strcat(mainPath,'/videos/',subFolderNames{i,1}); 
            cd(folderPath); % Go to the folder of the video
            
            dirList = dir; numFrames = size(dirList,1) - 2; clear dirList; 
            
             % Run Flow 
            ss_i = 1; 
            for j = 0:configPB.frameSeparationForFlow(1,2):10000
                imgName = strcat(subFolderNames{i,1},'-',num2str(j),'.jpg'); 
                a = exist (imgName);
                if (a == 2)  % File exists  
                    % Include in the Tensor 
                    img = im2double(imread(imgName)); 
                    T_vidForFlow(:,:,:,ss_i) = img; ss_i = ss_i + 1; 
                    clear img  imgName; 
                else
                    % No more to do and exit the loop for this video
                    clear imgName; 
                    break;  
                end
            end

            % Compute the Flow 
            T_vidForFlow = T_vidForFlow(:,:,:,1:size(T_vidForFlow,4)-2); % To avoid corber cases 
            cd ('../../../../../code/flow/code_v1');
            addpath (genpath('piotr_toolbox')); addpath('colorcodedopticalflow'); addpath('gridfitdir'); 
            [outputStreakFlow, outputSegMasks, outputOpticalFlow, outputStreakLines_x, outputStreakLines_y] = streakline_segmentation_v1 (T_vidForFlow); 
            save (strcat('../../',folderPath,'/flow_motion_info.mat'),'outputStreakFlow','outputSegMasks','outputOpticalFlow','outputStreakLines_x','outputStreakLines_y'); 
            clear T_vidForFlow outputStreakFlow outputSegMasks outputOpticalFlow outputStreakLines_x outputStreakLines_y; 

            % Back to the code folder 
            % cd('../../../../../code'); 
            cd ('../..');   
            
        end % End for the subfolder 
    end
end   % End of the submodule If 


%% PART DETECTION - AMBIGUITY RESOLUTION 
if (configPB.resolvePartDetectionAmbiguity == 1)
    
%    % Testing on dummy datasets
%     mainPath = '../tempCodes/dataset_learning_classifiers'; 
%     for i = 1:1:2
%         cd (mainPath); 
%         imgName = strcat('dlc_',num2str(i),'.jpg');
%         img = im2double(imread(imgName));
%         imgSize = size(img); 
%         load (strcat('dlc_',num2str(i),'-INFO_FMP.mat')); 
%         load (strcat('dlc_',num2str(i),'-INFO_POSELETS.mat')); 
%         cd ('../../code'); 
%         infoResolvedParts = resolvePartAmbiguity (imgSize,infoFMP,infoPoselets,configPB.runDualMode, configPB.considerOnlyFMP);  
%         
%         imgNameSave = strcat('dlc_',num2str(i),'-PAR_FMP_ONLY'); 
%         if (size(infoResolvedParts{1,1},1) ~= 0)
%             draw_rectangle (img,infoResolvedParts{1,1},imgNameSave); 
%         end
%         
%         clear imgNameSave; 
%         imgNameSave = strcat('dlc_',num2str(i),'-PAR_FULL'); 
%         if (size(infoResolvedParts{1,2},1) ~= 0)
%             draw_rectangle (img,infoResolvedParts{1,2},imgNameSave); 
%         end
%         
%         % clear img imgSize infoFMP infoPoselets; 
%     end
%                         
%     fprintf ('----------------------- DONE ALL - NOW PAUSE -------------------------'); 
%     pause (inf);
    
    % ----------------------------
    % Hollywood dataset (For Activity Detection)
    if (configPB.dataset == 1)
        mainPath = '../datasets/hollywood/hollywood/'; 
        [subFolderNames,numberOfsubfolders] = getFiles(strcat(mainPath,'/videoclips'),''); % Extract sub Folder names
        for i = 4:1:numberOfsubfolders  % Neglect first two folder names since they indicate navigation
            folderPath = strcat(mainPath,'/videoclips/',subFolderNames{i,1}); 
            cd(folderPath); % Go to the folder of the video
            dirList = dir; numFrames = size(dirList,1) - 2; clear dirList; 
            
            % Get the resolved parts
            for j = 0:configPB.frameSeparation(1,1):numFrames-1
                imgName = strcat(subFolderNames{i,1},'-',num2str(j),'.jpg'); 
                imgNameWithoutExt = strcat(subFolderNames{i,1},'-',num2str(j)); 
                if (exist(imgName))
                    img = im2double(imread(imgName));
                    imgSize = size(img); 
                    load (strcat(imgNameWithoutExt,'-INFO_FMP.mat')); 
                    load (strcat(imgNameWithoutExt,'-INFO_POSELETS.mat'));
                    cd ('../../../../../code'); 
                    infoResolvedParts = resolvePartAmbiguity (imgSize,infoFMP,infoPoselets,configPB.runDualMode, configPB.considerOnlyFMP);  
                    
                    % Draw the final resolved parts on the frame and store 
                    cd (folderPath); 
                    if (configPB.runDualMode == 1)
                        imgNameSave = strcat(imgNameWithoutExt,'-PAR_FMP_ONLY'); 
                        if (size(infoResolvedParts{1,1},1) ~= 0)
                            draw_rectangle (img,infoResolvedParts{1,1},imgNameSave); 
                        end
                        clear imgNameSave; 
                        imgNameSave = strcat(imgNameWithoutExt,'-PAR_FULL'); 
                        if (size(infoResolvedParts{1,2},1) ~= 0)
                            draw_rectangle (img,infoResolvedParts{1,2},imgNameSave); 
                        end
                    end
                    
                    if (configPB.runDualMode == 0 && configPB.considerOnlyFMP == 1)
                        imgNameSave = strcat(imgNameWithoutExt,'-PAR_FMP_ONLY'); 
                        if (size(infoResolvedParts{1,1},1) ~= 0)
                            draw_rectangle (img,infoResolvedParts{1,1},imgNameSave); 
                        end
                    end
                    
                    if (configPB.runDualMode == 0 && configPB.considerOnlyFMP == 0)
                        imgNameSave = strcat(imgNameWithoutExt,'-PAR_FULL'); 
                        if (size(infoResolvedParts{1,1},1) ~= 0)
                            draw_rectangle (img,infoResolvedParts{1,1},imgNameSave); 
                        end
                    end
                    
                    % Save the infoResolvedParts - With its size and config
                    % vars, one can find out which mode has operated. 
                    save(strcat(imgNameWithoutExt,'-INFO_RESOLVED_PARTS.mat') ,'infoResolvedParts'); 
                    clear img imgSize imgNameWithoutExt infoFMP infoPoselets imgNameSave; 
                end
                % clear img imgName imgSize imgNameWithoutExt; 
            end
            cd ('../../../../../code');
        end % End for the subfolder 
    end % End for the dataset 

    
    % ----------------------------
    % MSR Actions dataset (For Activity Detection)
    if (configPB.dataset == 2)
        mainPath = '../datasets/action-detection-dataset/msr/'; 
        [subFolderNames,numberOfsubfolders] = getFiles(strcat(mainPath,'/videos'),''); % Extract sub Folder names
        for i = 3:1:numberOfsubfolders  % Neglect first two folder names since they indicate navigation
            folderPath = strcat(mainPath,'/videos/',subFolderNames{i,1}); 
            cd(folderPath); % Go to the folder of the video 
            dirList = dir; numFrames = size(dirList,1) - 2; clear dirList; 
            
            % Get the resolved parts
            for j = 0:configPB.frameSeparation(1,2):numFrames-1
                imgName = strcat(subFolderNames{i,1},'-',num2str(j),'.jpg'); 
                imgNameWithoutExt = strcat(subFolderNames{i,1},'-',num2str(j)); 
                if (exist(imgName))
                    img = im2double(imread(imgName));
                    imgSize = size(img); 
                    load (strcat(imgNameWithoutExt,'-INFO_FMP.mat')); 
                    load (strcat(imgNameWithoutExt,'-INFO_POSELETS.mat'));
                    cd ('../../../../../code'); 
                    infoResolvedParts = resolvePartAmbiguity (imgSize,infoFMP,infoPoselets,configPB.runDualMode, configPB.considerOnlyFMP);  
                    
                    % Draw the final resolved parts on the frame 
                    fprintf ('------------------ %d',j); 
                    cd (folderPath); 
                    if (configPB.runDualMode == 1)
                        imgNameSave = strcat(imgNameWithoutExt,'-PAR_FMP_ONLY'); 
                        if (size(infoResolvedParts{1,1},1) ~= 0)
                            draw_rectangle (img,infoResolvedParts{1,1},imgNameSave); 
                        end
                        clear imgNameSave; 
                        imgNameSave = strcat(imgNameWithoutExt,'-PAR_FULL'); 
                        if (size(infoResolvedParts{1,2},1) ~= 0)
                            draw_rectangle (img,infoResolvedParts{1,2},imgNameSave); 
                        end
                    end
                    
                    if (configPB.runDualMode == 0 && configPB.considerOnlyFMP == 1)
                        imgNameSave = strcat(imgNameWithoutExt,'-PAR_FMP_ONLY'); 
                        if (size(infoResolvedParts{1,1},1) ~= 0)
                            draw_rectangle (img,infoResolvedParts{1,1},imgNameSave); 
                        end
                    end
                    
                    if (configPB.runDualMode == 0 && configPB.considerOnlyFMP == 0)
                        imgNameSave = strcat(imgNameWithoutExt,'-PAR_FULL'); 
                        if (size(infoResolvedParts{1,1},1) ~= 0)
                            draw_rectangle (img,infoResolvedParts{1,1},imgNameSave); 
                        end
                    end
                    
                    % Save the infoResolvedParts - With its size and config
                    % vars, one can find out which mode has operated. 
                    save(strcat(imgNameWithoutExt,'-INFO_RESOLVED_PARTS.mat') ,'infoResolvedParts');    
                    clear img imgSize imgNameWithoutExt infoFMP infoPoselets imgNameSave; 
                end
                % clear img imgName imgSize imgNameWithoutExt; 
            end
            cd ('../../../../../code');
        end % End for the subfolder 
    end
    
end  % End of the main If (resolving ambiguity within detected Parts)


%% DOING EVERYTHING WITH THE USE OF FLOW AND GENERATE DESCRIPTORS 
if (configPB.utilizeFlow == 1)
     % ----------------------------
    % Hollywood dataset (For Activity Detection)
    if (configPB.dataset == 1)
        mainPath = '../datasets/hollywood/hollywood/'; 
        [subFolderNames,numberOfsubfolders] = getFiles(strcat(mainPath,'/videoclips'),''); % Extract sub Folder names
        for i = 4:1:numberOfsubfolders  % Neglect first two folder names since they indicate navigation
            folderPath = strcat(mainPath,'/videoclips/',subFolderNames{i,1}); 
            cd(folderPath); % Go to the folder of the video
            dirList = dir; numFrames = size(dirList,1) - 2; clear dirList; 
            
            % Do all with the flow and return the variables
            generateDescriptors (numFrames,subFolderNames{i,1});		
            
            % Save the returned variables
                    
            % Clear variables and change the folder 
            cd ('../../../../../code');
        end % End for the subfolder 
    end % End for the dataset 

    
    % ----------------------------
    % MSR Actions dataset (For Activity Detection)
    if (configPB.dataset == 2)
        mainPath = '../datasets/action-detection-dataset/msr/'; 
        [subFolderNames,numberOfsubfolders] = getFiles(strcat(mainPath,'/videos'),''); % Extract sub Folder names
        for i = 3:1:numberOfsubfolders  % Neglect first two folder names since they indicate navigation
            folderPath = strcat(mainPath,'/videos/',subFolderNames{i,1}); 
            cd(folderPath); % Go to the folder of the video 
            dirList = dir; numFrames = size(dirList,1) - 2; clear dirList; 
            
            % Do all with the flow and return the variables
            generateDescriptors (numFrames,subFolderNames{i,1}); 
            
            % Save the returned variables
                    
            % Clear variables and change the folder 
            cd ('../../../../../code');
        end % End for the subfolder 
    end  
end  % End for the config Variable If for Utilizing Flow 
