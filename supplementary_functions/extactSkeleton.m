function skeleton=extactSkeleton(ssField,bsField,startPt,endPt,isPlot)

if nargin < 5
    isPlot = 1;
end

%created only for visualization purpose
bsFieldTmp = bsField;
ssFieldTmp = ssField;

%extract skeleton from startPt to endPt from ssField and bsField
startPtVal = ssField(startPt(1),startPt(2));
[imageSizeX,imageSizeY] = size(ssField);
skeleton = endPt;
currentPt = endPt;
currentVal = ssField(currentPt(1),currentPt(2));

radius = 6;
diameter=radius*2+1;

%while value not at the very starting point and not at image boundary
while currentVal ~= startPtVal &&...
        currentPt(1)-radius >= 1 &&...
        currentPt(1)+radius <= imageSizeX &&...
        currentPt(2)-radius >= 1 &&...
        currentPt(2)+radius <= imageSizeY,

    %extract neighboring field of the current point.
    neighborSsRegion = ssField(currentPt(1)-radius:currentPt(1)+radius,currentPt(2)-radius:currentPt(2)+radius);
    neighborBsRegion = bsField(currentPt(1)-radius:currentPt(1)+radius,currentPt(2)-radius:currentPt(2)+radius);
    
    %find points with lower Ss value than the current field.
    neighborInd = ( neighborSsRegion == currentVal-1 );
    %neighborInd = neighborInd + (neighborSsRegion == currentVal-2);

    if ~any(neighborInd),
        display('break');
        break;
    end
    
    %if there are muliple valid points in neighborInd, obtain one that is
    %most centered (check for max of BS value)
    neighborTmpRegion = neighborBsRegion.*neighborInd;    
    [valM,indM]=max(neighborTmpRegion(:));
    if isempty(indM),
        display('break');
        break;
    end
    
    %obtain the coordinate of that point.
    [neighborIndX,neighborIndY]=ind2sub([diameter,diameter],indM);
    currentPt = [currentPt(1)+neighborIndX-radius-1,currentPt(2)+neighborIndY-radius-1];
    currentVal = ssField(currentPt(1),currentPt(2));
    skeleton = [skeleton;currentPt];
    
    %bsFieldTmp(currentPt(1),currentPt(2))=-1;
    %ssFieldTmp(currentPt(1),currentPt(2))=-1;

    if isPlot,
    subplot(1,2,1);
    imagesc(bsField);colormap(gray);hold on;axis image;
    plot(skeleton(:,2),skeleton(:,1),'r-','Linewidth',2);
    title('boundary seeded field');
    subplot(1,2,2);
    imagesc(ssField);colormap(gray);hold on;axis image;
    plot(skeleton(:,2),skeleton(:,1),'r-','Linewidth',2);    
    title('single-seed seeded field');
    drawnow;
    end
end
