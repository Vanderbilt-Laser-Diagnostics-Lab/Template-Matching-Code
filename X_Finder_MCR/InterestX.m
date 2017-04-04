function [coords h] = InterestX(Image, Shape, MaxN, MinDist, Thresh)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

% Shape = [Ang1 Ang2 Intens1 LinWid LegLen]

if nargin<5; Thresh = 0.75; end;

CF = GaussXList.Array([0 0 Shape]);
CI = NormCorr(CF, Image, .25);
CImax = max(CI(:));

ind = FindPeaks2(CI, MaxN, MinDist, CImax*Thresh);
[r c] = ind2sub(size(CI),ind);
coords = cat(2,c,r);

h(1) = figure();
imshow(CI,[min(CI(:)) max(CI(:))]);
hold all;

[coords h(2)] = EditPnts(Image, coords);