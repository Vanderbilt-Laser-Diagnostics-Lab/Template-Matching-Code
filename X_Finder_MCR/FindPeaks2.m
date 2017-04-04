function Indices = FindPeaks2(Array, MaxN, MinDist, Threshold)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

% Finds up to MaxN peaks > Threshold seperated by MinDist in Array

SA = sparse(Array - Threshold);
SA(SA<=0) = 0;
sz = size(SA);

Indices = zeros(MaxN, 1);
n = 0;
while n<MaxN
    [val ind] = max(SA(:));
    
    if val == 0
        break;
    else
        [r c] = ind2sub(sz, ind);
        minr = max(1,r-MinDist);
        maxr = min(sz(1),r+MinDist);
        minc = max(1,c-MinDist);
        maxc = min(sz(2),c+MinDist);
        
        SA(minr:maxr,minc:maxc) = 0;
        n = n+1;
        Indices(n,1) = ind;
    end
end

Indices = Indices(1:n,1);
    