function FixXDel()

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

[PatFile, PatPath] = uigetfile({'*.xfit'; '*.xpat'},...
    'Select pattern file');
L = load([PatPath PatFile],'-mat');
XPattern = L.XFit;

[ImageFile, ImagePath] = uigetfile({'*.tif'},...
    'Select TIFF image file',PatPath);
ImageArray = GetMultiPageTiff(ImagePath, ImageFile);
SavePath = ImagePath;
[empty,SaveName] = fileparts(ImageFile);

Im = double(ImageArray);
AvgIm = mean(Im,3);
XFit = XPattern;
[XFit(:,1:2) h(2)] = MovePnts(AvgIm, XFit(:,1:2));

[SaveName, SavePath] = uiputfile('*.xfit',...
        'Select save file:', [SavePath SaveName '_FIX']);

save([SavePath SaveName],'XFit');