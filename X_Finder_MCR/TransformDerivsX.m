function ders = TransformDerivsX(Angles, MeasuredDers, EstDers)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

% ders = TransformDerivsX(MeasuredDers, EstDers)
% ders = [Ux Vx Uy Vy];
%
% Angles = [A1 A2];
% MeasuredDers = [dV1dX1 dV2dX2];
% EstDers = [Ux Vx Uy Vy];

s = sin(Angles);
c = cos(Angles);

A = [ c(1)*[-s(1) c(1)] s(1)*[-s(1) c(1)] ; ...
      c(2)*[-s(2) c(2)] s(2)*[-s(2) c(2)] ; ...
      c(2)*[-s(1) c(1)] s(2)*[-s(1) c(1)] ; ...
      c(1)*[-s(2) c(2)] s(1)*[-s(2) c(2)] ];
  
b = [MeasuredDers'; A(3:4,:)* EstDers'];

ders = A\b;

end
    

