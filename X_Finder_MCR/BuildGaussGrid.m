function [ImArray U V] = BuildGaussGrid(NPix,XAng,LinWid,Spacing,SNR)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

ImArray = zeros(NPix);
[X Y] = meshgrid(1:NPix,1:NPix);
%[U V] = DisplaceFun(X,Y);
U = rand*2-1;
V = rand*2-1;
Xa = X - U;

HAng = XAng/2;
TR = [cos(HAng) sin(HAng); cos(-HAng) sin(-HAng)];
YRotRev1 = [-TR(1,2); TR(1,1)];
YRotRev2 = [-TR(2,2); TR(2,1)];
YSpace = Spacing * TR(1);
NLines = ceil(NPix / YSpace);

for i = -NLines : NLines*2
    
    ofst = i*YSpace;
    Ya = Y - ofst - V;

    YR1 = [Xa(:) Ya(:)] * YRotRev1;
    YR2 = [Xa(:) Ya(:)] * YRotRev2;

    Pix = .5*exp(-YR1.^2 / (2*LinWid^2)) + ...
        .5*exp(-YR2.^2 / (2*LinWid^2));
    ImArray = ImArray + reshape(Pix, size(X));
end

if nargin > 4
    SigmaNoise = 1/SNR/5;
    ImArray = ImArray + randn(NPix)*SigmaNoise;
end

ImArray = uint16((ImArray+1)*double(intmax('uint16'))/3);

imshow(ImArray,[min(ImArray(:)) max(ImArray(:))]);