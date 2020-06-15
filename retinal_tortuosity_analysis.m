% =========================================== GENERAL EXPLANATION ==============================================
% This script is for quantification of retinal vessel tortuosity in fundus/OPTOS images. Several measures of 
% tortuosity is calculated and saved in an excel file. Tortuosity measures are based on vessel centerline
% within a circumpapillary region centered on the optic nerve head (ONH). The user needs to select the center
% of ONH and its diameter. Also, the user can modify thresholds for vessel segmentation. Additionally, 
% the user needs to select endpoints of each vessel for extracting the centerline and calculating its 
% tortuosity. Please see the user manual (Retinal Vessel Tortuosity.pdf) for further instruction.


% ================================================== EXAMPLE ====================================================
% Change current MATLAB directory to where the files are downloaded (where retinal_tortuosity_analysis.m is 
% located). Update UserDefined.DefaultDir in setup section of "retinal_tortuosity_analysis.m" file to the directory 
% where the files are downloaded. Run "retinal_tortuosity_analysis.m". A pop-up window will show up and the user can
% select % sample4.tif which is a fundus retinal image. Please check the user manual file in the main folder for
% further instruction (Retinal Vessel Tortuosity FUNDUS.pdf).

% A new folder which has the same name as the image is created to contain the results. An excel file will be
% placed in that folder to contain all the results. There will be two sheets in the excel file. Sheet1 is for
% tortuosity measurements and Sheet2 contains variables used for tortuosity measures plus a copy of the fundus
% image with centerlines overlaid.

% To replot centerlines of an already analyzed image, use "re_plot_centerline.m" under "supplementary_functions" 
% folder. Please check the pdf manual for additional explanation.


% =========================================== PARAMETER EXPLANATION =============================================
% The main tortuosity measurements are the following:
%  VTI: vessel tortuosity index. (VTI = 0.1*(len_arch * sd * num_critical_pts * (mean_dm)) / len_cord).
%  curvature: mean absolute curvature.
%  DI: density index. Mean distance measure between inflection points, normalized by vessel length.
%  DM: distance measure. Ratio of vessel length to its chord length.

% Other variables that are needed for calculating the main measures are the following:
%  sd: standard deviation of angels between lines tangent to every pixel along the centerline.
%  mean_dm: average distance measure between inflection points along the centerline.
%  num_inflection_pts: number of inflection points along the centerline.
%  num_critical_pts: number of critical points along the centerline.
%  len_arch: length of vessel (arch) which is number of centerline pixels.
%  len_cord: length of vessel chord which is the shortest path connecting vessel end points.


% ================================================ LICENSE =======================================================
% This software has been released to promote research and education in medical image analysis. 
% Feel free to use and/or redistribute for any non-commercial application.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
% OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR LIABILITY, WHETHER IN AN ACTION OF ONTRACT, TORT 
% OR, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR USINF OTHER DEALINGS IN THE SOFTWARE.


% ========================================== REFERENCE AND DEFINITION =============================================
% Mathematical definition of vessel tortuosity index (VTI) can be found in our previously published paper:
% Please cite the following paper if you use this code.

% 1) Khansari, et al. "Method for quantitative assessment of retinal vessel tortuosity in % optical coherence 
%    tomography angiography applied to sickle cell retinopathy." Biomedical optics express 8.8 (2017):3796-3806.
% 2) Khansari, et al. "Relationship between retinal vessel tortuosity and oxygenation in sickle cell retinopathy"
%    IJRV (Springer Nature), DOI: 10.1186/s40942-019-0198-3

% Segmentation part is by Hessian filtering implemented by Dirk-Jan Kroon: https://www.mathworks.com/matlabcentral/
% fileexchange/24409-hessian-based-frangi-vesselness-filter


% ================================================== AUTHOR ========================================================
% Maz M. Khansari
% maziyar.khansari@gmail.com

% Release: 1.0, Date: 11/11/2019


%% Setup for directories, images and the format of the image

clearvars, close, clc, warning off;

% path to supplementary_functions
current_path = cd;
addpath([current_path '\Supplementary_functions']);

% path to images
UserDefined.DefaultDir = 'C:\Users\Mk\Desktop\VTI_OPTOS_ReleaseFinal\';
image_format = 'tif';

%% Hessian based vessel segmentation

