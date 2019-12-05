% Function for calculating tortuosity of vessels based on its centerline in 2D. Initially implemented for 
% retinal vessels but theoretically applicable to any 2D curvilinear shape.

% x & y represent coordinates of vessel centerline or any curvilinear shape.

% is_show equals 1 for graphical demonstration, otherwise set to 0. This option is to help with obtaining 
% an intuitive understanding of parameters and can be set to 0 in a real application.

% ========================================= PARAMETER EXPLANATION ==========================================
% VTI: vessel tortuosity index.
% sd: standard deviation of the angels between lines tangent to every pixel along the centerline.
% mean_dm: average distance measure between inflection points along the centerline.
% num_inflection_pts: number of inflection points along the centerline.
% num_critical_pts: number of critical points along the centerline.
% len_arch: length of vessel (arch) which is number of centerline pixels.
% len_cord: length of vessel chord which is the shortest path connecting vessel end points.
% VTI = (len_arch * sd * num_critical_pts * (mean_dm)) / len_cord;

% ============================================= LICENSE ====================================================
% This software has been released to promote research and education in the field of medical image analysis. 
% Feel free to use and/or redistribute for any non-commercial application.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
% OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR LIABILITY, WHETHER IN AN ACTION OF ONTRACT, TORT 
% OR, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR USINF OTHER DEALINGS IN THE SOFTWARE.

% ======================================= REFERENCE AND DEFINITION =========================================
% Mathematical definition of vessel tortuosity index (VTI) can be found in our previously published paper:
% Please cite the following paper if you use this code :)
% Khansari, et al. "Method for quantitative assessment of retinal vessel tortuosity in % optical coherence 
% tomography angiography applied to sickle cell retinopathy." Biomedical optics express 8.8 (2017):3796-3806.

% ============================================= AUTHOR =====================================================
% Maz M. Khansari (summer 2017)
% maziyar.khansari@gmail.com
% Release: 1.0
% Release date: 10/10/2019

%%
function [VTI,sd,mean_dm,num_inflection_pts,num_cpts,len_arch,len_cord,curvature] = vessel_tortousity_index(x,y,is_show)

% check for error
if nargin<3
  error('insufficient arguments', ...
    'provide x,y and is_show = 0/1')
end

% create a plot if is_show is 1 (true) and adjust axis
if is_show == 1
    figure, plot(x,y,'k','LineWidth',2), box off
    axis([min(x) max(x) min(y)-3 max(y)+3])
end

% compute chord length which is the shortest linear path between end points
len_cord = sqrt((x(end)-x(1))^2+(y(end)-y(1))^2);

% compute arc length between inflection points using John D'Errico tool
[len_arch,~] = arc_length(x(1:end),y(1:end));

% compute mean standard deviation of angels between lines tangent to each pixel along centerline and a reference axis
[sd,~] = sd_theta(x,y,is_show);

% compute mean distance measure (ratio of actual length to chord length) between inflection points
[mean_dm,num_inflection_pts,curvature] = mean_distance_measure(x,y,is_show);

% compute number of critical points
num_cpts = num_critical_pts(x,y,is_show);

% compute vessel tortuosity index (VTI)
VTI = (len_arch*sd*num_cpts*(mean_dm))/len_cord;

return
