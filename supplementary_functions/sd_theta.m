% Compute standard deviation (SD) of angles between lines tangent to each pixel on the
% centerline and a reference-axis (i.e. x-axis) for a curve defined by x & y coordinates.

% Please cite the following paper if you use this code.
% Khansari, et al. "Method for quantitative assessment of retinal vessel tortuosity in % optical coherence 
% tomography angiography applied to sickle cell retinopathy." Biomedical optics express 8.8 (2017):3796-3806.

% Written by Maz M. Khansari (summer 2017)
% maziyar.khansari@gmail.com

%%
function [SD,slope] = sd_theta(x,y,isshow)

% compute ratio of derivative of y over x for determining tangent lines at each point on the curve
dy = diff(y)./diff(x);
% slope of reference axis (i.e. x-axis)
m1 = 0;                

% pre-allocate to avoid memory fragmentation
slope = zeros(1,length(x)-1);
theta = zeros(1,length(x)-1);

% repeat for all pixels of the curve
for k = 1:1:length(x)-1
    % tangent line to the curve
    tan_line = (x-x(k))*dy(k)+y(k);
    % slope of tangent line.
    coefficients = polyfit(x,tan_line,1);
    % save slopes in a vector
    slope(k) = coefficients(1);     
    m2 = coefficients(1);
    % compute angle between the tangent line and the x-axis (m1 = 0)
    angle = atan((m1-m2)/(1+m1*m2))*(180/pi);
    % save angle in a vector
    theta(k) = angle;
end

% if show option is true (i.e. is_show=1), make the plot
if isshow == 1
    for k = 1:length(x)-1
        hold on
        tan_line=(x-x(k))*dy(k)+y(k);
        plot(x,tan_line,':k','LineWidth',0.005);
        pause(10^-19);
    end
end

% remove NaNs, if any
theta_final = theta(~isnan(theta));
% SD of angles between tangent lines and x axis. Note that SD is divided by 100 to lie in range of 0 and 1
SD = std(abs(theta_final))/100; 

return
