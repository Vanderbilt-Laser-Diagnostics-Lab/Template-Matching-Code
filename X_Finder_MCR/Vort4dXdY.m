function V = Vort4dXdY(dX, dY)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

[height width] = size(dX);
V = NaN(height,width);

V(2:(height-1), 2:(width-1)) = ( ...
    + dX(1:(height-2), 2:(width-1)) ...
    - dX(3:(height),   2:(width-1)) ...
    - dY(2:(height-1), 1:(width-2)) ...
    + dY(2:(height-1), 3:(width)) ) ./ 2;