
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Demo file that loads an image, finds the people and draws bounding
%%% boxes around them.
%%%
%%% Copyright (C) 2009, Lubomir Bourdev and Jitendra Malik.
%%% This code is distributed with a non-commercial research license.
%%% Please see the license file license.txt included in the source directory.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% img = Image to be processed for detetion of poselets
% imgName = Name of the image to be used for storing the outputs
% relPathToStore = Relative Path (w.r.t to this file) where the poselet
% output for the image shall be stored.
% minTorsosWithPoselets = parameter set in the config file 
function demo_poselets (img, imgName, relPathToStore,minTorsosWithPoselets) 

global config;
config=init;
time=clock;

% Choose the category here
category = 'person';
data_root = [config.DATA_DIR '/' category];
% disp(['Running on ' category]);

% These are important config parameters
faster_detection = true;  % Set this to false to run slower but higher quality
interactive_visualization = false; % Enable browsing the results
enable_bigq = true; % enables context poselets

if faster_detection
    % disp('Using parameters optimized for speed over accuracy.');
    config.DETECTION_IMG_MIN_NUM_PIX = 500^2;  % if the number of pixels in a detection image is < DETECTION_IMG_SIDE^2, scales up the image to meet that threshold
    config.DETECTION_IMG_MAX_NUM_PIX = 750^2;
    config.PYRAMID_SCALE_RATIO = 2;
end

% Loads the SVMs for each poselet and the Hough voting params
clear output poselet_patches fg_masks;
load([data_root '/model.mat']); % model
if exist('output','var')
    model=output; clear output;
end
if ~enable_bigq
   model =rmfield(model,'bigq_weights');
   model =rmfield(model,'bigq_logit_coef');
   % disp('Context is disabled.');
end
if ~enable_bigq || faster_detection
   % disp('*******************************************************');
   % disp('* NOTE: The code is running in faster but suboptimal mode.');
   % disp('*       Before reporting comparison results, set faster_detection=false; enable_bigq=true;');
   % disp('*******************************************************');
end


