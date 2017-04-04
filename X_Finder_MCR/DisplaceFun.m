function [u v] = DisplaceFun(x,y)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

u = zeros(size(x));

vmax = 20;
a = vmax*[.0001 -.02];
v = a(1)*x.^2 + a(2)*x;