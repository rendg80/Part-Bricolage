% -------------------------------------------------------------------------
% This function is for returning the FMP Parts 
% -------------------------------------------------------------------------
function partsFinal = return_parts_FMP(boxes,score,label,index, width_frame, height_frame)

% For label = 3 (C3 Class - WORST), the calling of the function is
% discarded in the calling loop. So, no need to check for that 
% For label = 1 (C1 Class - BEST), keep all the parts as it is with prob=1.
% Merge Head and Torso 
% For label = 2 (C2 Class - Cant Say about limbs), return all the parts.
% Merge head and Torso. Keep all probabilities as it is. Further checking
% is done according to the flags within the loops. Also, modification of
% probabilities is done there. 

head_indices = [1,2]; 
torso_indices = [3,8,9,10,15,20,21,22]; 
hand1_indices = [4,5,6,7];
hand2_indices = [16,17,18,19];
leg1_indices = [11,12,13,14];
leg2_indices = [23,24,25,26];

% Set the scale factors for the scroe 
if (label == 1)
    scaleFactor = 1;
end
if (label == 2)
    scaleFactor = score;
end

% No need to initialize since the surity is controlled from the caller
% Ensure that the coordinates in the box are within limits 
for i = 1:1:26
    lefts(1,i) = boxes((i-1)*4+1); 
    tops(1,i) = boxes((i-1)*4+2); 
    rights(1,i) = boxes((i-1)*4+3); 
    bottoms(1,i) = boxes((i-1)*4+4); 
end
lefts = max(0,lefts); lefts = min(lefts,width_frame);  
tops = max(0,tops); tops = min(tops,height_frame); 
rights = max(0,rights); rights = min(rights,width_frame);  
bottoms = max(0,bottoms); bottoms = min(bottoms,height_frame); 
for i = 1:1:26
    boxes((i-1)*4+1) = lefts(1,i); 
    boxes((i-1)*4+2) = tops(1,i); 
    boxes((i-1)*4+3) = rights(1,i); 
    boxes((i-1)*4+4) = bottoms(1,i); 
end

% Get the head coordinates after merging
k = 1; 
for i = 1:1:2
    head_rectangle_coordinates(k,:) = boxes(1,(head_indices(1,i)-1)*4+1:1:head_indices(1,i)*4);
    k = k + 1;
end
head_coord_final(1,1) = min (head_rectangle_coordinates(:,1));
head_coord_final(1,2) = min (head_rectangle_coordinates(:,2));
head_coord_final(1,3) = max (head_rectangle_coordinates(:,3));
head_coord_final(1,4) = max (head_rectangle_coordinates(:,4));
head_coord_final(1,3) = head_coord_final(1,3) - head_coord_final(1,1); 
head_coord_final(1,4) = head_coord_final(1,4) - head_coord_final(1,2); 
partsFinal.head_pos(index,1:4) = head_coord_final; 
partsFinal.head_scores(index,1:4) = ones(1,4);

% Get the torso co0rdinates after merging
k = 1; 
for i = 1:1:8
    torso_rectangle_coordinates(k,:) = boxes(1,(torso_indices(1,i)-1)*4+1:1:torso_indices(1,i)*4);
    k = k + 1;
end
torso_coord_final(1,1) = min (torso_rectangle_coordinates(:,1));
torso_coord_final(1,2) = min (torso_rectangle_coordinates(:,2));
torso_coord_final(1,3) = max (torso_rectangle_coordinates(:,3));
torso_coord_final(1,4) = max (torso_rectangle_coordinates(:,4));
torso_coord_final(1,3) = torso_coord_final(1,3) - torso_coord_final(1,1); 
torso_coord_final(1,4) = torso_coord_final(1,4) - torso_coord_final(1,2); 
partsFinal.torso_pos(index,1:4) = torso_coord_final; 
partsFinal.torso_scores(index,1:4) = ones(1,4);

% Set the corordinates of the tehr parts 
for i = 1:1:4 
    partsFinal.hand1_pos(index,(i-1)*4+1:1:4*i) = boxes(1,(hand1_indices(1,i)-1)*4+1:1:hand1_indices(1,i)*4);
    partsFinal.hand1_pos(index,(i-1)*4+3) = partsFinal.hand1_pos(index,(i-1)*4+3) - partsFinal.hand1_pos(index,(i-1)*4+1);
    partsFinal.hand1_pos(index,4*i) = partsFinal.hand1_pos(index,4*i) - partsFinal.hand1_pos(index,(i-1)*4+2);
end
partsFinal.hand1_scores(index,1:16) = scaleFactor * ones(1,16); 

for i = 1:1:4 
    partsFinal.hand2_pos(index,(i-1)*4+1:1:4*i) = boxes(1,(hand2_indices(1,i)-1)*4+1:1:hand2_indices(1,i)*4);
    partsFinal.hand2_pos(index,(i-1)*4+3) = partsFinal.hand2_pos(index,(i-1)*4+3) - partsFinal.hand2_pos(index,(i-1)*4+1);
    partsFinal.hand2_pos(index,4*i) = partsFinal.hand2_pos(index,4*i) - partsFinal.hand2_pos(index,(i-1)*4+2);
end
partsFinal.hand2_scores(index,1:16) = scaleFactor * ones(1,16);


for i = 1:1:4 
    partsFinal.leg1_pos(index,(i-1)*4+1:1:4*i) = boxes(1,(leg1_indices(1,i)-1)*4+1:1:leg1_indices(1,i)*4);
    partsFinal.leg1_pos(index,(i-1)*4+3) = partsFinal.leg1_pos(index,(i-1)*4+3) - partsFinal.leg1_pos(index,(i-1)*4+1);
    partsFinal.leg1_pos(index,4*i) = partsFinal.leg1_pos(index,4*i) - partsFinal.leg1_pos(index,(i-1)*4+2);
end
partsFinal.leg1_scores(index,1:16) = scaleFactor * ones(1,16);


for i = 1:1:4 
    partsFinal.leg2_pos(index,(i-1)*4+1:1:4*i) = boxes(1,(leg2_indices(1,i)-1)*4+1:1:leg2_indices(1,i)*4);
    partsFinal.leg2_pos(index,(i-1)*4+3) = partsFinal.leg2_pos(index,(i-1)*4+3) - partsFinal.leg2_pos(index,(i-1)*4+1);
    partsFinal.leg2_pos(index,4*i) = partsFinal.leg2_pos(index,4*i) - partsFinal.leg2_pos(index,(i-1)*4+2);
end
partsFinal.leg2_scores(index,1:16) = scaleFactor * ones(1,16);