% Process for an image
    [bounds_predictions,poselet_hits,torso_predictions]=detect_objects_in_image(img,model,config);

    if interactive_visualization && (~exist('poselet_patches','var') || ~exist('fg_masks','var'))
        % disp('Interactive visualization not supported for this category');
        interactive_visualization=false;
    end

    % SUKRIT MODIFICATION 
    % if ~interactive_visualization
    %     display_thresh = 5.7; % detection rate vs false positive rate threshold
    %     imshow(img);
    %     bounds_predictions.select(bounds_predictions.score>display_thresh).draw_bounds;
    %     torso_predictions.select(torso_predictions.score>display_thresh).draw_bounds('blue');
    % else
    %     disp('Entering interactive visualization.');
    %     params.poselet_patches=poselet_patches;
    %     params.all_torso_hits=torso_predictions;
    %     params.all_poselet_hits=poselet_hits;
    %     params.masks=fg_masks;
    % 
    %     bounds_predictions.image_id(:)=1;
    %     params.all_poselet_hits.image_id(:)=1;
    %     params.all_torso_hits.image_id(:)=1;
    %     browse_hits(bounds_predictions,im1,params);
    % end


    % -------------------------------------------------------------------------
    % Bounds Predictions - 0.8 threshold 
    % Torso Predictions - 1.5 threshold 
    % -------------------------------------------------------------------------
    if ~interactive_visualization
        display_thresh_bounds = 0.8; 
        display_thresh_torso = 0.8;
        % display_thresh_poselets = 0.5; 
        % h1 = figure; imshow(img);
        % Adjust Threshold in case nothing is found
        noOfBounds = 0; 
        while (noOfBounds < minTorsosWithPoselets) % Detecting atleast 2 boxes (Scores will be there anyways)
             noOfBounds = bounds_predictions.select(bounds_predictions.score > display_thresh_bounds).size; 
             display_thresh_bounds = display_thresh_bounds - 0.1;
             if (display_thresh_bounds < 0)
                 break; 
             end
        end 
                
        % bounds_predictions.select(bounds_predictions.score > display_thresh_bounds).draw_bounds;
        % torso_predictions.select(bounds_predictions.score > display_thresh_bounds).draw_bounds('blue');
        
        cd (relPathToStore); % Go to the path to store  
        % Increasing Poselet Range 
        poseletsInBoundsTemp = poselet_hits.select(bounds_predictions.score > display_thresh_bounds); 
        display_thresh_poselets = max(max(poseletsInBoundsTemp.score) - 1,0) ; 
        poseletsInBounds = poselet_hits.select(poselet_hits.score > display_thresh_poselets); 
        
        % Sort Poselets and Choose top 20 in descending order
        [a,b] = sort(poseletsInBounds.score,'descend');
        
        h2 = figure;
        for j = 1:1:min(poseletsInBounds.size,20)
            subplot (4,5,j); imshow (fg_masks{poseletsInBounds.poselet_id(b(j))}); title (num2str(a(j))); 
            % subplot (4,5,j); imshow (fg_masks{poselet_hits.poselet_id(b(j))}); title (num2str(a(j))); 
            % subplot(2,5,j); imshow (fg_masks{poseletsInBounds.poselet_id(j)}); title (num2str(poseletsInBounds.score(j))); 
        end
        
        saveas (h2,strcat(strtok(imgName,'.'),'-POSELETS_DETECTED'),'jpg');
        clf(h2); 
        
        % Overlay the place of poselet firing 
        h3 = figure; imshow(img); 
        for j = 1:1:min(poseletsInBounds.size,20)
            rectangle('position',poseletsInBounds.bounds(:,b(j)),'edgecolor','red','linewidth',2,'linestyle','-');
            text(double(poseletsInBounds.bounds(1,b(j))),double(poseletsInBounds.bounds(2,b(j))),num2str(a(j),'%4.4f'),'BackgroundColor',[1,1,1],'Color',[0 0 0]);
        end
        saveas (h3,strcat(strtok(imgName,'.'),'-POSELETS_OVERLAY'),'jpg');
        clf(h3); close all; 
        
        % Store the following for the image / frame 
        % Bounding Boxes (green)
        infoPoselets.boundingBoxesMain = bounds_predictions.select(bounds_predictions.score > display_thresh_bounds).bounds; % 4 x noOfBoxes 
        % Bounding Boxes of Torsos (blue)
        infoPoselets.boundingBoxesTorso = torso_predictions.select(torso_predictions.score > display_thresh_bounds).bounds; % 4 x noOfBoxes 
        % Bounding Boxes of poselets detected, their scores, and type
        for j = 1:1:min(poseletsInBounds.size,20)  % Number of poselet detections considered 
            infoPoselets.poseletTypeId(1,j) = poseletsInBounds.poselet_id(b(j)); 
        end
        
        for j = 1:1:min(poseletsInBounds.size,20)
            infoPoselets.boundingBoxesPoselets(:,j) = poseletsInBounds.bounds(:,b(j));
        end
      
        h1 = figure; 
        imshow(img);
        bounds_predictions.select(bounds_predictions.score > display_thresh_bounds).draw_bounds;
        torso_predictions.select(torso_predictions.score > display_thresh_bounds).draw_bounds('blue');
        
        infoPoselets.torso_predictions_score = [];
        ss_j = 1; 
        for j = 1:1:size(torso_predictions.score,1)
            if (torso_predictions.score(j,1) > display_thresh_bounds)
                infoPoselets.torso_predictions_score(ss_j,1) = torso_predictions.score(j,1);
                ss_j = ss_j + 1; 
            end
        end
        
        for j = 1:1:size(infoPoselets.torso_predictions_score,1)
            text(double(infoPoselets.boundingBoxesTorso(1,j)),double(infoPoselets.boundingBoxesTorso(2,j)),num2str(infoPoselets.torso_predictions_score(j,1),'%4.4f'),'BackgroundColor',[1,1,1],'Color',[0 0 0]);
        end
        saveas (h1, strcat(strtok(imgName,'.'),'-TORSOS_OVERLAYED'),'jpg'); 
        clf(h1); close all;
        
        infoPoselets.poseletScoresSorted = a'; % No of poselets across row 
        infoPoselets.display_thresh_poselets = display_thresh_poselets; 
        infoPoselets.display_thresh_bounds = display_thresh_bounds; 
        infoPoselets.torso_predictions.score = torso_predictions.score; 
        save (strcat(strtok(imgName,'.'),'-INFO_POSELETS'),'infoPoselets'); 
        
        % Clear the variables
        clear img; 
        clear imgName; 
        
        % Check the memory leak
        % [userview systemview] = memory
    else
        % disp('Entering interactive visualization.');
        params.poselet_patches = poselet_patches;
        params.all_torso_hits = torso_predictions;
        params.all_poselet_hits = poselet_hits;
        params.masks = fg_masks;

        bounds_predictions.image_id(:)=1;
        params.all_poselet_hits.image_id(:)=1;
        params.all_torso_hits.image_id(:)=1;
        browse_hits(bounds_predictions,im1,params);
    end