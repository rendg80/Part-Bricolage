function [fileNames,number] = getFiles(folderName,fileFormat)
% -------------------------------------------------------------------------
% Author: Sukrit Shankar.
% Date : 28 Oct, 2011. University of Cambridge.
% *****************************************************
% This function gets all the file names of the specified fileFormat from the
% folderName in fileNames and the corresponding number in number. fileNames
% is a cell array of a single column and rows equal to number. For JPEG files, 
% specify 'jpg' only, etc. 
% *****************************************************
% INPUT ARGUMENTS - Path name of the folder, File Format
% OUTPUT ARGUMENTS - fileNames is a cell array with all file names, number
% contains the number of file names thus found. 
% *****************************************************
% Example - getFiles ('MIT-CBCL-facerec-database\training-originals','jpg'); 
% -------------------------------------------------------------------------

%% Find all files within the specified folder. 
queryString = strcat(folderName,'/*',fileFormat);
dirList = dir (queryString); 

% Get the filenames
fileNames = cell (size(dirList,1),1); 
for i = 1:1:size(dirList,1)
    fileNames{i,1} = dirList(i).name; 
end 

% Store the count in number.
number = size(dirList,1); 