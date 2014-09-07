function draw_rectangle (img,partsFinal,imgNameSave)
% -------------------------------------------------------------------------
% clc; clear all; close all; 
% img = im2double(imread('dlc_1.jpg'));
% This function displays the rectangles from partsFinal over the image img
% -------------------------------------------------------------------------

h = figure; 
% Display all the parts 
for i = 1:1:size(partsFinal.head_pos,1)
    left = partsFinal.head_pos(i,1); 
    top = partsFinal.head_pos(i,2); 
    right = left + partsFinal.head_pos(i,3); 
    bottom = top + partsFinal.head_pos(i,4); 
    
    x = [left left right right];
    y = [bottom top top bottom];
    fill(x, y, 'g','FaceAlpha',0.2,'EdgeColor','none'); hold on; 
    
    clear left top right bottom x y; 
end 

for i = 1:1:size(partsFinal.torso_pos,1)
    left = partsFinal.torso_pos(i,1); 
    top = partsFinal.torso_pos(i,2); 
    right = left + partsFinal.torso_pos(i,3); 
    bottom = top + partsFinal.torso_pos(i,4); 
    
    x = [left left right right];
    y = [bottom top top bottom];
    fill(x, y, 'y','FaceAlpha',0.2,'EdgeColor','none'); hold on; 
    
    clear left top right bottom x y; 
end 

for i = 1:1:size(partsFinal.hand1_pos,1)
    for k = 1:1:4
        if (partsFinal.hand1_scores(i,(k-1)*4+1) ~= -1)
            left = partsFinal.hand1_pos(i,(k-1)*4+1); 
            top = partsFinal.hand1_pos(i,(k-1)*4+2); 
            right = left + partsFinal.hand1_pos(i,(k-1)*4+3); 
            bottom = top + partsFinal.hand1_pos(i,(k-1)*4+4); 

            x = [left left right right];
            y = [bottom top top bottom];
            fill(x, y, 'm','FaceAlpha',0.2,'EdgeColor','none'); hold on; 

            clear left top right bottom x y; 
        end
    end
end 

for i = 1:1:size(partsFinal.hand2_pos,1)
    for k = 1:1:4
        if (partsFinal.hand2_scores(i,(k-1)*4+1) ~= -1)
            left = partsFinal.hand2_pos(i,(k-1)*4+1); 
            top = partsFinal.hand2_pos(i,(k-1)*4+2); 
            right = left + partsFinal.hand2_pos(i,(k-1)*4+3); 
            bottom = top + partsFinal.hand2_pos(i,(k-1)*4+4); 

            x = [left left right right];
            y = [bottom top top bottom];
            fill(x, y, 'c','FaceAlpha',0.2,'EdgeColor','none'); hold on; 

            clear left top right bottom x y; 
        end
    end
end 

for i = 1:1:size(partsFinal.leg1_pos,1)
    for k = 1:1:4
        if (partsFinal.leg1_scores(i,(k-1)*4+1) ~= -1)
            left = partsFinal.leg1_pos(i,(k-1)*4+1); 
            top = partsFinal.leg1_pos(i,(k-1)*4+2); 
            right = left + partsFinal.leg1_pos(i,(k-1)*4+3); 
            bottom = top + partsFinal.leg1_pos(i,(k-1)*4+4); 

            x = [left left right right];
            y = [bottom top top bottom];
            fill(x, y, 'r','FaceAlpha',0.2,'EdgeColor','none'); hold on; 

            clear left top right bottom x y; 
        end
    end
end 

for i = 1:1:size(partsFinal.leg2_pos,1)
    for k = 1:1:4
        if (partsFinal.leg2_scores(i,(k-1)*4+1) ~= -1)
            left = partsFinal.leg2_pos(i,(k-1)*4+1); 
            top = partsFinal.leg2_pos(i,(k-1)*4+2); 
            right = left + partsFinal.leg2_pos(i,(k-1)*4+3); 
            bottom = top + partsFinal.leg2_pos(i,(k-1)*4+4); 

            x = [left left right right];
            y = [bottom top top bottom];
            fill(x, y, 'b','FaceAlpha',0.2,'EdgeColor','none'); hold on; 

            clear left top right bottom x y; 
        end
    end
end 

% Display the image
imshow (img);

% Save
saveas (h,imgNameSave,'jpg');
clf(h); 
close all; 

