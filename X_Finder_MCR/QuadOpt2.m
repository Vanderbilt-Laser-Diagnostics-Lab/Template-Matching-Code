function [x y z] = QuadOpt2(X, Y, Z, XLim, YLim)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

% performs 2D quadratic fit, returns peak
% if max falls outside range of X,Y, returns max input point
% 
% Q(X,Y) = aX^2 + bY^2 + cXY + dX + eY + f

X = X(:);
Y = Y(:);
Z = Z(:);

if nargin < 4
    XLim = [min(X) max(X)];
    YLim = [min(Y) max(Y)];
end

% 2D second order fit
mat = [X.^2 Y.^2 X.*Y X Y ones(size(X))];
A = mat\Z;

% solve dzdx=dzdy= 0 for [x y]
mat = [2*A(1) A(3); A(3) 2*A(2)];
cpoint = mat\[-A(4); -A(5)];

% find discriminant = dzdx*dzdy - dz2dxdy^2
d = 4*A(1)*A(2) - A(3)^2;

% If fit has a max, output that. If not, output max in.
if cpoint(1)<XLim(1) || cpoint(1)>XLim(2) || ...
        cpoint(2)<YLim(1) || cpoint(2)>YLim(2) || d <= 0
    [z I] = max(Z);
    x = X(I);
    y = Y(I);
else
    x = cpoint(1);
    y = cpoint(2);
    
    if nargout > 2
        z = A'*[x^2 y^2 x*y x y 1]';
    end
end