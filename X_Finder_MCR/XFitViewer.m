function XFit = XFitViewer(XFit, ImageArray)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

CorrThresh = 0;

FitName = 'cmd';
if nargin < 1
    [FitFile, FitPath] = uigetfile({'*.xfit'; '*.xpat'},...
        'Select fit file');
    L = load([FitPath FitFile],'-mat');
    FullXFit = L.XFit;
    FitName = FitFile;
end
[NX eleven NFit] = size(FullXFit);

ImageName = 'cmd';
if nargin < 2
    [ImageFile, ImagePath] = uigetfile({'*.tif'},...
        'Select TIFF image file',FitPath);
    ImageArray = GetMultiPageTiff(ImagePath, ImageFile);
    ImageName = ImageFile;
end

AvgIm = mean(ImageArray,3);
NIm = size(ImageArray,3);

A1fig = figure(); TileImage(2,2,1,1);
A2fig = figure(); TileImage(2,2,2,1);
SNRfig = figure(); TileImage(2,2,1,2);
CORRfig = figure(); TileImage(2,2,2,2);

GXF = GaussXList();
% fig = figure();
% PlotH = [];
GXF.X = FullXFit(:,:,1);
GXF.Image = AvgIm;
[fig ImH PlotH] = GXF.Show();
BrightSlider = AddBrightnessScroll(gcf,gca);
% set(fig,'Name', ['XFit: ' FitName ' AVG.  Image: ' ImageName], ...
%     'NumberTitle','off');
% set(gca,'CLim', [min(AvgIm(:)) max(AvgIm(:))]);

if NFit == 1; warning off all; end
Slider = uicontrol('Style','slider','Position',[1 1 150 20], ...
    'BusyAction','cancel','Interruptible','off', ...
    'Min',1,'Max', NFit,'Value', 1,'SliderStep',[1/NFit .1], ...
    'Callback',@FlipImage);
CorrEdit = uicontrol('Style','edit','Position',[1 20 40 20], ...
    'String',num2str(CorrThresh), 'Callback', @AuditXFit);
ApplyButton = uicontrol('Style','pushbutton','Position',[40 20 110 20], ...
    'String','Apply to File','CallBack', ...
    @(hO, eD) save([FitPath FitFile],'XFit'));

AuditXFit();

    function AuditXFit(hObj,eData)
        if nargin>0
            CorrThresh = str2num(get(CorrEdit,'String'));
        end
        XFit = FullXFit;
        for i = 1:NFit
            MaxC = max(FullXFit(:,8,i));
            Thresh = CorrThresh*MaxC;
            kill = find(FullXFit(:,8,i) < Thresh);
            XFit(kill,:,i) = NaN;
        end

        ShowStats();
        FlipImage();
    end
    
    function FlipImage(hObj,EData)
        figure(fig);
        i = round(get(Slider,'Value'));
        set(Slider,'Value', i);
        
        if i == 1
            im = AvgIm;
            set(fig,'Name', ['XFit: ' FitName ' AVG.  Image: ' ...
                ImageName]);            
        else
            im = ImageArray(:,:,i-1);
            set(fig,'Name', ['XFit: ' FitName ' ' int2str(i-1) ...
                '.  Image: ' ImageName]);
        end
        set(ImH,'CData',im);
        ImMn = min(im(:));
        ImMx = max(im(:));
        set(gca,'CLim', [ImMn ImMx]);
        set(BrightSlider,'Min', ImMn, 'Max', ImMx);

        if ~isempty(PlotH); delete(PlotH); end;
        GXF.X = XFit(:,:,i);
        PlotH = GXF.Draw;  
        drawnow;
    end

    function ShowStats()
        WindowTitle = 'Angle 1';
        PlotXLabel = 'Frame';
        PlotYLabel = 'angle mean, std, and 95% conf on mean (rad)';
        vals = reshape(XFit(:,3,:),NX,NFit);
        FrameStatsPlot(vals, WindowTitle,PlotXLabel,PlotYLabel,A1fig);
        
        WindowTitle = 'Angle 2';
        vals = reshape(XFit(:,4,:),NX,NFit);
        FrameStatsPlot(vals, WindowTitle,PlotXLabel,PlotYLabel,A2fig);
        
        WindowTitle = 'Correlation Coefficient';
        PlotYLabel = 'Corr mean, std, and 95% conf on mean';
        vals = reshape(XFit(:,8,:),NX,NFit);
        FrameStatsPlot(vals, WindowTitle,PlotXLabel,PlotYLabel,CORRfig);
        
        WindowTitle = 'Signal to Noise Ratio';
        PlotYLabel = 'SNR mean, std, and 95% conf on mean';
        vals = reshape((XFit(:,9,:) - XFit(:,10,:)) ./ ...
            XFit(:,11,:),NX,NFit);
        FrameStatsPlot(vals, WindowTitle,PlotXLabel,PlotYLabel,SNRfig);
    end
end