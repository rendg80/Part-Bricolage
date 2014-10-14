% -------------------------------------------------------------------------
%  This is the file that generates the descriptors for MSR Training Set
% -------------------------------------------------------------------------
clc; clear all; close all; 

% Add paths 
addpath ('/home/sukrit/Desktop/ECCV_FULL/eccv_code_final/code'); 
addpath('libsvm-3.12/matlab/');
addpath('use_libsvm/');

% Load the configuration 
global configPB; 
configPB = loadConfiguration(); 

% In case training already hasnot been done, do it here
% Here we want to run all the parts of generating a descriptor, so the
% entries related to runPartDetectors, runFlow,
% resolvePartDetectionAmbiguity, utilizeFlow are all considered as TRUE. 
% So, there are no global variables to consider. We decalre them locally in
% case separate processing is required. 
MSRTrainSet_runPartDetectors = 1; 
MSRTrainSet_runFlow = 1; 
MSRTrainSet_resolvePartDetectionAmbiguity = 1; 
MSRTrainSet_utilizeFlow = 1; 

% Decalre the Category Names
categoryNames  = cell (1,3); 
categoryNames{1,1} = 'boxing'; 
categoryNames{1,2} = 'handclapping'; 
categoryNames{1,3} = 'handwaving'; 

% -----------------------------------------------
% Run Part Detections on the MSR Training Set  
if (MSRTrainSet_runPartDetectors == 1)
    for k = 1:1:3
        mainPath = '../datasets/MSR-training-set/'; 
        [subFolderNames,numberOfsubfolders] = getFiles(strcat(mainPath,categoryNames{1,k}),''); % Extract sub Folder names
        for i = 3:1:numberOfsubfolders  % Neglect first two folder names since they indicate navigation
            folderPath = strcat(mainPath,categoryNames{1,k},'/',subFolderNames{i,1}); 
            cd(folderPath); % Go to the folder of the video
            
            dirList = dir; numFrames = size(dirList,1) - 2; clear dirList; 
            
            % Run Poselets 
            relPathToStore = strcat('../../',folderPath); 
            for j = 0:configPB.frameSeparation(1,2):numFrames-1
                imgName = strcat(subFolderNames{i,1},'-',num2str(j),'.jpg'); 
                if (exist(imgName))
                    img = im2double(imread(imgName)); 
                    img = imresize(img,2);
                    img = abs (img); 
                    img = img./max(img(:));
                    cd ../../../../code/poselets/detector; % Come to the poselets folder 
                    demo_poselets (img, imgName, relPathToStore, configPB.minTorsosWithPoselets); % Run poselets on the image
                end
                clear img imgName; 
            end
            
            % RUN FMPs
            relPathToStore = strcat('../../',folderPath); 
            for j = 0:configPB.frameSeparation(1,2):numFrames-1
                imgName = strcat(subFolderNames{i,1},'-',num2str(j),'.jpg'); 
                if (exist(imgName))
                    img = im2double(imread(imgName)); 
                    img = imresize(img,2);
                    img = abs (img); 
                    img = img./max(img(:));
                    cd ../../../../code/pose_estimate_flexible_mix_parts/code-basic; % Come to the FMP folder 
                    demo (img, imgName, relPathToStore); % Run poselets on the image
                end 
                clear img imgName; 
            end
            
            % Back to the code folder 
            cd('../../../../code'); 
        end % End for the subfolder 
    end 
end

