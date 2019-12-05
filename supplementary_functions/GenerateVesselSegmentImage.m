function [OutputImage,whatScale,Direction] = GenerateVesselSegmentImage(ImgScaleStack,AnglesStack,Scale,sigmas,Threshold,MinSize);

[rows cols nDim] = size(ImgScaleStack);
    
StackIdxFirst = find(Scale(1) == sigmas);
StackIdxLast  = find(Scale(2) == sigmas);
         

    if length(sigmas) > 1,
        [outIm,whatScale] = max(ImgScaleStack(:,:,StackIdxFirst:StackIdxLast),[],3);
        outIm = reshape(outIm,[rows cols]);
        whatScale = reshape(whatScale,[rows cols]);
        %Direction = reshape(AnglesStack((1:rows*cols)'+(whatScale(:)-1)*rows*cols,[rows cols]));
        
        Direction = reshape(AnglesStack((1:numel(numel(AnglesStack(:,:,1))))'+(whatScale(:)-1)*numel(numel(AnglesStack(:,:,1)))),[rows cols]);
    else
        outIm = reshape(ImgScaleStack,[rows cols]);
        whatScale = ones([rows cols]);
        Direction = reshape(ALLangles,[rows cols]);

    end

OutputImage = outIm>Threshold;
OutputImage = bwareaopen(OutputImage,MinSize);

end

