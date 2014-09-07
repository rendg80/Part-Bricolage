function demo(img, imgName, relPathToStore) 

% Clear variables
clearvars -except configPB folderPath i j mainPath numFrames numberOfsubfolders relPathToStore subFolderNames categoryNames noOfClasses imgName img; 

addpath visualization;
if isunix()
  addpath mex_unix;
elseif ispc()
  addpath mex_pc;
end

compile;

% load and display model
load('PARSE_model');

%visualizemodel(model);
%disp('model template visualization');
%disp('press any key to continue'); 
%pause;
%visualizeskeleton(model);
%disp('model tree visualization');
%disp('press any key to continue'); 
%pause;

% load and display image
% im = imread(['importantImagesToTestFirst/' imlist(i).name]);
%clf; imagesc(im); axis image; axis off; drawnow;

% call detect function
% tic;
boxes = detect_fast(img, model, min(model.thresh,-1));
% dettime = toc; % record cpu time
boxes = nms(boxes, .1); % nonmaximal suppression
colorset = {'g','g','y','m','m','m','m','y','y','y','r','r','r','r','y','c','c','c','c','y','y','y','b','b','b','b'};

% showboxes(im, boxes(1,:),colorset); % show the best detection
h = figure; showboxes(img, boxes,colorset);  % show all detections
cd (relPathToStore); % Go to the path to store  
saveas(h,strcat(strtok(imgName,'.'),'-FMP_OVERLAY'),'jpg'); 
clf(h); close all; 

% Save the bounding boxes for the parts detected, the type of parts and
% their scores - All info is contained in boxes 
if (size(boxes,1) == 0)
    infoFMP.boxes = []; 
    infoFMP.scores = []; 
    save (strcat(strtok(imgName,'.'),'-INFO_FMP'),'infoFMP'); 
else
    infoFMP.boxes = boxes(:,1:104); % For 26 parts 
    infoFMP.scores = boxes(:,106) + 1; % Add 1 to the scores for bringing to 0-1 scale 
    save (strcat(strtok(imgName,'.'),'-INFO_FMP'),'infoFMP'); 
end

%fprintf('detection took %.1f seconds\n',dettime);
%disp('press any key to continue');
%pause (2);

disp('done');

% Clear the variables
clear img imgName; 

% [userview systemview] = memory
