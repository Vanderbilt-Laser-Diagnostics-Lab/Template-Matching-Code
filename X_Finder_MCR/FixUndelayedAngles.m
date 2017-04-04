function FixedXFit = FixUndelayedAngles(XFit)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

SavePath = cd;
SuggestName = 'FixUndAng';
if nargin < 1
    [FitFile FitPath] = uigetfile({'*.xfit'; '*.xpat'},...
        'Select file');
    L = load([FitPath FitFile],'-mat');
    XFit = L.XFit;
    [empty FitFileName EXT] = fileparts(FitFile);
    SavePath = FitPath;
end

SuggestName = [FitFileName '-FixUndAng'];
[SaveName, SavePath] = uiputfile([SuggestName EXT],...
        'Select save file:', [SavePath SuggestName]);
    
NumFrames = size(XFit,3);
for i = 1:NumFrames
    XFit(:,3,i) = mean(XFit(:,3,i));
    XFit(:,4,i) = mean(XFit(:,4,i));
end

save([SavePath SaveName],'XFit');

end