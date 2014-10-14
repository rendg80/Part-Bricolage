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
    normalizedOutputOpticalFlow = zeros (size(outputOpticalFlow)); 
    if (configPB.normalizeFlow == 1)
        for i = 1:1:size(outputOpticalFlow,4)
            [normalizedOutputOpticalFlow(:,:,1,i),normalizedOutputOpticalFlow(:,:,2,i)] = normalizeFlow(outputOpticalFlow(:,:,:,i)); 
        end
        % Compensate for flows between non-consecutive frames
        normalizedOutputOpticalFlow = normalizedOutputOpticalFlow * configPB.frameSeparationForFlow(1,configPB.dataset);
    end
     
    if (configPB.normalizeFlow == 0)
        normalizedOutputOpticalFlow = outputOpticalFlow; 
    end
    
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

%% Form the All-Flow Descriptor
if (configPB.useFlowInformation == 1)
    normalizedOutputOpticalFlow = zeros (size(outputOpticalFlow)); 
    if (configPB.normalizeFlow == 1)
        for i = 1:1:size(outputOpticalFlow,4)
            [normalizedOutputOpticalFlow(:,:,1,i),normalizedOutputOpticalFlow(:,:,2,i)] = normalizeFlow(outputOpticalFlow(:,:,:,i)); 
        end
        % Compensate for flows between non-consecutive frames
        normalizedOutputOpticalFlow = normalizedOutputOpticalFlow * configPB.frameSeparationForFlow(1,configPB.dataset);
    end
     
    if (configPB.normalizeFlow == 0)
        normalizedOutputOpticalFlow = outputOpticalFlow; 
    end
    
    x_span = floor(configPB.histWindowSizeSpatialPercentage*size(normalizedOutputOpticalFlow,2)); 
    y_span = floor(configPB.histWindowSizeSpatialPercentage*size(normalizedOutputOpticalFlow,1)); 
    
    % Extract histograms of oriented gradients and pixel angles
    for i = 1:1:3 %size(normalizedOutputOpticalFlow,4) 
        for j = 1:1:size(normalizedOutputOpticalFlow,2) % Columns define x range 
            if (j + x_span >= size(normalizedOutputOpticalFlow,2))
                x_min = j;
                x_max = size(normalizedOutputOpticalFlow,2); 
            else
                x_min = j;
                x_max = j + x_span; 
            end
            
            for k = 1:1:size(normalizedOutputOpticalFlow,1)
                if (k + y_span >= size(normalizedOutputOpticalFlow,1))
                    y_min = k;
                    y_max = size(normalizedOutputOpticalFlow,1); 
                else
                    y_min = k;
                    y_max = k + y_span; 
                end
                
                fprintf ('\n FRAME = %d, j = %d, k = %d',i,j,k); 
                hoofAll(:,k,j) = histogramOfGradients(normalizedOutputOpticalFlow(y_min:y_max,x_min:x_max,1,i), normalizedOutputOpticalFlow(y_min:y_max,x_min:x_max,2,i));                   
            end  % End of j 
        end  % End of k
        
        % Save for each frame
        hoofAll(find (isnan(hoofAll))) = 0; % Normally for first frame
        fileNameForFrame = strcat(subFolderName,'-',num2str(i),'-FLOW_ORIENTEDHIST_ALL.mat');
        save (fileNameForFrame,'hoofAll'); 
        clear fileNameForFrame hoofAll; 
    end
    clear x_span y_span;    
end % End of the If for checking the configuration variable 

