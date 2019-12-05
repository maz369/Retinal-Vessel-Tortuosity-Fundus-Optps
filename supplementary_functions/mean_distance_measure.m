% Mean distance measure (DM) between points where the convexity of a curve changes. The curve or vessel 
% centerline is defined by x & y coordinates.

% Distance measure is the ratio of vessel length to its chord length. This can be used as a rough approximation 
% of tortuosity. However, this global estimation may not match human perception of tortuosity (Grisan, et al
% 2008). In the current work, we used local distance measure between inflection points and showed that it better 
% matches with visual perception of tortuosity.

% Please cite the following paper if you use this code :)
% Khansari, et al. "Method for quantitative assessment of retinal vessel tortuosity in % optical coherence 
% tomography angiography applied to sickle cell retinopathy." Biomedical optics express 8.8 (2017):3796-3806.

% Written by Maz M. Khansari (summer 2017)
% maziyar.khansari@gmail.com

%%
function [mean_dm,ipf,curvature] = mean_distance_measure(x,y,isshow)

% index initialization
idx_ifp = 1;
N = 0;

%% curvature approximation
dx = diff(x); % 1st derivative of x vlaues
dy = diff(y); % 1st derivative of y values
dx2 = (dx(1:end-1)+dx(2:end))/2; % 2nd derivative of x values
dy2 = (dy(1:end-1)+dy(2:end))/2; % 2nd derivative of y values

% remove the last element to match length of the 1st and 2nd derivatives to enable vector multiplication
dx = dx(1:end-1);
dy = dy(1:end-1);

k = (((dx.*dy2)-(dx2.*dy)))./((((dx).^2)+((dy).^2)).^(3/2)); % curvature of the curve based on x and y coordinates
k = k+eps; % adding epsilon to avoid zero values. Due to discrete integral, inflection points can be very close to zero
curvature = mean(abs(k));

%% Detecting points of changes in sign of the curvature (inflection points).
% *** The DM between the 1st point on the curve and the first inflection point was computed separately. Similarly, DM between the last inflection
% point and the end point of the vessel segment was computed separetly.

for i = 1:numel(k)-1  % number of times slope sign changed along the curve
    previos = k(i);
    current = k(i+1);
    if previos*current < 0  % points of convexity change
        N = N+1; % count number of inflection points       
        if N == 1  % DM between the first point on the curve and the first inflection point
            idx = i+1;
            chord_len = sqrt((x(idx)-x(1))^2+(y(idx)-y(1))^2); % chord length between the 1st point and the 1st inflection point
            [arc_len,~] = arc_length(x(1:idx),y(1:idx)); % arc length between the 1st point and the 1st inflection point
            DM(idx_ifp) = arc_len/chord_len;  % DM between the 1st curve point and the 1st inflection point
            previous_pt = idx; % record index of the inflection point
            % plot inflection points if is_show is True
            if isshow == 1
                hold on, plot(x(1),y(1),'or','LineWidth',2);
                plot(x(idx),y(idx),'or','LineWidth',2);
                line([x(1),x(idx)],[y(1),y(idx)],'LineWidth',2);
                plot(x(1:idx),y(1:idx),'r'); pause(0.05)       
            end            
        elseif N > 1 % compute DM for the 2nd and the rest of infleciton points
            idx_ifp = idx_ifp+1;
            idx = i+1; % Index for saving DM value.
            chord_len = sqrt((x(idx)-x(previous_pt))^2+(y(idx)-y(previous_pt))^2); % chord length between inflection points
            [arc_len,~] = arc_length(x(previous_pt:idx),y(previous_pt:idx)); % arc length between inflection points
            DM(idx_ifp) = arc_len/chord_len;   % DM between the inflection points.
            % plot inflection points if is_show is True
            if isshow == 1
                hold on all,plot(x(idx),y(idx),'or','LineWidth',2);
                plot(x(previous_pt),y(previous_pt),'or','LineWidth',2);
                line([x(previous_pt),x(idx)],[y(previous_pt),y(idx)],'LineWidth',2);
                plot(x(previous_pt:idx),y(previous_pt:idx),'r'); pause(0.2)     
            end
            previous_pt = idx;
        end
    end
end

% if there are more than 1 inflection point, determine DM between the last inflection point and the end point
if N >= 1  
    idx_ifp = idx_ifp+1;
    chord_len = sqrt((x(end)-x(previous_pt))^2+(y(end)-y(previous_pt))^2); % chord length between the last inflection point and the endpoint
    [arc_len,~] = arc_length(x(previous_pt:end),y(previous_pt:end)); % arc length between the last inflection point and the endpoint
    DM(idx_ifp) = arc_len / chord_len; % DM between the last inflection point and the endpoint
    
    % plot inflection points if is_show is True
    if isshow == 1
        hold on all, plot(x(end),y(end),'or','LineWidth',2);
        plot(x(previous_pt),y(previous_pt),'or','LineWidth',2);
        line([x(previous_pt),x(end)],[y(previous_pt),y(end)],'LineWidth',2);
        plot(x(previous_pt:end),y(previous_pt:end),'r');
    end
end

% if the curve has no inflection point, compute DM between the start and endpoint
if N < 1  
    chord_len = sqrt((x(end)-x(1))^2+(y(end)-y(1))^2); % chord length between the start and end points of the curve
    [arc_len,~] = arc_length(x,y); % arc length between the start and end points of the curve
    DM(idx_ifp) = arc_len/chord_len; % DM between the start and end points of the curve
end

if N >= 1
    DM(1) = [];
    DM(end) = [];
    ipf = numel(DM)+1;
else
    ipf = 1;
end

mean_dm = mean(DM);  % compute average of DM between inflection points including the start and end point.

% set mean_dm to 1 if there was no inflection point so it has no effect on VTI
if isnan(mean_dm)
    mean_dm = 1;
end

return
