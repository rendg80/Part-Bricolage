% -------------------------------------------------------------------------
% This function extracts torsos and heads from poselets, and adds to the
% list the ones which are not common with that of the FMP part detections.
% -------------------------------------------------------------------------
function partsFinal = return_parts_poselets(partsFinalIn,infoPoselets,index,width_frame,height_frame)

% Refine the boundary cases from the coordinates of the bounding boxes and
% the torso boxes. No need to worry about the scores.

% Check for the empty matrices
if ((size(infoPoselets.boundingBoxesMain,2) == 0) || (size(infoPoselets.boundingBoxesTorso,2) == 0))
    partsFinal = partsFinalIn; 
    return; 
end

infoPoselets.boundingBoxesMain = ceil (infoPoselets.boundingBoxesMain);
infoPoselets.boundingBoxesTorso = ceil (infoPoselets.boundingBoxesTorso);
for i = 1:1:size(infoPoselets.boundingBoxesMain,2)
    infoPoselets.boundingBoxesMain(1,i) = max(infoPoselets.boundingBoxesMain(1,i),0); 
    infoPoselets.boundingBoxesMain(1,i) = min(infoPoselets.boundingBoxesMain(1,i),width_frame);
    infoPoselets.boundingBoxesMain(2,i) = max(infoPoselets.boundingBoxesMain(2,i),0); 
    infoPoselets.boundingBoxesMain(2,i) = min(infoPoselets.boundingBoxesMain(2,i),height_frame);
    infoPoselets.boundingBoxesMain(3,i) = max(infoPoselets.boundingBoxesMain(3,i),0); 
    infoPoselets.boundingBoxesMain(3,i) = min(infoPoselets.boundingBoxesMain(3,i),width_frame - infoPoselets.boundingBoxesMain(1,i));
    infoPoselets.boundingBoxesMain(4,i) = max(infoPoselets.boundingBoxesMain(4,i),0); 
    infoPoselets.boundingBoxesMain(4,i) = min(infoPoselets.boundingBoxesMain(4,i),height_frame - infoPoselets.boundingBoxesMain(2,i)); 
end

for i = 1:1:size(infoPoselets.boundingBoxesTorso,2)
    infoPoselets.boundingBoxesTorso(1,i) = max(infoPoselets.boundingBoxesTorso(1,i),0); 
    infoPoselets.boundingBoxesTorso(1,i) = min(infoPoselets.boundingBoxesTorso(1,i),width_frame);
    infoPoselets.boundingBoxesTorso(2,i) = max(infoPoselets.boundingBoxesTorso(2,i),0); 
    infoPoselets.boundingBoxesTorso(2,i) = min(infoPoselets.boundingBoxesTorso(2,i),height_frame);
    infoPoselets.boundingBoxesTorso(3,i) = max(infoPoselets.boundingBoxesTorso(3,i),0); 
    infoPoselets.boundingBoxesTorso(3,i) = min(infoPoselets.boundingBoxesTorso(3,i),width_frame - infoPoselets.boundingBoxesTorso(1,i));
    infoPoselets.boundingBoxesTorso(4,i) = max(infoPoselets.boundingBoxesTorso(4,i),0); 
    infoPoselets.boundingBoxesTorso(4,i) = min(infoPoselets.boundingBoxesTorso(4,i),height_frame - infoPoselets.boundingBoxesTorso(2,i)); 
end

% Store the torsos and head found from the poselets
for i = 1:1:size(infoPoselets.boundingBoxesTorso,2)
    for j = 1:1:size(infoPoselets.boundingBoxesMain,2)
        % Establish the matrix of TBs being fully contained inside BBs
        M(i,j) = checkContainment(infoPoselets.boundingBoxesMain(:,j), infoPoselets.boundingBoxesTorso(:,i)); 
    end
end


% infoPoselets.boundingBoxesMain
% infoPoselets.boundingBoxesTorso
% From the matrix establish the following four cases 
OOM = M % Stores final one to one matches, first TB, and then BB 
for j = 1:1:size(OOM,2) % Scan all columns (Select 1 TB per bounding box)
    flag = 0; 
    for i = 1:1:size(OOM,1)
        if (OOM(i,j) == 1)  % TB contained inside BB
            flag = 1; 
            S(1,i) = infoPoselets.torso_predictions_score(i,1);
        else 
            S(1,i) = -Inf; 
        end
    end
    if (flag == 1)
        [q,w] = max(S(1,:));
        OOM(:,j) = 0; OOM(w,j) = 1;  
    end
    clear S q w;
end

OOM
for i = 1:1:size(OOM,1) % Scan all rows (Select 1 BB per torso box)
    flag = 0; 
    for j = 1:1:size(OOM,2)
        if (OOM(i,j) == 1)  % TB contained inside BB
            flag = 1; 
            S(1,j) = checkSymmetry(infoPoselets.boundingBoxesMain(:,j), infoPoselets.boundingBoxesTorso(:,i)); 
        else 
            S(1,j) = Inf; 
        end
    end
    if (flag == 1)
        [q,w] = min(S(1,:));
        OOM(i,:) = 0; OOM(i,w) = 1;  
    end
    clear S q w;