% --------------------------------------------------------------------
% Now form descriptors.
% --------------------------------------------------------------------
if (configPB.useFlowInformation == 1)
    % ALL FLOW DESCRIPTOR 
    % For a pixel in a frame, it concatenates the HOOF around it, and the next 
    % configPB.histWindowSizeTemporalPixels frame HOOFs. 
    angles_flow = atan2(-normalizedOutputOpticalFlow(:,:,2,:), -normalizedOutputOpticalFlow(:,:,1,:))/pi * 180; 
    for i = 1:1:size(outputOpticalFlow,4)
        [normalizedOutputOpticalFlow_temp(:,:,1,i),normalizedOutputOpticalFlow_temp(:,:,2,i)] = normalizeFlow(outputOpticalFlow(:,:,:,i),1); 
    end

    % Store all the pixel angles as well
    for i = 1:1:size(outputOpticalFlow,4)
        for j = 1:1:size(normalizedOutputOpticalFlow,2)
            for k = 1:1:size(normalizedOutputOpticalFlow,1)
                if (angles_flow(k,j,1,i) >= 0)
                    pixelFlowAngle(k,j,1,i) = ceil(angles_flow(k,j,1,i) / (360 / configPB.binNumberOfFlowAngles)); 
                end

                if (angles_flow(k,j,1,i) < 0)
                    pixelFlowAngle(k,j,1,i) = configPB.binNumberOfFlowAngles + 1 - ceil(-angles_flow(k,j,1,i) / (360 / configPB.binNumberOfFlowAngles)); 
                end

                val_flow = sqrt(normalizedOutputOpticalFlow_temp(k,j,1,i)^2 + normalizedOutputOpticalFlow_temp(k,j,2,i)^2); 
                if (val_flow <= configPB.thresholdForFlowConsideration)
                    pixelFlowAngle(k,j,1,i) = 0; % No Consideration should be given during classification - here just for storage 
                end
            end
        end 
    end
    clear angles_flow normalizedOutputOpticalFlow_temp; 

    x_span = floor(configPB.histWindowSizeSpatialPercentage*size(normalizedOutputOpticalFlow,2)); 
    y_span = floor(configPB.histWindowSizeSpatialPercentage*size(normalizedOutputOpticalFlow,1));

    for i = 1:1:size(normalizedOutputOpticalFlow,4)     
        % Set the temporal range 
        if (i + configPB.histWindowSizeTemporalPixels >= size(normalizedOutputOpticalFlow,4))
            tr_min = size(normalizedOutputOpticalFlow,4) - floor(configPB.histWindowSizeTemporalPixels / configPB.frameSeparationForFlow(1,configPB.dataset));
            tr_max = size(normalizedOutputOpticalFlow,4); 
        else
            tr_min = i;
            tr_max = i + floor (configPB.histWindowSizeTemporalPixels / 2); 
        end

        % Load the PARTS INFO Files in case they exist for the frame
        partsPresentFlag = 0; 
        fileNameForFrame_RP = strcat(subFolderName,'-',num2str((i-1)*configPB.frameSeparationForFlow(1,configPB.dataset)),'-INFO_RESOLVED_PARTS.mat');
        if (exist(fileNameForFrame_RP))
            partsPresentFlag = 1; 
            load (fileNameForFrame_RP); 
            infoParts = infoResolvedParts; 
            clear infoResolvedParts; 
        end
        
        clear fileNameForFrame_RP;
        fileNameForFrame_RP = strcat(subFolderName,'-',num2str((i-1)*configPB.frameSeparationForFlow(1,configPB.dataset)),'-INFO_TRACKED_PARTS.mat');
        if (exist(fileNameForFrame_RP))
            partsPresentFlag = 1; 
            load (fileNameForFrame_RP); 
            infoParts = infoTrackedParts; 
            clear infoTrackedParts; 
        end
        clear fileNameForFrame_RP; 
        
        for ii = tr_min:1:tr_max
            partsPresentFlag_TS = 0; 
            fileNameForFrame_RP = strcat(subFolderName,'-',num2str((ii-1)*configPB.frameSeparationForFlow(1,configPB.dataset)),'-INFO_RESOLVED_PARTS.mat');
            if (exist(fileNameForFrame_RP))
                partsPresentFlag_TS = 1; 
                load (fileNameForFrame_RP); 
                infoParts_TS = infoResolvedParts; 
                clear infoResolvedParts; 
            end

            clear fileNameForFrame_RP;
            fileNameForFrame_RP = strcat(subFolderName,'-',num2str((ii-1)*configPB.frameSeparationForFlow(1,configPB.dataset)),'-INFO_TRACKED_PARTS.mat');
            if (exist(fileNameForFrame_RP))
                partsPresentFlag_TS = 1; 
                load (fileNameForFrame_RP); 
                infoParts_TS = infoTrackedParts; 
                clear infoTrackedParts; 
            end
            clear fileNameForFrame_RP; 
            fileNameForVideo = strcat(subFolderName,'-',num2str(ii),'-FLOW_ORIENTEDHIST_ALL.mat');
            load (fileNameForVideo,'hoofAll'); clear fileNameForVideo; 

            % For the X range 
            for j = 1:1:size(normalizedOutputOpticalFlow,2)
                if (j + x_span >= size(normalizedOutputOpticalFlow,2))
                    x_min = size(normalizedOutputOpticalFlow,2) - x_span;
                    x_max = size(normalizedOutputOpticalFlow,2); 
                else
                    x_min = j;
                    x_max = j + x_span; 
                end

                for k = 1:1:size(normalizedOutputOpticalFlow,1)   
                    if (k + y_span >= size(normalizedOutputOpticalFlow,1))
                        y_min = size(normalizedOutputOpticalFlow,1) - y_span;
                        y_max = size(normalizedOutputOpticalFlow,1); 
                    else
                        y_min = k;
                        y_max = k + y_span; 
                    end

                    % ALL FLOW DESCRIPTOR
                    flow_desc_root_angles(k,j) = pixelFlowAngle(k,j,1,i); 
                    q_temp = hoofAll(:,k,j); 
                    all_flow_disc_hist_around(k,j,ii-tr_min + 1,:) =  q_temp; clear q_temp; 
                    fprintf ('\n FRAME = %d, j = %d, k = %d, temporal span = %d',i,j,k,ii); 
                    
                    % PART ROOT DESCRIPTOR
                    % While considering flows, take care of the overlapping cases since flow
                    % information will also be available at places where the part detections
                    % have happened. 
                    for np = 1:1:configPB.runDualMode+1
                        if (partsPresentFlag == 0)
                            part_desc_root_types(k,j,np) = 0;
                        end
                        if (partsPresentFlag == 1)
                            % Get to which part the pixel belongs to 
                            if (size(infoParts{1,np},1) > 0)
                                a_temp = zeros(1,6); 
                                
                                for sst = 1:1:size(infoParts{1,np}.head_pos,1)
                                    a_temp(1,1) = a_temp(1,1) + checkContainmentOfPixel(infoParts{1,np}.head_pos(sst,:)',[j,k]'); 
                                end
                                for sst = 1:1:size(infoParts{1,np}.torso_pos,1)
                                    a_temp(1,2) = a_temp(1,2) + checkContainmentOfPixel(infoParts{1,np}.torso_pos(sst,:)',[j,k]'); 
                                end
                                for ssi = 0:1:3
                                    for sst = 1:1:size(infoParts{1,np}.hand1_pos,1)
                                        a_temp(1,3) = a_temp(1,3) + checkContainmentOfPixel(infoParts{1,np}.hand1_pos(sst,ssi*4+1:1:ssi*4+4)',[j,k]');
                                    end
                                    for sst = 1:1:size(infoParts{1,np}.hand2_pos,1)
                                        a_temp(1,4) = a_temp(1,4) + checkContainmentOfPixel(infoParts{1,np}.hand2_pos(sst,ssi*4+1:1:ssi*4+4)',[j,k]');
                                    end
                                    for sst = 1:1:size(infoParts{1,np}.leg1_pos,1)
                                        a_temp(1,5) = a_temp(1,5) + checkContainmentOfPixel(infoParts{1,np}.leg1_pos(sst,ssi*4+1:1:ssi*4+4)',[j,k]');
                                    end
                                    for sst = 1:1:size(infoParts{1,np}.leg2_pos,1)
                                        a_temp(1,6) = a_temp(1,6) + checkContainmentOfPixel(infoParts{1,np}.leg2_pos(sst,ssi*4+1:1:ssi*4+4)',[j,k]');
                                    end
                                end
                                
                                % Prioritize
                                a_temp(find(a_temp >= 1)) = 1; 
                                if (sum(a_temp) > 0)
                                     part_desc_root_types(k,j,np) = max (find(a_temp == 1)); 
                                else
                                     part_desc_root_types(k,j,np) = 0; 
                                end
                                clear a_temp; 
                            else
                                part_desc_root_types(k,j,np) = 0;
                            end
                            
                        end % End of if Present Flag 
                    end % End of For np

                    % --------------------------------------
                    % ALL PART DESCRIPTOR 
                    for np = 1:1:configPB.runDualMode+1
                        if (partsPresentFlag_TS == 0)
                            all_part_disc_around(k,j,ii-tr_min + 1,np,:) = zeros (1,6); 
                        end
                        if (partsPresentFlag_TS == 1)
                            % Get to which part the pixel belongs to 
                            if (size(infoParts_TS{1,np},1) > 0)
                                boxMain = [x_min,y_min, x_max - x_min, y_max - y_min]'; 
                                a_temp = zeros(1,6); 
                                
                                for sst = 1:1:size(infoParts_TS{1,np}.head_pos,1)
                                    a_temp(1,1) = a_temp(1,1) + findOverlapBoxes(infoParts_TS{1,np}.head_pos(sst,:)',boxMain); 
                                end
                                for sst = 1:1:size(infoParts_TS{1,np}.torso_pos,1)
                                    a_temp(1,2) = a_temp(1,2) + findOverlapBoxes(infoParts_TS{1,np}.torso_pos(sst,:)',boxMain);  
                                end
                                
                                for sst = 1:1:size(infoParts_TS{1,np}.hand1_pos,1)
                                    qsst = 0; 
                                    for ssi = 0:1:3
                                        qsst = qsst + findOverlapBoxes(infoParts_TS{1,np}.hand1_pos(sst,ssi*4+1:1:ssi*4+4)',boxMain);  
                                    end
                                    a_temp(1,3) = a_temp(1,3) + (qsst >= 1); 
                                end
                                
                                for sst = 1:1:size(infoParts_TS{1,np}.hand2_pos,1)
                                    qsst = 0; 
                                    for ssi = 0:1:3
                                        qsst = qsst + findOverlapBoxes(infoParts_TS{1,np}.hand2_pos(sst,ssi*4+1:1:ssi*4+4)',boxMain);  
                                    end
                                    a_temp(1,4) = a_temp(1,4) + (qsst >= 1); 
                                end
                                
                                for sst = 1:1:size(infoParts_TS{1,np}.leg1_pos,1)
                                    qsst = 0; 
                                    for ssi = 0:1:3
                                        qsst = qsst + findOverlapBoxes(infoParts_TS{1,np}.leg1_pos(sst,ssi*4+1:1:ssi*4+4)',boxMain);  
                                    end
                                    a_temp(1,5) = a_temp(1,5) + (qsst >= 1); 
                                end
                                
                                for sst = 1:1:size(infoParts_TS{1,np}.leg2_pos,1)
                                    qsst = 0; 
                                    for ssi = 0:1:3
                                        qsst = qsst + findOverlapBoxes(infoParts_TS{1,np}.leg2_pos(sst,ssi*4+1:1:ssi*4+4)',boxMain);  
                                    end
                                    a_temp(1,6) = a_temp(1,6) + (qsst >= 1); 
                                end
                                all_part_disc_around(k,j,ii-tr_min + 1,np,:) = a_temp; 
                                clear a_temp; 
                            else
                                all_part_disc_around(k,j,ii-tr_min + 1,np,:) = zeros (1,6); 
                            end
                            
                        end % End of if Present Flag
                        
                    end  % End of the np For
                    
                end % End of k 
            end % End of j 

            clear hoofAll; 
        end % End of ii 

        % Save for each frame
        fileNameForFrame = strcat(subFolderName,'-',num2str(i),'-FLOW_REL_DESC.mat');
        save (fileNameForFrame,'flow_desc_root_angles','part_desc_root_types','all_flow_disc_hist_around','all_part_disc_around'); 
        clear fileNameForFrame part_desc_root_types flow_desc_root_angles all_flow_disc_hist_around all_part_disc_around;  
    end

    % Clear Variables
    clear pixelFlowAngle;  
end

end  % END OF THE FILE FUNCTION 

%% -------------------- OTHER FUNCTIONS USED HERE --------------------------
function containedFlag = checkContainmentOfPixel(boxBB,pixelCoordinates)
% Check if pixelCoordinates(2x1) is fully contained inside boxBB (4x1)
% (x,y) contained inside (x,y,width,height)
    containedFlag = 0; 
    if (size(boxBB,1) > 0)
        if (pixelCoordinates(1,1) >= boxBB(1,1) && ...
                pixelCoordinates(1,1) <= boxBB(1,1) + boxBB(3,1) && ...
                pixelCoordinates(2,1) >= boxBB(2,1) && ...
                pixelCoordinates(2,1) <= boxBB(2,1) + boxBB(4,1))
                containedFlag = 1; 
        end     
    end
end

function overlapFlag = findOverlapBoxes(box2,box1)
% Find if any part of box2 lies inside box1
    overlapFlag = 0; x_overlap_flag = 0; y_overlap_flag = 0;  

    if (size(box2,1) > 0)
        for i = box2(1,1):1:box2(1,1) + box2(3,1)
            if ( i>= box1(1,1) && i <= box1(1,1) + box1(3,1))
                x_overlap_flag = 1; 
                break; 
            end
        end

        for i = box2(2,1):1:box2(2,1) + box2(4,1)
            if ( i>= box1(2,1) && i <= box1(2,1) + box1(4,1))
                y_overlap_flag = 1; 
                break; 
            end
        end

        if (x_overlap_flag == 1 && y_overlap_flag == 1)
           overlapFlag = 1;  
        end
    end
end












