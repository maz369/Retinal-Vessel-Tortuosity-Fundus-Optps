function [skeletonSmoothedY,skeletonSmoothedX,xX,yY] = distance_transform_fundus(binaryImage,intImage,x1,y1,r)

isPlot = 0;
binary_image_orig = binaryImage;
user_happy = 'n';
while strcmpi(user_happy,'n')
    
%% Start point
    
    figure(2);
    set(figure(2),'pos',[840 200 700 700]), axis off
    axis([x1-(4*r), x1+(4*r),y1-(4*r),y1+(4*r)]);
    
    padding = 5;
    bImgSz = size(binaryImage);
    
    imagesc(binaryImage);colormap('gray');axis([x1-(4*r), x1+(4*r),y1-(4*r),y1+(4*r)]);
    hold on; plot(x1,y1,'*r');circle(x1,y1,r);
    circle(x1,y1,1.5*r);circle(x1,y1,4*r);
    axis off
    
    hold on;
    plot([1+padding, 1+padding, bImgSz(2)-padding,  bImgSz(2)-padding, 1+padding],...
        [1+padding, bImgSz(1)-padding,bImgSz(1)-padding, 1+padding,  1+padding],'g-','Linewidth',1);
    axis([x1-(4*r), x1+(4*r),y1-(4*r),y1+(4*r)]);
    
    [x,y] = ginputc(2, 'Color', 'r', 'LineWidth', 1, 'LineStyle', '-');
    axis off
    startPt = round([y(1),x(1)]);
    endPt   = round([y(2),x(2)]);
    
    hold on; plot(startPt(2),startPt(1),'r.','Linewidth',2);
    hold on; plot(x1,y1,'*r');circle(x1,y1,r);
    circle(x1,y1,1.5*r);circle(x1,y1,4*r); axis off
    imagesc(binaryImage);colormap('gray');axis([x1-(4*r), x1+(4*r),y1-(4*r),y1+(4*r)]);
    
    hold on;
    plot(endPt(2),endPt(1),'r.','Linewidth',80); axis off
    
%% begin algorithm
    
    %initialize distance metrices
    distanceMetricSs = [[2,1,2];[1,0,1];[2,1,2]];
    distanceMetricBs = [[5,3,5];[3,0,3];[5,3,5]];
    
    %create Single-seed Seeded Field
    ssField = distanceTransform(binaryImage,distanceMetricSs,startPt,isPlot);
    
    if isPlot
        [x,y] = ginputc(1, 'Color', 'r', 'LineWidth', 1, 'LineStyle', '-');
        axis off
    end
    
    boundaryList = findBoundary(binaryImage,startPt,endPt);
    
    % create Boundary Seeded Field
    bsField = distanceTransform(binaryImage,distanceMetricBs,boundaryList,isPlot);
    if isPlot
        [x,y] = ginputc(1, 'Color', 'r', 'LineWidth', 1, 'LineStyle', '-');
        axis off
    end
    
    % extract vessel skeleton
    skeleton = extactSkeleton(ssField,bsField,startPt,endPt,isPlot);
    
    if isPlot
        [x,y] = ginput(1);
    end
    
%% smooth vessel skeleton to vessel centerline

    [skeletonSize,~] = size(skeleton);
    skeletonIndex = 1:1:skeletonSize;
    
    skeletonSmoothedX = csaps_pt(skeletonIndex,skeleton(:,1),3e-5,skeletonIndex);
    skeletonSmoothedY = csaps_pt(skeletonIndex,skeleton(:,2),3e-5,skeletonIndex);
    
%% Plot endpoints and the centerline
    
    figure(1), hold on
    h1 = plot(skeletonSmoothedY,skeletonSmoothedX,'r','Linewidth',0.001);
    xX = abs(skeletonSmoothedY(round(1)));
    yY = abs(skeletonSmoothedX(round(1)));
    h2 = plot(startPt(2),startPt(1),'r.','Linewidth',2);
    h3 = plot(endPt(2),endPt(1),'r.','Linewidth',2);
    
%% check user's input on centerline quality

    answer = questdlg('Good Centerline?', ...
        'Quality Check', ...
        'Yes','No - Replot','No - Clean Area','No Clean Image');
    
    % handle response
    switch answer
        case 'Yes'
            disp([answer ': user is happy with the centerline'])
            user_choice = 0;
            user_happy = 'y';
        case 'No - Replot'
            disp([answer ': user wants to select enpoints'])
            user_choice = 1;
            user_happy = 'n';
        case 'No - Clean Area'
            disp([answer ': user wants to clean vessel neighborhood and select enpoints'])
            user_choice = 2;
            user_happy = 'n';
    end
    
    if user_choice == 1
        figure(2)
        delete(h1); delete(h2); delete(h3);
    elseif user_choice == 2
        figure(2)
        delete(h1); delete(h2); delete(h3);
        binary_mask = roipoly;
        delete_idx = find(binary_mask == 0);
        binaryImage(delete_idx) = 0;
        
        % Keep or reverse; this option has been included to allow the user to get back to the original image without being forced to analyze the image from the
        % beginning.
        answer1 = questdlg('Reset?', ...
            'Keep or Reset', ...
            'Keep','Reset','Reset');
    
        if isequal(answer1,'Keep')
            continue
        elseif isequal(answer1,'Reset')
            binaryImage = binary_image_orig;
        end
        clear answer1   
    end
    
end
figure(1), hold off
