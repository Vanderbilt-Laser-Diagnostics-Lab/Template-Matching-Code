function CorrImage = NormCorr(Kernel, Image, MinPct)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

KernOffset = mean(Kernel(:));
KernScale = std(Kernel(:),1);
KN = (Kernel-KernOffset) / KernScale;

[IH IW] = size(Image);
ks = floor(size(Kernel)/2);
H = ks(1);
W = ks(2);

if nargin>2
    IMFilt = filter2(ones(3,3)/9,Image);
    IMMin = min(IMFilt(:));
    IMMax = max(IMFilt(:));
    IMThresh = IMMin + (IMMax-IMMin)*MinPct;
end

CorrImage = zeros(size(Image));
for r = (1+H):(IH-H-1)
    for c = (1+W):(IW-W-1)
        
        if nargin>2 && IMFilt(r,c)<IMThresh

        else
            im = Image( (r-H):(r+H), (c-W):(c+W));

            ImOffset = mean(im(:));
            ImScale = std(im(:),1);
            IN = (im-ImOffset) / ImScale;

            CorrImage(r,c) = max(0, 1/numel(KN)*sum(IN(:).*KN(:)));
        end
    end
end