UserDefined.Application = 'Optos';
Options.FrangiBetaOne = 0.5; % beta-1
Options.FrangiBetaTwo = 15; % beta-2
UserDefined.DiskDiameter = 5; % disk diameter
UserDefined.WorB = 'b'; % white or black vessels
UserDefined.Threshold = 0.001; % threshold of FRANGI
Options.FrangiScaleRatio = 2; % scale ration for FRANGI
UserDefined.SizeThresh = 1000; % size threshold of binary
Options.FrangiScaleRange = [1 21]; % scale range for FRANGI
UserDefined.ScaleRange = [3 5]; % initial scale range for FRANGI
UserDefined.Theta_Inc = 0.025; % degree for crearing ring display
Options.BlackWhite = true; % true = Dark vessels, false = bright vessels
UserDefined.InterpInterval = 0.1; % intensity interpolation 1/10 pixelOptions.
UserDefined.Resolution = 12; % um/pixel -- assumption: diameter of otic nerver head = 1.5 mm

if exist(UserDefined.DefaultDir,'dir') == 0
    UserDefined.DefaultDir = 'C:\';
end

% select the image
[file_name, path_name, filt_idx] = uigetfile([UserDefined.DefaultDir,strcat('*.',image_format)],'Choose Fundus Image ');

% creat a folder which has the same name as the image, then copy the image into the folder and update directory
[~,img_name, ext] = fileparts(file_name);
mkdir(img_name)
sprintf('%s%s',path_name,img_name)
copyfile([path_name,file_name],[path_name,img_name]);
path_name = [path_name,img_name '\']; % update path_name to save the results in the new folder

ImageStruct = imfinfo([path_name [img_name,ext]]);
if numel(ImageStruct) == 1
    ImageStruct.IntImages = imread(ImageStruct.Filename,image_format);
    img = ImageStruct.IntImages;
    ImageStruct.IntImages = double(ImageStruct.IntImages);
    if size(ImageStruct.IntImages,3) > 1
        ImageStruct.IntImages = ImageStruct.IntImages(:,:,1:2);
        ImageStruct.o2InsensitiveInd = 2;
        ImageStruct.o2SensitiveInd = 1;
        
        ImageStruct.IntImage = ImageStruct.IntImages(:,:,2); % use green image for analysis
        ImageStruct.isODR = 1;
    else
        ImageStruct.IntImage = double(imread(ImageStruct.Filename,image_format));
        ImageStruct.isODR = 0;
        ImageStruct.o2InsensitiveInd = nan;
    end
else
    disp('image structure not supported, using 1st image');
    ImageStruct = ImageStruct(1);
    ImageStruct.IntImage = double(imread(ImageStruct.Filename,image_format));
    ImageStruct.IntImage = ImageStruct.IntImage(:,:,1);
    ImageStruct.isODR = 0;
    ImageStruct.o2InsensitiveInd = nan;
    ImageStruct.o2SensitiveInd = nan;
end
ImageStruct.FILENAME = file_name;
ImageStruct.PATHNAME = path_name;
ImageStruct.UserDefined = UserDefined;
ImageStruct.FiltImage = LowPassImage(ImageStruct.IntImage);
ImageStruct.SubtImage = ImageStruct.IntImage - ImageStruct.FiltImage;
InputImage = ImageStruct.SubtImage;
[Sigma,ImgScaleStack,AnglesStack] = FrangiFilter2D_wScaleStack(InputImage,Options);
disp('Done with vessel filtering')

% adjust vessel segmentation threshold and scale
user_happy = 'n';
while strcmpi(user_happy,'n')
    greenImage = cat(3, zeros(size(InputImage)),ones(size(InputImage)), zeros(size(InputImage)));
    redImage = cat(3, ones(size(InputImage)),zeros(size(InputImage)), zeros(size(InputImage)));
    [ImageStruct.BW,whatScale,Direction] = GenerateVesselSegmentImage(ImgScaleStack,AnglesStack,UserDefined.ScaleRange,...
        Sigma,UserDefined.Threshold,UserDefined.SizeThresh);
    hfig1 = figure(1); % hack for speed
    h1 = imagesc(InputImage);axis image; colormap(gray(256)); axis off
    hold on
    h = imagesc(greenImage);
    hold off
    set(h, 'AlphaData',0.5*ImageStruct.BW);
    set(hfig1,'pos',[10 10 1200 1000]);
    prompt = {'Happy with Segmentation? (y or n)',['Max Scale ODD ONLY (1 - ', ...
        num2str(Options.FrangiScaleRange(2)),') ODD ONLY'],'Min Scale','Threshold','Min Object Size'};
    name = 'Segmentaion Parameters';
    numlines = 1;
    defAnswer = {'n',num2str(UserDefined.ScaleRange(2)),num2str(UserDefined.ScaleRange(1)),num2str(UserDefined.Threshold),...
        num2str(UserDefined.SizeThresh)};
    user_input = inputdlg(prompt,name,numlines,defAnswer);
    user_happy = user_input{1};
    UserDefined.ScaleRange(2) = str2double(user_input{2}); % specific to Heidelberg Spectralis SLO Images
    if mod(UserDefined.ScaleRange(2),2) == 0
        UserDefined.ScaleRange(2) = UserDefined.ScaleRange(2) - 1;
    end
    UserDefined.ScaleRange(1) = str2double(user_input{3}); % specific to Heidelberg Spectralis SLO Images
    if mod(UserDefined.ScaleRange(1),2) == 0
        UserDefined.ScaleRange(1) = UserDefined.ScaleRange(1) - 1;
    end
    if UserDefined.ScaleRange(1) > UserDefined.ScaleRange(2)
        UserDefined.ScaleRange(1) = UserDefined.ScaleRange(2);
    end
    UserDefined.Threshold = str2double(user_input{4});
    UserDefined.SizeThresh = str2double(user_input{5});
    close(hfig1)
end

%% Selecting optic nerve head

ScrSize = get(0,'screensize'); % get screen size for showing the image
fig1 = figure(1);
fig1; set(fig1,'OuterPosition',ScrSize), imshow(img)
[x1,y1] = getpts(fig1); % get coordinates of the center of optic nerve head
radius = 50; % original radius of optic nerve head (user can modify in the pop-up menu)
hold on, plot(x1,y1,'or','Linewidth',2);
circle(x1,y1,radius);
user_happy = 'n';
% default answer (number of pixels) for radius of ONH. This can be very different for an image with a different resolution
DefAnswer = {'n','50'};

% pop-up menu for user to modify the circumpapillary regions
while strcmpi(user_happy,'n')
    prompt = {'Diameter looks good? (y or n)','New Diamter'};
    name = 'Change Disk Diameter';
    numlines = 2;
    user_input = inputdlg(prompt,name,numlines,DefAnswer);
    user_happy = user_input(1);
    radius = str2double(cell2mat(user_input(2)));
    DefAnswer = {'n',sprintf('%d',radius)};
    ScrSize = get(0,'screensize');
    fig1 = figure(1);  set(fig1,'OuterPosition',ScrSize);
    imshow(img); hold on % show image and keep hold for overlaying circles
    plot(x1,y1,'.r','Linewidth',2);
    circle(x1,y1,radius); % circle around optic nerve head
    circle(x1,y1,1.5*radius); % circle with radius 1.5X of that of ONH
    circle(x1,y1,4*radius); % circle with radius 4X of that of ONH
end

% keep only one value for center of ONH
if numel(x1) > 1
    x1 = x1(1);
end

if numel(y1) > 1
    y1 = y1(1);
end

close all

%% Delete vessels inside and outside the circle

figure(1), imshow(adapthisteq(img(:,:,2))) % show green channel image after adoptive histogram equalization
set(figure(1),'pos',[10 10 820 1000]);
hold on; plot(x1,y1,'or','LineWidth',2);

% replot the circles for visualization
circle(x1,y1,radius);
circle(x1,y1,1.5*radius);
circle(x1,y1,4*radius);
dlmwrite([path_name 'circle_center.txt'],[x1,y1,radius]); % save coordinates of the center of ONH

binary_img = ImageStruct.BW;
[num_rows,num_cols,d] = size(binary_img);

% plot the first circle
ci = [y1, x1, 1.5*radius];
[xx,yy] = ndgrid((1:num_rows)-ci(1),(1:num_cols)-ci(2));
mask = uint8((xx.^2 + yy.^2)>ci(3)^2);
binary_img = double(binary_img).*double(mask);

% plot the second circle
ci = [y1, x1, 4*radius];
[xx,yy] = ndgrid((1:num_rows)-ci(1),(1:num_cols)-ci(2));
mask = uint8((xx.^2 + yy.^2)<ci(3)^2);
binary_img = double(binary_img).*double(mask);

%% calculate tortuosity and save data (tortuosity measures & centerline coordinates)

user_happy = 'y';
id = 0;
idx = 1; % index for saving the data

while strcmpi(user_happy,'y')
    % remove try - exception for debugging. This code is made to run smooth without bringing up an error in the middle of the process
    try
        % extract the centerline
        [centerline_xa,centerline_ya,x,y] = distance_transform_fundus(double(binary_img),img,x1,y1,radius);  % Extract the centeline from the vessel segment.
        figure(1), hold on
        id = id+1;
        
        % calculate tortuosity measures
        [vti,sd,mean_dm,num_inflection_pts,num_cpts,len_arch,len_cord,curvature] = vessel_tortousity_index(centerline_xa,centerline_ya,0);
        dm = len_arch/len_cord; % distance measure which is the ratio of vessel length to its chord length (the most commmon measure in litrature)
        di = mean_dm/len_cord; % density index similar to the one by Grisan et al
        
        % print the result in command window
        fprintf('Vessel number <strong>%.2f</strong>:\n', id)
        fprintf('              <strong>Vessel Tortuosity Index</strong>: <strong>%.2f</strong>\n',vti)
        fprintf('              Mean Absolute Curvature: <strong>%.2f</strong>\n',curvature)
        fprintf('              Vessel Density Index: <strong>%.2f</strong>\n',di)
        fprintf('              Distance Measure: <strong>%.2f</strong>\n',dm)
        fprintf('- - - - - - - - - - - - - - - - - - - - - - \n')
        
        % save coordinate of the centerline
        save([path_name,sprintf('XVessel%d_%s.mat',[id,file_name(1:end-4)])],'centerline_xa')
        save([path_name,sprintf('YVessel%d_%s.mat',[id,file_name(1:end-4)])],'centerline_ya')
        
        % overlay vessel number on the figure
        figure(1), hold on
        h = text(x,y,num2str(id));
        set(h,'Color','g','FontSize',15,'FontWeight','bold');
        idx = idx+1;
        cell = sprintf('A%d',idx);
        
        % organize data into cell array and export to excel file
        data = {idx-1,file_name,vti,num_inflection_pts,di,dm,curvature};
        data_1 = {idx-1,file_name,sd,num_inflection_pts,num_cpts,len_arch,len_cord};
        tag_1 = {'Vessel Num','Name','SD','Num Inflection Points','Num Critical Points','Arch Length','Chord Lenght','A/V'};
        xlswrite([path_name '\' file_name(1:end-4),'.xls'],data,'Sheet1',cell);
        xlswrite([path_name '\' file_name(1:end-4),'.xls'],data_1,'Sheet2',cell);
        
        % let user decide to analyze another vessel or finish the process
        answer = questdlg('Add new vessels?','NEW VESSEL','Yes','No','No');
        if isequal(answer,'No')
            user_happy = 'n';
        end
        
        clear centerline_xa centerline_ya
        
    catch exception
        err = errordlg('CenterLine Not Found','Error');
        clear CenterLineXa CenterLineYa
        uiwait(err)
    end
    
end

% close figure(2) if the analysis is over
close(figure(2))

% data and figure for sheet 1 (different measures of tortuosity)
tag = {'Vessel Num','Name','Vessel Tortuosity Index (VTI)','Num Inflection Points (VII)',...
    'Density Index (DI)', 'Distance Measure (DM)', 'Mean Absolute Curvature (MAC)'};
xlswrite([path_name '\' file_name(1:end-4) '.xls'],tag,'Sheet1','A1');

% data and figure for sheet 2 (all the parameters used for tortuosity calculation)
tag_1 = {'Vessel Num','Name','SD','Num Inflection Points','Num Critical Points','Arch Length','Chord Lenght','A/V'};

xlswrite([path_name '\' file_name(1:end-4) '.xls'],tag_1,'Sheet2','A1');
xlsPasteTo([path_name '\' file_name(1:end-4) '.xls'],'Sheet2',512,512,'I2');

% close all files
fclose('all'); 