end

OOM
% Discard extremely small torsos
thresholdArea = 0.25; 
for i = 1:1:size(OOM,1) 
    if (numel(find(OOM(i,:) == 1)))
        A(1,i) = findArea(infoPoselets.boundingBoxesTorso(:,i)); 
    else
        A(1,i) = -Inf;
    end
    
end
maxArea = max(A(1,:)); 

for i = 1:1:size(OOM,1)
    if ((A(1,i)/maxArea) < thresholdArea)
        OOM(i,:) = 0; 
    end
end

OOM
% Discard the torsos which are just above one another 
for i = 1:1:size(OOM,1)
    if (numel(find(OOM(i,:) == 1)))
        for j = 1:1:size(OOM,1)
            if (numel(find(OOM(j,:) == 1)))
                if(i ~= j)
                    % Check if torso i is above j
                    aboveFlag = checkAbove(infoPoselets.boundingBoxesTorso(:,i), infoPoselets.boundingBoxesTorso(:,j)); 
                    if (aboveFlag == 1)
                        % Check for Symmetry 
                        wi = (find(OOM(i,:) == 1));
                        wj = (find(OOM(j,:) == 1));
                        if ((wi > 0) & (wj > 0))
                            si = checkSymmetry(infoPoselets.boundingBoxesMain(:,wi),infoPoselets.boundingBoxesTorso(:,i)); 
                            sj = checkSymmetry(infoPoselets.boundingBoxesMain(:,wj),infoPoselets.boundingBoxesTorso(:,j)); 
                            if (si <= sj) % More symmetric
                                OOM(j,:) = 0; 
                            end
                            if (si > sj)
                                OOM(i,:) = 0;
                            end 
                        end
                    end
                end  
            end
        end
    end
end


OOM
% Discard torso which are inside another head or a torso 
for i = 1:1:size(OOM,1)
    if (numel(find(OOM(i,:) == 1)))
        containFlagTorso = 0; 
        containFlagHead = 0;
        for j = 1:1:size(OOM,1)
            if (numel(find(OOM(j,:) == 1)))
                if(i ~= j)
                    w = (find(OOM(j,:) == 1));
                    containFlagTorso = checkContainment(infoPoselets.boundingBoxesTorso(:,j),infoPoselets.boundingBoxesTorso(:,i)); 
                    headCord = findHead (infoPoselets.boundingBoxesMain(:,w), infoPoselets.boundingBoxesTorso(:,j)); 
                    containFlagHead = checkContainment(headCord,infoPoselets.boundingBoxesTorso(:,i)); 
                end  
            end
        end
        
        if ((containFlagTorso > 0) || (containFlagHead > 0))
            OOM(i,:) = 0; 
        end
    end
end
OOM

% Decide in case the bounding boxes are within each other
for j = 1:1:size(OOM,2)
    if (numel(find(OOM(:,j) == 1)))
        box1 = infoPoselets.boundingBoxesMain(:,j); 
        for k = 1:1:size(OOM,2)
            if (j ~= k)
                if (numel(find(OOM(:,k) == 1)))
                    box2 = infoPoselets.boundingBoxesMain(:,k); 
                    containedFlag = checkContainment(box2,box1); % Is box1 contained inside box2
                    if (containedFlag == 1)
                        % Check torso probabilities 
                        t1 = find(OOM(:,j) == 1); 
                        t2 = find(OOM(:,k) == 1); 
                        p1 = infoPoselets.torso_predictions_score(t1,1); 
                        p2 = infoPoselets.torso_predictions_score(t2,1); 
                        if (p1 >= p2)
                            OOM (:,k) = 0; 
                        end
                        if (p1 < p2)
                            OOM(:,j) = 0; 
                        end
                    end
                    clear box2; 
                    
                end
            end
        end
        
        clear box1; 
    end
end
OOM

