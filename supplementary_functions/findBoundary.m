function boundaryList = findBoundary(binaryImage,startPt,endPt)

[sizeX,sizeY] = size(binaryImage);
%define boundry box size
sizeX_box = abs(startPt(2) - endPt(2)) + 250;
sizeY_box = abs(startPt(1) - endPt(1)) + 250;
%error checking?
if startPt(2) < endPt(2)
    i_start = startPt(2) - 100;
    if i_start <= 0
        i_start = startPt(2) - 20;
    end
    i_end = i_start + sizeX_box;
    if i_end >= sizeX
        i_end = i_start + sizeX_box - 100;
        if i_end < endPt(2)
            i_end = endPt(2) + 10;
        end
    end
else
     i_start = startPt(2)+100;
     if i_start >= sizeX
         i_start = sizeX-50;
     end
     i_end = i_start-sizeX_box;
     if i_end <= 0
         i_end = i_start-sizeX_box + 100;
     end
end
    
if i_end < i_start
    X_range = i_end:i_start;
else 
    X_range = i_start:i_end;
end

if startPt(1) < endPt(1)
    j_start = startPt(1)-100;
    if j_start <= 0
        j_start = startPt(1)-20;
    end
    j_end = j_start + sizeY_box;
    if j_end >= sizeY
        j_end = j_start + sizeY_box-100;
        if j_end < endPt(1)
            j_end = endPt(1)+10;
        end
    end
else
     j_start = startPt(1)+100;
     if j_start >= sizeY
         j_start = sizeX-50;
     end
     j_end = j_start-sizeY_box;
     if j_end <= 0
         j_end = j_start-sizeY_box+100;
     end
end
    
if j_end < j_start
    Y_range = j_end:j_start;
else 
    Y_range = j_start:j_end;
end


boundaryMap = zeros(length(X_range), length(Y_range));

for i = Y_range(1):Y_range(end)
    for j = X_range(1):X_range(end)
        if binaryImage(i,j)==1,
            neighbors = binaryImage(i-1:i+1,j-1:j+1);
            neighbors(2,2) = -1;
            %if sum(neighbors(:) == 1)>=1 && sum(neighbors(:) ==0)>=1,
            if sum(neighbors(:) ==0) >= 1,
                boundaryMap(i,j) = 1;
            end
        end
    end
end

[indX,indY] = find(boundaryMap==1);
boundaryList = [indX,indY];
