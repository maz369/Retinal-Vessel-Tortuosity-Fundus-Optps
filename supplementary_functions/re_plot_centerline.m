% This script load a fundus image and replot the centerlines. This
% is helpful for checking the centerlines and reproducing the result.
% It will also save a high quality image for publication (user can specify dpi).

% User needs to select the following:
% 1) directory where the centerlines are located
% 2) format of the image if it is not .tif (line 18; image_format = 'tif')
% 3) dpi of the output image if other than 600 (print -dtiff result.tif -r600)

% Written by Maz M. Khansari
% maziyar.khansari@gmail.com


%% Set directory and image format

% directory where centerlines are saved
dir_centerline = 'C:\Users\Mk\Desktop\VTI_OPTOS_ReleaseFinal\sample4';
image_format = 'tif';
cd(dir_centerline); % change MATLAB directory

% get image name because the name has been imbedded into the name of the folder
image_name = dir_centerline(max(strfind(dir_centerline,'\'))+1:end)

%% Load image and plot circles

% read and show the image
image = imread([image_name sprintf('.%s',image_format)]);
figure, imshow(image)
hold all
center_info = dlmread('circle_center.txt');
center_x = center_info(1);
center_y = center_info(2);
radius = center_info(3);
plot(center_x,center_y,'or','LineWidth',2);
circle(center_x,center_y,radius);
circle(center_x,center_y,1.5*radius);
circle(center_x,center_y,4*radius);

% fine mat files that contain centerline coordinates
coordinates = dir([dir_centerline '\*.mat']);
num_centerline = numel(coordinates)/2;

%% Plot centerlines

for i = 1:num_centerline  
    % read x-coordinates and convert to double
    x_file = sprintf('XVessel%d_%s.mat',i,image_name);
    x = cell2mat(struct2cell(load(x_file)));
    
    % read y-coordinates and convert to double
    y_file = sprintf('YVessel%d_%s.mat',i,image_name);
    y = cell2mat(struct2cell(load(y_file)));
    
    % plot the centerline
    hold on
    plot(x,y,'r','LineWidth',1) 
end

%% Export

% export high quality image (600 is dot per inch (dpi) and it can be c to a smaller
% number for lower resolution image)
print -dtiff result.tif -r600