% ------------------------------------------------------------------  
% OOM contains the one-to-one Torso and Box Combinations
% ------------------------------------------------------------------
% Now, see which one of these torso and head detections are the same as
% those found from the FMP (already in partFinal) and known by index
% Delete those 
for i = 1:1:size(OOM,1)
    for j = 1:1:size(OOM,2)
        if (OOM(i,j) == 1)  % TB - BB relationship
            boxTB_poselets = infoPoselets.boundingBoxesTorso(:,i); 
            overlapFlag = 0; 
            for k = 1:1:size(partsFinalIn.torso_pos,1)
                overlapFlag = findOverlap(boxTB_poselets,partsFinalIn.torso_pos(k,:)');
            end
            if (overlapFlag == 1)
                OOM(i,j) = 0; 
            end
        end
    end
end

% Form the final partsFinal with torsos and heads  
% For limbs, assign pos and scores to -1 
% Start the disjoint parts from poselets from index in partsFinalIn
partsFinal = partsFinalIn; 
for i = 1:1:size(OOM,1)
    for j = 1:1:size(OOM,2)
        if (OOM(i,j) == 1)
            headCord = findHead (infoPoselets.boundingBoxesMain(:,j), infoPoselets.boundingBoxesTorso(:,i)); 
            partsFinal.head_pos(index,1:4) = headCord';  clear headCord; 
            
            partsFinal.head_scores(index,1:4) = ones(1,4); 
            partsFinal.torso_pos(index,1:4) = infoPoselets.boundingBoxesTorso(:,i)'; 
            partsFinal.torso_scores(index,1:4) = ones(1,4); 
            partsFinal.hand1_pos(index,1:16) = -1 * ones(1,16); 
            partsFinal.hand1_scores(index,1:16) = -1 * ones(1,16); 
            partsFinal.hand2_pos(index,1:16) = -1 * ones(1,16); 
            partsFinal.hand2_scores(index,1:16) = -1 * ones(1,16); 
            partsFinal.leg1_pos(index,1:16) = -1 * ones(1,16); 
            partsFinal.leg1_scores(index,1:16) = -1 * ones(1,16); 
            partsFinal.leg2_pos(index,1:16) = -1 * ones(1,16); 
            partsFinal.leg2_scores(index,1:16) = -1 * ones(1,16); 
            
            index = index + 1; 
        end
    end
end

end % MAIN Function End for this file 

% -------------------------------------------------------------------------
% -------------------- OTHER FUNCTIONS USED HERE --------------------------
function containedFlag = checkContainment(boxBB,boxTB)
% Check if boxBB (4x1) fully contains boxTB (4x1)
    containedFlag = 0; 
    if ((boxBB(1,1) <= boxTB(1,1)) && ... 
        (boxBB(2,1) <= boxTB(2,1)) && ...    
        ((boxBB(1,1)+boxBB(3,1)) >= (boxTB(1,1)+boxTB(3,1))) && ... 
        ((boxBB(2,1)+boxBB(4,1)) >= (boxTB(2,1)+boxTB(4,1))))
            containedFlag = 1;
    end
end

function asymmetryValue = checkSymmetry(boxBB,boxTB)
% Call this function when TB is totally contained inside BB
% Check the symmetry of boxTB (4x1) within boxBB (4x1)
% Lower value means more symmetry 
    dist(1,1) = sqrt((boxBB(1,1) - boxTB(1,1))^2 + (boxBB(2,1) - boxTB(2,1))^2); 
    dist(2,1) = sqrt((boxBB(1,1)+boxBB(3,1) - boxTB(1,1)-boxTB(3,1))^2 + (boxBB(2,1) - boxTB(2,1))^2); 
    dist(3,1) = sqrt((boxBB(1,1) - boxTB(1,1))^2 + (boxBB(2,1)+boxBB(4,1) - boxTB(2,1)-boxTB(4,1))^2); 
    dist(4,1) = sqrt((boxBB(1,1)+boxBB(3,1) - boxTB(1,1)-boxTB(3,1))^2 + (boxBB(2,1)+boxBB(4,1) - boxTB(2,1)-boxTB(4,1))^2); 
    maxDist = max(dist(:,1)); 
    minDist = min(dist(:,1)); 
    asymmetryValue = maxDist - minDist; 
end

function overlapFlag = findOverlap(box1,box2)
% Find the overlap of box1 (4x1) and box2 (4x1)
% Used for finding overlaps between torso and heads of FMP and Poselets
    overlapFlag = 0; threshold = 0.7; 

    area_box1 = box1(3,1) * box1(4,1);
    area_box2 = box2(3,1) * box2(4,1);

    leftMost = min(box1(1,1), box2(1,1));  
    topMost = min(box1(2,1), box2(2,1));  
    rightMost = max(box1(1,1)+box1(3,1), box2(1,1)+box2(3,1));  
    bottomMost = max(box1(2,1)+box1(4,1), box2(2,1)+box2(4,1));  

    unionArea = abs(rightMost - leftMost) * abs(bottomMost-topMost);
    if ((area_box1/unionArea > threshold) || (area_box2/unionArea > threshold))
        overlapFlag = 1; 
    end
end

function headCord = findHead (boxBB, boxTB)
% Find the head coordinates given the bounding box and the torso ones
% TB is fully contained inside BB 
    headCord(1,1) = boxTB(1,1); 
    headCord(2,1) = boxBB(2,1);
    headCord(3,1) = boxTB(3,1);
    headCord(4,1) = abs(boxBB(2,1) - boxTB(2,1));
end

function areaBox = findArea(box)
% This function returns the area of the box 
    areaBox = box(3,1) * box(4,1); 
end


function aboveFlag = checkAbove(box1, box2)
% This function checks if box1 is above box2 
    threshold = 0.4 * max (box1(3,1), box2(3,1));
    
    aboveFlag = 0; 
    if (box1(2,1) + box1(4,1)  < box2(2,1))
        if ((abs(box1(1,1) - box2(1,1)) <= threshold) && ...
                (abs(box1(1,1) + box1(3,1) - box2(1,1) - box2(3,1)) <= threshold))
                aboveFlag = 1; 
        end
    end
end
