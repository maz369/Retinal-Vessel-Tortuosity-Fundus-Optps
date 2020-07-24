function [output,p] = csaps_pt(x,y,p,xx,w)

if nargin<3||isempty(p), p = -1; end
if nargin<4, xx = []; end
if nargin<5, w = []; end

if iscell(x)     % we are to handle gridded data
 output=[];
 p=[];

else             % we have univariate data

   [output,p] = csaps1(x,y,p,xx,w);

end

function [output,p] = csaps1(x,y,p,xx,w)
%CSAPS1 univariate cubic smoothing spline

n=length(x); if isempty(w), w = ones(1,n); end
[xi,yi,sizeval,w,origint,p] = chckxywp_pt(x,y,2,w,p);
n = size(xi,1); yd = size(yi,2); dd = ones(1,yd);

dx = diff(xi); divdif = diff(yi)./dx(:,dd);
if n==2 % the smoothing spline is the straight line interpolant
   pp=ppmak_pt(xi.',[divdif.' yi(1,:).'],yd); p = 1;
else % set up the linear system for solving for the 2nd derivatives at  xi .
     % this is taken from (XIV.6)ff of the `Practical Guide to Splines'
     % with the diagonal matrix D^2 there equal to diag(1/w) here.
     % Make use of sparsity of the system.

   dxol = dx;
   if length(p)>1 
      lam = p(2:end).'; p = p(1);
      dxol = dx./lam;
   end

   R = spdiags([dxol(2:n-1), 2*(dxol(2:n-1)+dxol(1:n-2)), dxol(1:n-2)],...
                                         -1:1, n-2,n-2);
   odx = 1./dx;
   Qt = spdiags([odx(1:n-2), -(odx(2:n-1)+odx(1:n-2)), odx(2:n-1)], ...
                                                0:2, n-2,n);
   % solve for the 2nd derivatives
   W = spdiags(1./w(:),0,n,n);
   Qtw = Qt*spdiags(1./sqrt(w(:)),0,n,n);
   if p<0 % we are to determine an appropriate P
      QtWQ = Qtw*Qtw.'; p = 1/(1+trace(R)/(6*trace(QtWQ)));
          % note that the resulting  p  behaves like
          %  1/(1 + w_unit*x_unit^3/lambda_unit)
          % as a function of the various units chosen
      u = ((6*(1-p))*QtWQ+p*R)\diff(divdif);
   else
      u = ((6*(1-p))*(Qtw*Qtw.')+p*R)\diff(divdif);
   end
   % ... and convert to pp form
   % Qt.'*u=diff([0;diff([0;u;0])./dx;0])
   yi = yi - ...
    (6*(1-p))*W*diff([zeros(1,yd)
                 diff([zeros(1,yd);u;zeros(1,yd)])./dx(:,dd)
                 zeros(1,yd)]);
   c3 = [zeros(1,yd);p*u;zeros(1,yd)];
   c2=diff(yi)./dx(:,dd)-dxol(:,dd).*(2*c3(1:n-1,:)+c3(2:n,:));

%Pangyu   
   output = yi;
%Pangyu     
   return;
   
   if exist('lam','var')
      dxtl = dx.*lam;
      pp=ppmak_pt(xi.',...
      reshape([(diff(c3)./dxtl(:,dd)).',3*(c3(1:n-1,:)./lam(:,dd)).', ...
                                    c2.',yi(1:n-1,:).'], (n-1)*yd,4),yd);
   else
      pp=ppmak_pt(xi.',...
      reshape([(diff(c3)./dx(:,dd)).',3*c3(1:n-1,:).',c2.',yi(1:n-1,:).'],...
                                                            (n-1)*yd,4),yd);
   end
end

if ~isempty(origint), pp = fnchg(pp,'int',origint); end
if length(sizeval)>1, pp = fnchg(pp,'dz',sizeval); end

if isempty(xx)
   output = pp;
else
   output = fnval_pt(pp,xx);
end
