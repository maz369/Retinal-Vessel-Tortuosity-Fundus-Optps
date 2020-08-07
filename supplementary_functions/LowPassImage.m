function OutputImage = LowPassImage(InputImage);

% number of rows and columns in the image
[rows cols] = size(InputImage); 

% threshold
f = 0.25;
FiltSizeX = round(f*cols);
FiltSizeY = round(f*rows);
sigma     = round(0.25*min([FiltSizeX FiltSizeY]));

GausFilt    = fspecial('gaussian',[FiltSizeY FiltSizeX],sigma);
%AvgFilt     = fspecial('average',[FiltSizeY FiltSizeX]);
OutputImage = filter2(GausFilt,InputImage,'same');
 
