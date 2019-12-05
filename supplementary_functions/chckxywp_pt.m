function [x,y,sizeval,w,origint,p,tolred] = chckxywp_pt(x,y,nmin,w,p,adjtol)

% make sure X is a vector:
if iscell(x)||length(find(size(x)>1))>1
   error('SPLINES:CHCKXYWP:Xnotvec','X must be a vector.'), end

% make sure X is real:
if ~all(isreal(x))
   x = real(x);
   warning('SPLINES:CHCKXYWP:Xnotreal', ...
           'Imaginary part of complex data sites ignored.')
end

% deal with NaN's and Inf's among the sites:
nanx = find(~isfinite(x));
if ~isempty(nanx)
   x(nanx) = [];
   warning('SPLINES:CHCKXYWP:NaNs', ...
           'All data points with NaN or Inf as their site will be ignored.')
end

n = length(x);
if nargin>2&&nmin>0, minn = nmin; else minn = 2; end
if n<minn
   error('SPLINES:CHCKXYWP:toofewpoints', ...
   'There should be at least %g data sites.',minn), end

% re-sort, if needed, to ensure nondecreasing site sequence:
tosort = false;
if any(diff(x)<0), tosort = true; [x,ind] = sort(x); end

nstart = n+length(nanx);
% if Y is ND, reshape it to a matrix by combining all dimensions but the last:
sizeval = size(y);
yn = sizeval(end); sizeval(end) = []; yd = prod(sizeval);
if length(sizeval)>1
   y = reshape(y,yd,yn);
else
   % if Y happens to be a column matrix, of the same length as the original X,
   % then change Y to a row matrix
   if yn==1&&yd==nstart
      yn = yd; y = reshape(y,1,yn); yd = 1; sizeval = yd;
   end
end
y = y.'; x = reshape(x,n,1);

% make sure that sites, values and weights match in number:

if nargin>2&&~nmin % in this case we accept two more data values than
                   % sites, stripping off the first and last, and returning
		   % them separately, in W, for use in CSAPE1.
   switch yn
   case nstart+2, w = y([1 end],:); y([1 end],:) = [];
      if ~all(isfinite(w)),
         error('SPLINES:CHCKXYWP:InfY', ...
	 'Some of the end condition values fail to be finite.')
      end
   case nstart, w = [];
   otherwise
      error('SPLINES:CHCKXYWP:XdontmatchY', ...
           ['The number of sites, %g, does not match the number of', ...
          ' values, %g.'], nstart, yn)
   end
else
   if yn~=nstart
      error('SPLINES:CHCKXYWP:XdontmatchY', ...
           ['The number of sites, %g, does not match the number of', ...
          ' values, %g.'], nstart, yn)
   end
end

nonemptyw = nargin>3&&~isempty(w);
if nonemptyw
   if length(w)~=nstart
      error('SPLINES:CHCKXYWP:weightsdontmatchX', ...
       ['The number of weights, %g, does not match the number of', ...
       ' sites, %g.'], length(w), nstart)
   else
      w = reshape(w,1,nstart);
   end
end

roughnessw = exist('p','var')&&length(p)>1;
if roughnessw
   if tosort
      warning('SPLINES:CHCKXYWP:cantreorderrough', ...
           'Since data sites are not ordered, roughness weights are ignored.')
      p = p(1);
   else
      if length(p)~=nstart
         error('SPLINES:CHCKXYWP:rweightsdontmatchX', ...
	 ['The number of roughness weights is incompatible with the', ...
	        ' number of sites, %g.'], nstart)
      end
   end
end

%%% remove values and error weights corresponding to nonfinite sites:
if ~isempty(nanx), y(nanx,:) = []; if nonemptyw, w(nanx) = []; end
   if roughnessw  % as a first approximation, simply ignore the
                  % specified weight to the left of any ignored point.
      p(max(nanx,2)) = [];
   end
end
if tosort, y = y(ind,:); if nonemptyw, w = w(ind); end, end

% deal with nonfinites among the values:
nany = find(sum(~isfinite(y),2));
if ~isempty(nany)
   y(nany,:) = []; x(nany) = []; if nonemptyw, w(nany) = []; end
   warning('SPLINES:CHCKXYWP:NaNs', ...
           'All data points with NaNs or Infs in their value will be ignored.')
   n = length(x);
   if n<minn
      error('SPLINES:CHCKXYWP:toofewX', ...
      'There should be at least %g data sites.',minn), end
   if roughnessw  % as a first approximation, simply ignore the
                  % specified weight to the left of any ignored point.
      p(max(nany,2)) = [];
   end
end

if nargin==3&&nmin, return, end % for SPAPI, skip the averaging

if nargin>3&&isempty(w) %  use the trapezoidal rule weights:
   dx = diff(x);
   if any(dx), w = ([dx;0]+[0;dx]).'/2;
   else,       w = ones(1,n);
   end
   nonemptyw = ~nonemptyw;
end

tolred = 0;
if ~all(diff(x)) % conflate repeat sites, averaging the corresponding values
                 % and summing the corresponding weights
   mults = knt2mlt(x);
   for j=find(diff([mults;0])<0).'
      if nonemptyw
         temp = sum(w(j-mults(j):j));
	 if nargin>5
	    tolred = tolred + w(j-mults(j):j)*sum(y(j-mults(j):j,:).^2,2); 
	 end
         y(j-mults(j),:) = (w(j-mults(j):j)*y(j-mults(j):j,:))/temp;
         w(j-mults(j)) = temp;
         if nargin>5
	    tolred = tolred - temp*sum(y(j-mults(j),:).^2);
	 end
      else
         y(j-mults(j),:) = mean(y(j-mults(j):j,:),1);
      end
   end
      
   repeats = find(mults);
   x(repeats) = []; y(repeats,:) = []; if nonemptyw, w(repeats) = []; end
   if roughnessw  % as a first approximation, simply ignore the
                  % specified weight to the left of any ignored point.
      p(max(repeats,2)) = [];
   end
   n = length(x);
   if n<minn, error('SPLINES:CHCKXYWP:toofewX', ...
      'There should be at least %g data sites.',minn), end
end

if nargin<4, return, end


% remove all points corresponding to relatively small weights (since a
% (near-)zero weight in effect asks for the corresponding datum to be dis-
% regarded while, at the same time, leading to bad condition and even
% division by zero).
origint = []; % this will be set to x([1 end]).' in case the weight for an end
             % data point is near zero, hence the approximation is computed
             % without that endpoint.
if nonemptyw
   ignorep = find( w <= (1e-13)*max(abs(w)) );
   if ~isempty(ignorep)
      if ignorep(1)==1||ignorep(end)==n, origint = x([1 end]).'; end
      x(ignorep) = []; y(ignorep,:) = []; w(ignorep) = []; 
      if roughnessw
                     % as a first approximation, simply ignore the
                     % specified weight to the left of any ignored point.
         p(max(ignorep,2)) = [];
      end
      n = length(x);
      if n<minn
        error('SPLINES:CHCKXYWP:toofewX', ...
	     ['There should be at least %g data points with positive',...
	       ' weights.'],minn)
      end
   end
end
