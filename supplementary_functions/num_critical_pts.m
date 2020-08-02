% Determine number of critical points in a curve defined by x and y coordinates
% A critical point is a point on the curve where the derivative vanishes (either zero or doesn't exist).
% In such a point, there is a change in sign of the slope of tangent lines.

% Please cite the following paper if you use this code
% Khansari, et al. "Method for quantitative assessment of retinal vessel tortuosity in % optical coherence 
% tomography angiography applied to sickle cell retinopathy." Biomedical optics express 8.8 (2017):3796-3806.

% Written by Maz M. Khansari (summer 2017)
% maziyar.khansari@gmail.com

%%
function N = num_critical_pts(x,y,isshow)
% initialize
N = 0;
dy = diff(y)./diff(x); % compute ratio of derivative of y over x to determine tangent lines at each point on the curve
slope = zeros(1,length(x)-1); % pre-allocate to avoid memory fragmentation

% compute slope of tangent lines for every pixel along the curve
for k = 1:1:length(x)-1              
    tang = (x-x(k))*dy(k)+y(k); % tangent line to the curve.
    coefficients = polyfit(x,tang,1);  % slope of the tangent line
    slope(k) = coefficients(1); % save slope
end

% number of times the sign of slope changed along the curve
for ii = 1:numel(slope)-1 
    previos = slope(ii);
    current = slope(ii+1); 
    if previos * current < 0
        N = N+1; % add 1 to the number of critical points (twists)
        
        % plot inflection points if is_show is True
        if isshow == 1
            hold on,
            plot(x(ii), y(ii),'og','markers',12,'LineWidth',4');
            pause(0.1)   
        end
    end
end

% if there is no critical point, set it to 1 so it will not affect final VTI value
if N == 0
    N = 1;
end

return
