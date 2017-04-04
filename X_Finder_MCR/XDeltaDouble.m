function XDelta = XDeltaDouble(UndelayedXFit, DelayedXFit)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

% XDelta = [x y dx dy da]

SavePath = cd;
SaveName = 'XDelta';
if nargin < 2
    [UndFile, UndPath] = uigetfile({'*.xfit'},...
        'Select Undelayed XFit');
    L = load([UndPath UndFile],'-mat');
    UXF = L.XFit;

    [DelFile, DelPath] = uigetfile({'*.xfit'},...
        'Select Delayed XFit');
    L = load([DelPath DelFile],'-mat');
    DXF = L.XFit;

    SavePath = DelPath;
    [empty,SaveName] = fileparts(DelFile);
else
    UXF = UndelayedXFit;
    DXF = DelayedXFit;
end

[SaveName, SavePath] = uiputfile('*.xdel',...
    'Select save file:', [SavePath SaveName]);

[r c z] = size(DXF);
XDelta = NaN(r,8,z);

XDelta(:,1:4,:) = UXF(:,1:4,:);
XDelta(:,5:6,:) = DXF(:,1:2,:) - UXF(:,1:2,:);
XDelta(:,7:8,:) = DXF(:,3:4,:) - UXF(:,3:4,:);

save([SavePath SaveName],'XDelta');