% -----------------------------------------------
% Run Flow on the MSR Training Set 
if (MSRTrainSet_runFlow == 1)
    for k = 1:1:3
        mainPath = '../datasets/MSR-training-set/'; 
        [subFolderNames,numberOfsubfolders] = getFiles(strcat(mainPath,categoryNames{1,k}),''); % Extract sub Folder names
            
        for i = 3:1:numberOfsubfolders  % Neglect first two folder names since they indicate navigation
            folderPath = strcat(mainPath,categoryNames{1,k},'/',subFolderNames{i,1}); 
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
                    img = imresize(img,2); 
                    img = abs (img); 
                    img = img./max (img(:)); 
                    T_vidForFlow(:,:,:,ss_i) = img; ss_i = ss_i + 1; 
                    clear img  imgName; 
                else
                    % No more to do and exit the loop for this video
                    clear imgName; 
                    break;  
                end
            end

            % Compute the Flow 
            T_vidForFlow = T_vidForFlow(:,:,:,1:size(T_vidForFlow,4)-2); % To avoid corner cases 
            cd ('../../../../code/flow/code_v1');
            addpath (genpath('piotr_toolbox')); addpath('colorcodedopticalflow'); addpath('gridfitdir'); 
            
            outputOpticalFlow = streakline_segmentation_v1 (T_vidForFlow); 
            save (strcat('../../',folderPath,'/flow_motion_info.mat'),'outputOpticalFlow'); 
            clear T_vidForFlow  outputOpticalFlow ; 
            
            %[outputStreakFlow, outputSegMasks, outputOpticalFlow, outputStreakLines_x, outputStreakLines_y] = streakline_segmentation_v1 (T_vidForFlow); 
            %save (strcat('../../',folderPath,'/flow_motion_info.mat'),'outputStreakFlow','outputSegMasks','outputOpticalFlow','outputStreakLines_x','outputStreakLines_y'); 
            %clear T_vidForFlow outputStreakFlow outputSegMasks outputOpticalFlow outputStreakLines_x outputStreakLines_y; 

            % Back to the code folder 
            cd('../..'); 
        end % End for the subfolder 
    end 
end

% -----------------------------------------------
% Run Part Detection Ambiguity Resolution on the MSR Training Set 
if (MSRTrainSet_resolvePartDetectionAmbiguity == 1)
    for k = 1:1:3
        mainPath = '../datasets/MSR-training-set/'; 
        [subFolderNames,numberOfsubfolders] = getFiles(strcat(mainPath,categoryNames{1,k}),''); % Extract sub Folder names

        for i = 3:1:numberOfsubfolders  % Neglect first two folder names since they indicate navigation
                folderPath = strcat(mainPath,categoryNames{1,k},'/',subFolderNames{i,1}); 
                cd(folderPath); % Go to the folder of the video
                dirList = dir; numFrames = size(dirList,1) - 2; clear dirList;

            % Get the resolved parts
            for j = 0:configPB.frameSeparation(1,2):numFrames-1
                imgName = strcat(subFolderNames{i,1},'-',num2str(j),'.jpg'); 
                imgNameWithoutExt = strcat(subFolderNames{i,1},'-',num2str(j)); 
                if (exist(imgName))
                    img = im2double(imread(imgName));
                    img = imresize(img,2); 
                    img = abs(img); 
                    img = img./max(img(:)); 
                    imgSize = size(img); 
                    load (strcat(imgNameWithoutExt,'-INFO_FMP.mat')); 
                    load (strcat(imgNameWithoutExt,'-INFO_POSELETS.mat'));
                    cd ('../../../../code'); 
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
            cd ('../../../../code');
        end % End for the subfolder
    end 
end

% -----------------------------------------------
% Run Utilize Everything from Flow on the MSR Training Set 
if (MSRTrainSet_utilizeFlow == 1)
    for k = 1:1:3
        mainPath = '../datasets/MSR-training-set/'; 
        [subFolderNames,numberOfsubfolders] = getFiles(strcat(mainPath,categoryNames{1,k}),''); % Extract sub Folder names
            
        for i = 3:1:numberOfsubfolders  % Neglect first two folder names since they indicate navigation
           
            folderPath = strcat(mainPath,categoryNames{1,k},'/',subFolderNames{i,1}); 
            cd(folderPath); % Go to the folder of the video 
            dirList = dir; numFrames = size(dirList,1) - 2; clear dirList; 
            
            % Do all with the flow and return the variables
            generateDescriptors (numFrames,subFolderNames{i,1}); 
            
            % Save the returned variables
                    
            % Clear variables and change the folder 
            cd ('../../../../code');
        end % End for the subfolder 
    end  
end



