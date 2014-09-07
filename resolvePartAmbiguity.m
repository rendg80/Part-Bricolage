% -------------------------------------------------------------------------
% The function resolves the ambiguities in the detected parts (for a frame)
% -------------------------------------------------------------------------
function infoResolvedParts = resolvePartAmbiguity(imgSize,infoFMP,infoPoselets, dualModeFlag, onlyFMPFlag)

% Load the width and the height of the frame 
width_frame = imgSize(1,2); 
height_frame = imgSize(1,1); 

% Load the FMP Information 
load ('trained_FMP_model.mat'); model_FMP = model; clear model; 

% -------------------------------------------------------------------------
% If dual mode is active - run two times - one without FMP and one with it 
if (dualModeFlag == 1) 
    infoResolvedParts = cell (1,2); % First for FMP only, Second for FMP + Poselets
    
    count_parts = 0; % Number of parts detected 
    % Check if we have any nice FMP detections 
    for i = 1:1:size(infoFMP.scores,1)
        [predict_label, accuracy, decis_values] = ovrpredictBot(1,infoFMP.scores(i,1), model_FMP);
        if (predict_label(1,1) == 1) % Best Class C1
            % Store the part detections from FMP 
            label = 1;
            count_parts = count_parts + 1; 
            partsFinal = return_parts_FMP(infoFMP.boxes(i,:),infoFMP.scores(i,:),label,count_parts,width_frame,height_frame);
        end
        
        if ((predict_label(1,2) == 1) && (predict_label(1,1) == 0)) % Doubtful Class C2
            % Store the part detections from FMP as if onlyFMPFlag = 1
            label = 2;
            count_parts = count_parts + 1; 
            partsFinal = return_parts_FMP(infoFMP.boxes(i,:),infoFMP.scores(i,:),label,count_parts,width_frame,height_frame);    
        end
    end
    % In case no good FMP parts have been detected
    if (count_parts == 0)
        partsFinal.head_pos = []; 
        partsFinal.head_scores = []; 
        partsFinal.torso_pos = []; 
        partsFinal.torso_scores = []; 
        partsFinal.hand1_pos = []; 
        partsFinal.hand1_scores = []; 
        partsFinal.hand2_pos = []; 
        partsFinal.hand2_scores = []; 
        partsFinal.leg1_pos = []; 
        partsFinal.leg1_scores = []; 
        partsFinal.leg2_pos = []; 
        partsFinal.leg2_scores = [];  
    end
    infoResolvedParts{1,1} = partsFinal; 
    
    % Store the final parts after poselet based torso and head predictions
    index = count_parts + 1; % Starting index for disjoint poselet detections
    partsFinal = return_parts_poselets(partsFinal,infoPoselets,index,width_frame,height_frame); 
    infoResolvedParts{1,2} = partsFinal;
    
    
    
% -------------------------------------------------------------------------
else  % Dual Mode Flag is off - check the onlyFMPFlag
    infoResolvedParts = cell (1,1); % Just to make the format consistent
    
    if (onlyFMPFlag == 1)  % do only FMP 
        count_parts = 0; % Number of parts detected 
        % Check if we have any nice FMP detections 
        for i = 1:1:size(infoFMP.scores,1)
            [predict_label, accuracy, decis_values] = ovrpredictBot(1,infoFMP.scores(i,1), model_FMP);
            if (predict_label(1,1) == 1) % Best Class C1
                % Store the part detections from FMP 
                label = 1; 
                count_parts = count_parts + 1; 
                partsFinal = return_parts_FMP(infoFMP.boxes(i,:),infoFMP.scores(i,:),label,index,width_frame,height_frame);
            end

            if ((predict_label(1,2) == 1) && (predict_label(1,1) == 0)) % Doubtful Class C2
                % Store the part detections from FMP as if onlyFMPFlag = 1
                label = 2; 
                count_parts = count_parts + 1; 
                partsFinal = return_parts_FMP(infoFMP.boxes(i,:),infoFMP.scores(i,:),label,index,width_frame,height_frame);    
            end
        end
        % In case no good FMP parts have been detected
        if (count_parts == 0)
            partsFinal.head_pos = []; 
            partsFinal.head_scores = []; 
            partsFinal.torso_pos = []; 
            partsFinal.torso_scores = []; 
            partsFinal.hand1_pos = []; 
            partsFinal.hand1_scores = []; 
            partsFinal.hand2_pos = []; 
            partsFinal.hand2_scores = []; 
            partsFinal.leg1_pos = []; 
            partsFinal.leg1_scores = []; 
            partsFinal.leg2_pos = []; 
            partsFinal.leg2_scores = [];  
        else
            infoResolvedParts{1,1} = partsFinal; 
        end
        
    else  % Do FMP + Poselets 
        count_parts = 0; % Number of parts detected 
        % Check if we have any nice FMP detections 
        for i = 1:1:size(infoFMP.scores,1)
            [predict_label, accuracy, decis_values] = ovrpredictBot(1,infoFMP.scores(i,1), model_FMP);
            if (predict_label(1,1) == 1) % Best Class C1
                % Store the part detections from FMP 
                label = 1; 
                count_parts = count_parts + 1; 
                partsFinal = return_parts_FMP(infoFMP.boxes(i,:),infoFMP.scores(i,:),label,index,width_frame,height_frame);
            end

            if ((predict_label(1,2) == 1) && (predict_label(1,1) == 0)) % Doubtful Class C2
                % Store the part detections from FMP as if onlyFMPFlag = 1
                label = 2; 
                count_parts = count_parts + 1; 
                partsFinal = return_parts_FMP(infoFMP.boxes(i,:),infoFMP.scores(i,:),label,index,width_frame,height_frame);    
            end
        end
        % In case no good FMP parts have been detected
        if (count_parts == 0)
            partsFinal.head_pos = []; 
            partsFinal.head_scores = []; 
            partsFinal.torso_pos = []; 
            partsFinal.torso_scores = []; 
            partsFinal.hand1_pos = []; 
            partsFinal.hand1_scores = []; 
            partsFinal.hand2_pos = []; 
            partsFinal.hand2_scores = []; 
            partsFinal.leg1_pos = []; 
            partsFinal.leg1_scores = []; 
            partsFinal.leg2_pos = []; 
            partsFinal.leg2_scores = [];  
        else
            infoResolvedParts{1,1} = partsFinal; 
        end
        
        % Store the final parts after poselet based torso and head predictions
        index = count_parts + 1; % Starting index for disjoint poselet detections
        partsFinal = return_parts_poselets(partsFinal,infoPoselets,index,width_frame,height_frame); 
        infoResolvedParts{1,1} = partsFinal;
    end
    
end


