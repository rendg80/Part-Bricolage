% -------------------------------------------------------------------------
% This function tracks the parts using the flow information
% The outputs are saved into the running folder 
% -------------------------------------------------------------------------
function videoEndFlag = trackParts(parts_init,flow_init,N,NP,subFolderName,imgSize,lastDetectFlag,trackDirection) 

% Add paths 
addpath ('/home/sukrit/Desktop/ECCV_FULL/eccv_code_final/code'); 

% Load the configuration 
configPB = loadConfiguration(); 
MAX_TRACK_THRESHOLD_X = imgSize(1,2) * configPB.frameSeparationForFlow(1,configPB.dataset) / 40; 
MAX_TRACK_THRESHOLD_Y = imgSize(1,1) * configPB.frameSeparationForFlow(1,configPB.dataset) / 40; 

% Load the cell array 
infoTrackedParts = cell(1,configPB.runDualMode+1); 
    
% Handling the end of the frame case 
if (trackDirection == 1)  % Forward Tracking 
    k = floor(N + configPB.frameSeparation(1,configPB.dataset));
    if (~exist(strcat(subFolderName,'-',num2str(k),'-INFO_RESOLVED_PARTS.mat')))
        videoEndFlag = 1; 
        return; 
    end
    videoEndFlag = 0;
    range = floor(N / configPB.frameSeparationForFlow(1,configPB.dataset)) + lastDetectFlag: 1 : floor((N + configPB.frameSeparation(1,configPB.dataset))/ configPB.frameSeparationForFlow(1,configPB.dataset)) - 1;
    trackSign = 1; 
end

if (trackDirection == 0)  % Backward Tracking 
    videoEndFlag = 0; 
    k = 1; 
    range = floor(N / configPB.frameSeparationForFlow(1,configPB.dataset)) : -1 : 1; 
    trackSign = -1;
end

