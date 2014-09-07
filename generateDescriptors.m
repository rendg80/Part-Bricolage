% -------------------------------------------------------------------------
% The function generates descriptors (to be classified) for Part Bricolage 
% The function is called for every video 
% -------------------------------------------------------------------------
function generateDescriptors (numFrames,subFolderName) 

% Add paths 
addpath ('/home/sukrit/Desktop/ECCV_FULL/eccv_code_final/code'); 

% Load the configuration 
configPB = loadConfiguration(); 

% Load the flow inforation for the video 
if (configPB.useFlowInformation == 1)
    load ('flow_motion_info.mat','outputOpticalFlow'); 
end % Else no need to load since it wont be used at all 

%% Track the parts using the flow 
if (configPB.useFlowInformation == 0)
    % There is no tracking of parts, so the resolved parts are the only
    % part descriptors that we have - There is nothing extra to save 
end

if (configPB.useFlowInformation == 1)
    % First normalize the flow information for the entire video 
    normalizedOutputOpticalFlow = zeros (size(outputOpticalFlow)); 
    for i = 1:1:size(outputOpticalFlow,4)
        [normalizedOutputOpticalFlow(:,:,1,i),normalizedOutputOpticalFlow(:,:,2,i)] = normalizeFlow(outputOpticalFlow(:,:,:,i)); 
    end
    
    % Compensate for flows between non-consecutive frames
    normalizedOutputOpticalFlow = normalizedOutputOpticalFlow * configPB.frameSeparationForFlow(1,configPB.dataset); 
    
    for np = 1:1:configPB.runDualMode+1 % Will give the part sets to consider
        % Initialize the Flags 
        backTrackNumber = configPB.frameSeparation(1,configPB.dataset); 
        backTrackDoneFlag = 0; 
        videoEndFlag = 0; 
        
        % Once the flow is normalized, track the parts using the flow field
        for i = 0:configPB.frameSeparation(1,configPB.dataset):numFrames-2
            fprintf ('\n FRAME DONE = %d  (np = %d)',i,np); 
            fileNameForFrame = strcat(subFolderName,'-',num2str(i),'-INFO_RESOLVED_PARTS.mat'); % Will give infoResolvedParts
            if (exist(fileNameForFrame)) % Imp to check existence 
                load (fileNameForFrame); clear fileNameForFrame; 
                
                % Load the corresponding image and the image name - Its
                % bound to exist at this point 
                imgName = strcat(subFolderName,'-',num2str(i),'.jpg'); 
                img = im2double(imread(imgName));
                imgSize = size(img);clear img imgName; 
                
                if (backTrackDoneFlag == 0)
                    if (size(infoResolvedParts{1,np}.head_pos,1) == 0)
                        if (size(infoResolvedParts{1,np}.torso_pos,1) == 0)
                        end
                    else
                        backTrackNumber = i; 
                        videoEndFlag = trackParts(infoResolvedParts{1,np},normalizedOutputOpticalFlow,backTrackNumber,np,subFolderName,imgSize,0,0); 
                        backTrackDoneFlag = 1; 
                        videoEndFlag = trackParts(infoResolvedParts{1,np},normalizedOutputOpticalFlow,i,np,subFolderName,imgSize,1,1); 
                    end
                end
                
                if (backTrackDoneFlag == 1)
                    if (size(infoResolvedParts{1,np}.head_pos,1) == 0)
                        if (size(infoResolvedParts{1,np}.torso_pos,1) == 0)
                            % Load the last infoTrackedParts 
                            tempIndex = mod(i,configPB.frameSeparationForFlow(1,configPB.dataset));
                            if (tempIndex == 0)
                               tempIndex = configPB.frameSeparationForFlow(1,configPB.dataset); 
                            end
                            
                            fileNameForFrame = strcat(subFolderName,'-',num2str(i - tempIndex),'-INFO_TRACKED_PARTS.mat'); % Will give infoResolvedParts
                            if (exist(fileNameForFrame)) % Imp to check existence 
                                load (fileNameForFrame,'infoTrackedParts'); clear fileNameForFrame; 
                            end
                            videoEndFlag = trackParts(infoTrackedParts{1,np},normalizedOutputOpticalFlow,i,np,subFolderName,imgSize,0,1); 
                        end
                    else
                        videoEndFlag = trackParts(infoResolvedParts{1,np},normalizedOutputOpticalFlow,i,np,subFolderName,imgSize,1,1); 
                    end
                end
                
                if (videoEndFlag == 1)
                    break;
                end
                
                clear infoResolvedParts ; 
            end
        end
    end % End of the np For Loop 
    
end % End of the If for the flow config variable 







