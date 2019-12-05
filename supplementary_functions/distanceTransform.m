function fieldImage = distanceTransform(binaryImage,distanceMetric,seedList,isPlot)
%% create a distancefield from a binary image.
%inputs: -bindaryImage is the input binary image, where object=1 and
%        background=0.
%        -distanceMetric is the distance metric for doing coding-based iterations.
%        -seedList is a initial list of coordinate of the seeds.

if nargin<4
    isPlot = 0;
end

%for viz.
seedListOrg = seedList;

%initiate distance field
fieldImage=binaryImage;
[imageSizeX,imageSizeY]=size(fieldImage);

%let object = 0
fieldImage(binaryImage==1)=0; 

%let background = -1
fieldImage(binaryImage~=1)=-1;

%check size of seed list
[seedListSize,trash]=size(seedList);

for i = 1 : seedListSize
    fieldImage(seedList(i,1),seedList(i,2))=1;
end

%while there is still seeds inside the list.
while seedListSize >=1,
    
    %find neighboring Pixel and replace field value by pixel field+distance
    %metric value
    seedListToProcess = [];
    for i = 1 : seedListSize,
        
        %for each seed, process neighboring pixels
        %if seed is object pixel and is not near image boundary
        seed=seedList(i,:);
        if binaryImage(seed(1),seed(2))==1 && ...
                seed(1)-1 > 0 && ...
                seed(1)+1 <= imageSizeX && ...
                seed(2)-1 > 0 && ...
                seed(2)+1 <= imageSizeY,
            
            %go through neighboring object pixel
            for i=-1:1:1,
                for j=-1:1:1,
                    
                    seedI = seed(1)+i;
                    seedJ = seed(2)+j;
                    if (seedI ~= seed(1) || seedJ ~=seed(2)) &&...
                            binaryImage(seedI, seedJ) == 1,

                        val = fieldImage(seed(1),seed(2)) + distanceMetric(i+2,j+2);
                        if fieldImage(seedI,seedJ) == 0,
                            %update field value
                            fieldImage(seedI,seedJ)=val;
                            seedListToProcess=[seedListToProcess;[seedI,seedJ]];                            
                        elseif fieldImage(seedI,seedJ) > val,
                            %update field value
                            fieldImage(seedI,seedJ)=val;
                            seedListToProcess=[seedListToProcess;[seedI,seedJ]];
                        end
                    end
                end
            end
        end
    end
       
    %replace seedList
    seedList=seedListToProcess;
    %check size of seed list
    [seedListSize,trash]=size(seedList);

    if isPlot,
    %visualize the grass fire    
    if distanceMetric(1) == 5,
       imagesc(fieldImage,[-1 10]);colormap('gray');axis image; axis off
       hold on;plot(seedListOrg(:,2),seedListOrg(:,1),'g.','Linewidth',1);
       title('calculating boundary seeded field');pause(1);
    elseif distanceMetric(1) == 2,
       imagesc(fieldImage);colormap('gray');axis image; axis off
       hold on;plot(seedListOrg(:,2),seedListOrg(:,1),'g.','Linewidth',3);
       title('calculating single-seed seeded field');drawnow;
    end
    end %of isPlot
end
