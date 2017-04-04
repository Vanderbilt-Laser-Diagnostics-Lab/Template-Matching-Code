function XFit = ApplyXPattern(XPattern, ImageArray)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

SavePath = cd;
SaveName = 'XFit';
if nargin < 2
    [ImageFile, ImagePath] = uigetfile({'*.tif'},...
        'Select TIFF image file');
    ImageArray = GetMultiPageTiff(ImagePath, ImageFile);
    SavePath = ImagePath;
    [empty,SaveName] = fileparts(ImageFile);
end

if nargin < 1
    [PatFile, PatPath] = uigetfile({'*.xpat'; '*.xfit'},...
        'Select pattern file',ImagePath);
    L = load([PatPath PatFile],'-mat');
    XPattern = L.XFit(:,:,1);
end

[SaveName, SavePath] = uiputfile('*.xfit',...
        'Select save file:', [SavePath SaveName]);

Im = double(ImageArray);
AvgIm = mean(Im,3);
ImN = size(Im,3);

MXP = XPattern;
[MXP(:,1:2) h(2)] = MovePnts(AvgIm, MXP(:,1:2));
close(h(2));
LiveList = find(~isnan(MXP(:,1)));
ActiveMXP = MXP(LiveList,:);

GXL = GaussXList();
GXL.X = ActiveMXP;
[Rad NRad Gen ShrnkFctr LockAng] = uiGetXQuadOptParams(GXL.X(1,3:7));

[r c] = size(XPattern);
CFig = figure();
NumStr = int2str(ImN);
XFit = NaN(r,c,ImN+1);
for i = 1:ImN+1    
    if i == 1
        GXL.Image = AvgIm;
    else
        GXL.X = ActiveMXP;
        GXL.Image = Im(:,:,i-1);
    end

    GXL.QuadOpt(Rad,NRad,Gen,ShrnkFctr,LockAng);
    
%     Corr = GXL.QuadOpt(Rad,NRad,Gen,ShrnkFctr,LockAng);    
%     figure(CFig); hold off; plot(Corr); hold all;
%     plot(mean(Corr,2),'Color','r','LineWidth',5);   

    XFit(LiveList,:,i) = GXL.X;
    save([SavePath SaveName],'XFit');
        
    if i == 1
        disp('Completed averaged image.');
    else
        disp(['Completed ' int2str(i-1) ' of ' NumStr '.']);
    end
end