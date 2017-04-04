function XDelta = XDeltaSingle(UndelayedXFit, DelayedXFit)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

% XDelta = [x y t1 t2 dx dy dt1 dt2]

SavePath = cd;
SaveName = 'XDelta';
if nargin < 2
    [UndFile, UndPath] = uigetfile({'*.xpat';'*.xfit'},...
        'Select Undelayed Fit');
    L = load([UndPath UndFile],'-mat');
    UXF = L.XFit;

    [DelFile, DelPath] = uigetfile({'*.xfit'},...
        'Select Delayed XFit', UndPath);
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
for i = 1:z
    XDelta(:,1:4,i) = UXF(:,1:4,1);
    XDelta(:,5:6,i) = DXF(:,1:2,i) - UXF(:,1:2,1);
    XDelta(:,7:8,i) = DXF(:,3:4,i) - UXF(:,3:4,1);
end

save([SavePath SaveName],'XDelta');