% Back Track the Parts 
parts = parts_init; 
for i = range; 
    % For Head 
    for s = 1:1:size(parts.head_pos,1)
        x1 = parts.head_pos(s,1); 
        y1 = parts.head_pos(s,2); 
        x2 = x1 + parts.head_pos(s,3); 
        y2 = y1 + parts.head_pos(s,4);
        
        % Find the maximum flow in the block 
        flow_max_x = min(max(max(flow_init(floor(y1):floor(y2),floor(x1):floor(x2),1,i))),MAX_TRACK_THRESHOLD_X);
        flow_max_y = min(max(max(flow_init(floor(y1):floor(y2),floor(x1):floor(x2),2,i))),MAX_TRACK_THRESHOLD_Y);

        infoTrackedParts{1,NP}.head_pos(s,1) = x1 + trackSign * flow_max_x;  
        infoTrackedParts{1,NP}.head_pos(s,2) = y1 + trackSign * flow_max_y;
        infoTrackedParts{1,NP}.head_pos(s,1) = max (1,infoTrackedParts{1,NP}.head_pos(s,1)); 
        infoTrackedParts{1,NP}.head_pos(s,1) = min (imgSize(1,2),infoTrackedParts{1,NP}.head_pos(s,1)); 
        infoTrackedParts{1,NP}.head_pos(s,2) = max (1,infoTrackedParts{1,NP}.head_pos(s,2)); 
        infoTrackedParts{1,NP}.head_pos(s,2) = min (imgSize(1,1),infoTrackedParts{1,NP}.head_pos(s,2));

        infoTrackedParts{1,NP}.head_pos(s,3) = x2 + trackSign * flow_max_x;
        infoTrackedParts{1,NP}.head_pos(s,4) = y2 + trackSign * flow_max_y;
        infoTrackedParts{1,NP}.head_pos(s,3) = max (1,infoTrackedParts{1,NP}.head_pos(s,3)); 
        infoTrackedParts{1,NP}.head_pos(s,3) = min (imgSize(1,2),infoTrackedParts{1,NP}.head_pos(s,3)); 
        infoTrackedParts{1,NP}.head_pos(s,4) = max (1,infoTrackedParts{1,NP}.head_pos(s,4)); 
        infoTrackedParts{1,NP}.head_pos(s,4) = min (imgSize(1,1),infoTrackedParts{1,NP}.head_pos(s,4));

        infoTrackedParts{1,NP}.head_pos(s,3) = infoTrackedParts{1,NP}.head_pos(s,3) - infoTrackedParts{1,NP}.head_pos(s,1);   
        infoTrackedParts{1,NP}.head_pos(s,4) = infoTrackedParts{1,NP}.head_pos(s,4) - infoTrackedParts{1,NP}.head_pos(s,2); 
    end
    
    % For Torso 
    for s = 1:1:size(parts.torso_pos,1)
        x1 = parts.torso_pos(s,1); 
        y1 = parts.torso_pos(s,2); 
        x2 = x1 + parts.torso_pos(s,3); 
        y2 = y1 + parts.torso_pos(s,4); 
        
        % Find the maximum flow in the block 
        flow_max_x = min(max(max(flow_init(floor(y1):floor(y2),floor(x1):floor(x2),1,i))),MAX_TRACK_THRESHOLD_X);
        flow_max_y = min(max(max(flow_init(floor(y1):floor(y2),floor(x1):floor(x2),2,i))),MAX_TRACK_THRESHOLD_Y);

        infoTrackedParts{1,NP}.torso_pos(s,1) = x1 + trackSign * flow_max_x;
        infoTrackedParts{1,NP}.torso_pos(s,2) = y1 + trackSign * flow_max_y;
        infoTrackedParts{1,NP}.torso_pos(s,1) = max (1,infoTrackedParts{1,NP}.torso_pos(s,1)); 
        infoTrackedParts{1,NP}.torso_pos(s,1) = min (imgSize(1,2),infoTrackedParts{1,NP}.torso_pos(s,1)); 
        infoTrackedParts{1,NP}.torso_pos(s,2) = max (1,infoTrackedParts{1,NP}.torso_pos(s,2)); 
        infoTrackedParts{1,NP}.torso_pos(s,2) = min (imgSize(1,1),infoTrackedParts{1,NP}.torso_pos(s,2));

        infoTrackedParts{1,NP}.torso_pos(s,3) = x2 + trackSign * flow_max_x;
        infoTrackedParts{1,NP}.torso_pos(s,4) = y2 + trackSign * flow_max_y;
        infoTrackedParts{1,NP}.torso_pos(s,3) = max (1,infoTrackedParts{1,NP}.torso_pos(s,3)); 
        infoTrackedParts{1,NP}.torso_pos(s,3) = min (imgSize(1,2),infoTrackedParts{1,NP}.torso_pos(s,3)); 
        infoTrackedParts{1,NP}.torso_pos(s,4) = max (1,infoTrackedParts{1,NP}.torso_pos(s,4)); 
        infoTrackedParts{1,NP}.torso_pos(s,4) = min (imgSize(1,1),infoTrackedParts{1,NP}.torso_pos(s,4));

        infoTrackedParts{1,NP}.torso_pos(s,3) = infoTrackedParts{1,NP}.torso_pos(s,3) - infoTrackedParts{1,NP}.torso_pos(s,1);   
        infoTrackedParts{1,NP}.torso_pos(s,4) = infoTrackedParts{1,NP}.torso_pos(s,4) - infoTrackedParts{1,NP}.torso_pos(s,2); 
    end
    
    % For Hand1 
    for s = 1:1:size(parts.hand1_pos,1)
        if (parts.hand1_pos(s,1) ~= -1)
            for j = 0:1:3
                x1 = parts.hand1_pos(s,4*j+1); 
                y1 = parts.hand1_pos(s,4*j+2); 
                x2 = x1 + parts.hand1_pos(s,4*j+3); 
                y2 = y1 + parts.hand1_pos(s,4*j+4); 
                
                % Find the maximum flow in the block 
                flow_max_x = min(max(max(flow_init(floor(y1):floor(y2),floor(x1):floor(x2),1,i))),MAX_TRACK_THRESHOLD_X);
                flow_max_y = min(max(max(flow_init(floor(y1):floor(y2),floor(x1):floor(x2),2,i))),MAX_TRACK_THRESHOLD_Y);

                infoTrackedParts{1,NP}.hand1_pos(s,4*j+1) = x1 + trackSign * flow_max_x;
                infoTrackedParts{1,NP}.hand1_pos(s,4*j+2) = y1 + trackSign * flow_max_y;
                infoTrackedParts{1,NP}.hand1_pos(s,4*j+1) = max (1,infoTrackedParts{1,NP}.hand1_pos(s,4*j+1)); 
                infoTrackedParts{1,NP}.hand1_pos(s,4*j+1) = min (imgSize(1,2),infoTrackedParts{1,NP}.hand1_pos(s,4*j+1)); 
                infoTrackedParts{1,NP}.hand1_pos(s,4*j+2) = max (1,infoTrackedParts{1,NP}.hand1_pos(s,4*j+2)); 
                infoTrackedParts{1,NP}.hand1_pos(s,4*j+2) = min (imgSize(1,1),infoTrackedParts{1,NP}.hand1_pos(s,4*j+2));

                infoTrackedParts{1,NP}.hand1_pos(s,4*j+3) = x2 + trackSign * flow_max_x;
                infoTrackedParts{1,NP}.hand1_pos(s,4*j+4) = y2 + trackSign * flow_max_y;
                infoTrackedParts{1,NP}.hand1_pos(s,4*j+3) = max (1,infoTrackedParts{1,NP}.hand1_pos(s,4*j+3)); 
                infoTrackedParts{1,NP}.hand1_pos(s,4*j+3) = min (imgSize(1,2),infoTrackedParts{1,NP}.hand1_pos(s,4*j+3)); 
                infoTrackedParts{1,NP}.hand1_pos(s,4*j+4) = max (1,infoTrackedParts{1,NP}.hand1_pos(s,4*j+4)); 
                infoTrackedParts{1,NP}.hand1_pos(s,4*j+4) = min (imgSize(1,1),infoTrackedParts{1,NP}.hand1_pos(s,4*j+4));

                infoTrackedParts{1,NP}.hand1_pos(s,4*j+3) = infoTrackedParts{1,NP}.hand1_pos(s,4*j+3) - infoTrackedParts{1,NP}.hand1_pos(s,4*j+1);   
                infoTrackedParts{1,NP}.hand1_pos(s,4*j+4) = infoTrackedParts{1,NP}.hand1_pos(s,4*j+4) - infoTrackedParts{1,NP}.hand1_pos(s,4*j+2); 
            end
        else
            infoTrackedParts{1,NP}.hand1_pos(s,:) = parts.hand1_pos(s,:);
        end
    end
    
    % For Hand2 
    for s = 1:1:size(parts.hand2_pos,1)
        if (parts.hand2_pos(s,1) ~= -1)
            for j = 0:1:3
                x1 = parts.hand2_pos(s,4*j+1); 
                y1 = parts.hand2_pos(s,4*j+2); 
                x2 = x1 + parts.hand2_pos(s,4*j+3); 
                y2 = y1 + parts.hand2_pos(s,4*j+4); 
                
                % Find the maximum flow in the block 
                flow_max_x = min(max(max(flow_init(floor(y1):floor(y2),floor(x1):floor(x2),1,i))),MAX_TRACK_THRESHOLD_X);
                flow_max_y = min(max(max(flow_init(floor(y1):floor(y2),floor(x1):floor(x2),2,i))),MAX_TRACK_THRESHOLD_Y);

                infoTrackedParts{1,NP}.hand2_pos(s,4*j+1) = x1 + trackSign * flow_max_x;   
                infoTrackedParts{1,NP}.hand2_pos(s,4*j+2) = y1 + trackSign * flow_max_y;
                infoTrackedParts{1,NP}.hand2_pos(s,4*j+1) = max (1,infoTrackedParts{1,NP}.hand2_pos(s,4*j+1)); 
                infoTrackedParts{1,NP}.hand2_pos(s,4*j+1) = min (imgSize(1,2),infoTrackedParts{1,NP}.hand2_pos(s,4*j+1)); 
                infoTrackedParts{1,NP}.hand2_pos(s,4*j+2) = max (1,infoTrackedParts{1,NP}.hand2_pos(s,4*j+2)); 
                infoTrackedParts{1,NP}.hand2_pos(s,4*j+2) = min (imgSize(1,1),infoTrackedParts{1,NP}.hand2_pos(s,4*j+2));

                infoTrackedParts{1,NP}.hand2_pos(s,4*j+3) = x2 + trackSign * flow_max_x;   
                infoTrackedParts{1,NP}.hand2_pos(s,4*j+4) = y2 + trackSign * flow_max_y;
                infoTrackedParts{1,NP}.hand2_pos(s,4*j+3) = max (1,infoTrackedParts{1,NP}.hand2_pos(s,4*j+3)); 
                infoTrackedParts{1,NP}.hand2_pos(s,4*j+3) = min (imgSize(1,2),infoTrackedParts{1,NP}.hand2_pos(s,4*j+3)); 
                infoTrackedParts{1,NP}.hand2_pos(s,4*j+4) = max (1,infoTrackedParts{1,NP}.hand2_pos(s,4*j+4)); 
                infoTrackedParts{1,NP}.hand2_pos(s,4*j+4) = min (imgSize(1,1),infoTrackedParts{1,NP}.hand2_pos(s,4*j+4));

                infoTrackedParts{1,NP}.hand2_pos(s,4*j+3) = infoTrackedParts{1,NP}.hand2_pos(s,4*j+3) - infoTrackedParts{1,NP}.hand2_pos(s,4*j+1);   
                infoTrackedParts{1,NP}.hand2_pos(s,4*j+4) = infoTrackedParts{1,NP}.hand2_pos(s,4*j+4) - infoTrackedParts{1,NP}.hand2_pos(s,4*j+2); 
            end
        else
            infoTrackedParts{1,NP}.hand2_pos(s,:) = parts.hand2_pos(s,:);
        end
    end
    
    % For Leg1 
    for s = 1:1:size(parts.leg1_pos,1)
        if (parts.leg1_pos(s,1) ~= -1)
            for j = 0:1:3
                x1 = parts.leg1_pos(s,4*j+1); 
                y1 = parts.leg1_pos(s,4*j+2); 
                x2 = x1 + parts.leg1_pos(s,4*j+3); 
                y2 = y1 + parts.leg1_pos(s,4*j+4); 
                
                % Find the maximum flow in the block 
                flow_max_x = min(max(max(flow_init(floor(y1):floor(y2),floor(x1):floor(x2),1,i))),MAX_TRACK_THRESHOLD_X);
                flow_max_y = min(max(max(flow_init(floor(y1):floor(y2),floor(x1):floor(x2),2,i))),MAX_TRACK_THRESHOLD_Y);

                infoTrackedParts{1,NP}.leg1_pos(s,4*j+1) = x1 + trackSign * flow_max_x;  
                infoTrackedParts{1,NP}.leg1_pos(s,4*j+2) = y1 + trackSign * flow_max_y;
                infoTrackedParts{1,NP}.leg1_pos(s,4*j+1) = max (1,infoTrackedParts{1,NP}.leg1_pos(s,4*j+1)); 
                infoTrackedParts{1,NP}.leg1_pos(s,4*j+1) = min (imgSize(1,2),infoTrackedParts{1,NP}.leg1_pos(s,4*j+1)); 
                infoTrackedParts{1,NP}.leg1_pos(s,4*j+2) = max (1,infoTrackedParts{1,NP}.leg1_pos(s,4*j+2)); 
                infoTrackedParts{1,NP}.leg1_pos(s,4*j+2) = min (imgSize(1,1),infoTrackedParts{1,NP}.leg1_pos(s,4*j+2));

                infoTrackedParts{1,NP}.leg1_pos(s,4*j+3) = x2 + trackSign * flow_max_x;   
                infoTrackedParts{1,NP}.leg1_pos(s,4*j+4) = y2 + trackSign * flow_max_y;
                infoTrackedParts{1,NP}.leg1_pos(s,4*j+3) = max (1,infoTrackedParts{1,NP}.leg1_pos(s,4*j+3)); 
                infoTrackedParts{1,NP}.leg1_pos(s,4*j+3) = min (imgSize(1,2),infoTrackedParts{1,NP}.leg1_pos(s,4*j+3)); 
                infoTrackedParts{1,NP}.leg1_pos(s,4*j+4) = max (1,infoTrackedParts{1,NP}.leg1_pos(s,4*j+4)); 
                infoTrackedParts{1,NP}.leg1_pos(s,4*j+4) = min (imgSize(1,1),infoTrackedParts{1,NP}.leg1_pos(s,4*j+4));

                infoTrackedParts{1,NP}.leg1_pos(s,4*j+3) = infoTrackedParts{1,NP}.leg1_pos(s,4*j+3) - infoTrackedParts{1,NP}.leg1_pos(s,4*j+1);   
                infoTrackedParts{1,NP}.leg1_pos(s,4*j+4) = infoTrackedParts{1,NP}.leg1_pos(s,4*j+4) - infoTrackedParts{1,NP}.leg1_pos(s,4*j+2); 
            end
        else
            infoTrackedParts{1,NP}.leg1_pos(s,:) = parts.leg1_pos(s,:);
        end
    end
    
    % For Leg2 
    for s = 1:1:size(parts.leg2_pos,1)
        if (parts.leg2_pos(s,1) ~= -1)
            for j = 0:1:3
                x1 = parts.leg2_pos(s,4*j+1); 
                y1 = parts.leg2_pos(s,4*j+2); 
                x2 = x1 + parts.leg2_pos(s,4*j+3); 
                y2 = y1 + parts.leg2_pos(s,4*j+4); 
                
                % Find the maximum flow in the block 
                flow_max_x = min(max(max(flow_init(floor(y1):floor(y2),floor(x1):floor(x2),1,i))),MAX_TRACK_THRESHOLD_X);
                flow_max_y = min(max(max(flow_init(floor(y1):floor(y2),floor(x1):floor(x2),2,i))),MAX_TRACK_THRESHOLD_Y);

                infoTrackedParts{1,NP}.leg2_pos(s,4*j+1) = x1 + trackSign * flow_max_x;
                infoTrackedParts{1,NP}.leg2_pos(s,4*j+2) = y1 + trackSign * flow_max_y;
                infoTrackedParts{1,NP}.leg2_pos(s,4*j+1) = max (1,infoTrackedParts{1,NP}.leg2_pos(s,4*j+1)); 
                infoTrackedParts{1,NP}.leg2_pos(s,4*j+1) = min (imgSize(1,2),infoTrackedParts{1,NP}.leg2_pos(s,4*j+1)); 
                infoTrackedParts{1,NP}.leg2_pos(s,4*j+2) = max (1,infoTrackedParts{1,NP}.leg2_pos(s,4*j+2)); 
                infoTrackedParts{1,NP}.leg2_pos(s,4*j+2) = min (imgSize(1,1),infoTrackedParts{1,NP}.leg2_pos(s,4*j+2));

                infoTrackedParts{1,NP}.leg2_pos(s,4*j+3) = x2 + trackSign * flow_max_x; 
                infoTrackedParts{1,NP}.leg2_pos(s,4*j+4) = y2 + trackSign * flow_max_y;
                infoTrackedParts{1,NP}.leg2_pos(s,4*j+3) = max (1,infoTrackedParts{1,NP}.leg2_pos(s,4*j+3)); 
                infoTrackedParts{1,NP}.leg2_pos(s,4*j+3) = min (imgSize(1,2),infoTrackedParts{1,NP}.leg2_pos(s,4*j+3)); 
                infoTrackedParts{1,NP}.leg2_pos(s,4*j+4) = max (1,infoTrackedParts{1,NP}.leg2_pos(s,4*j+4)); 
                infoTrackedParts{1,NP}.leg2_pos(s,4*j+4) = min (imgSize(1,1),infoTrackedParts{1,NP}.leg2_pos(s,4*j+4));

                infoTrackedParts{1,NP}.leg2_pos(s,4*j+3) = infoTrackedParts{1,NP}.leg2_pos(s,4*j+3) - infoTrackedParts{1,NP}.leg2_pos(s,4*j+1);   
                infoTrackedParts{1,NP}.leg2_pos(s,4*j+4) = infoTrackedParts{1,NP}.leg2_pos(s,4*j+4) - infoTrackedParts{1,NP}.leg2_pos(s,4*j+2); 
            end
        else
            infoTrackedParts{1,NP}.leg2_pos(s,:) = parts.leg2_pos(s,:);
        end
    end

    % Copy Scores 
    infoTrackedParts{1,NP}.head_scores = parts.head_scores; 
    infoTrackedParts{1,NP}.torso_scores = parts.torso_scores; 
    infoTrackedParts{1,NP}.hand1_scores = parts.hand1_scores; 
    infoTrackedParts{1,NP}.hand2_scores = parts.hand2_scores; 
    infoTrackedParts{1,NP}.leg1_scores = parts.leg1_scores; 
    infoTrackedParts{1,NP}.leg2_scores = parts.leg2_scores; 

    % Save the tracked parts 
    if (trackDirection == 0)
        savingIndex = N - configPB.frameSeparationForFlow(1,configPB.dataset) * k; k = k + 1; 
    end
    if (trackDirection == 1)
        savingIndex = i*configPB.frameSeparationForFlow(1,configPB.dataset);
    end
    
    fileNameForSaving = strcat(subFolderName,'-',num2str(savingIndex),'-INFO_TRACKED_PARTS.mat'); 
    if (exist(fileNameForSaving))
       temp = infoTrackedParts{1,NP}; clear infoTrackedParts;
       load (fileNameForSaving);
       infoTrackedParts{1,NP} = temp; clear temp; 
       save(fileNameForSaving,'infoTrackedParts');
    else
       save(fileNameForSaving,'infoTrackedParts');
    end
    
    % Save the tracked thing as the NEW PARTS
    clear fileNameForSaving parts; 
    parts = infoTrackedParts{1,NP}; 
    clear infoTrackedParts; 
    infoTrackedParts = cell(1,configPB.runDualMode+1); 
end 