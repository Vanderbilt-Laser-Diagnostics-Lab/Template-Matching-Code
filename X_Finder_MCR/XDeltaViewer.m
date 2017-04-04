function XDeltaViewer(XDelta)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

%% use software OpenGL to avoid bug that reverses arrows
opengl software

%% set default params and scales
Frame = 1;
ArrowScale = 2;
PixScale = 1;
dt = 1;
Rad = 20;
DataType = 3;
InterpMethod = 2;

% get XDelta data from file with GUI
XDelName = 'XDelta';
if nargin < 1
    [XDelFile, XDelPath] = uigetfile({'*.xdel'},...
        'Select XDelta File');
    L = load([XDelPath XDelFile],'-mat');
    XDelta = L.XDelta;
    [~, XDelName] = fileparts(XDelFile);
end

%% initialize variables
[NArr , ~, NDel] = size(XDelta);
arrows = zeros(NArr,1);
dXI = 0; dYI = 0;
XVals = XDelta(:,1,:);
XMax = ceil(max(XVals(:)));
XMin = floor(min(XVals(:)));
Xspan = XMax - XMin;
YVals = XDelta(:,2,:);
YMax = ceil(max(YVals(:)));
YMin = floor(min(YVals(:)));
Yspan = YMax - YMin;
Border = mean([Xspan Yspan]) * 0.05;
XLim = [floor(XMin-Border) ceil(XMax+Border)];
YLim = [floor(YMin-Border) ceil(YMax+Border)];
[XI YI] = meshgrid(XMin:XMax, YMin:YMax);
ImArray = zeros(size(XI));

%% Create interpolation display figure
fig = figure();
set(fig,'Name', ['Displacement: ' XDelName ' Frame: AVG'], ...
    'NumberTitle','off');
im = imshow([]);
XPix = XMin:XMax;
YPix = YMin:YMax;
set(im,'xdata',XPix,'ydata',YPix);
axis on
ax = gca;
set(ax,'XLim',XLim,'YLim',YLim);
colormap(jet);
colorbar();

%% Run interpolation update functions for initial display
Interpolate();
ShowImage();
DrawArrows();

%% create frame select slider
if NDel > 1
    Slider = uicontrol('Style','slider','Position',[1 1 100 20], ...
        'BusyAction','cancel','Interruptible','off', ...
        'Min',1,'Max', NDel,'Value', 1,'SliderStep',[1/NDel .1], ...
        'Callback',@ReDraw);
end

%% create data type selection dropdown
DataTypes = {'X' 'Y' 'magnitude' 'angular'};
DataSelect = uicontrol('Style','popupmenu','Position',[100 1 80 20], ...
    'BusyAction','cancel','Interruptible','off', ...
    'String',DataTypes,'Value',DataType,'Callback',@NewDataType);

%% create parameter edit push button dialogue function
ParamButton = uicontrol('Style','pushbutton','Position',[200 1 80 20], ...
    'String','Parameters','Callback',@ParamEdit);

    function ParamEdit(~, ~)
        prompt = {'Pixel scale (len/pix):','Delay time:',...
            'Arrow scale:', 'MCR RadSq Interp radius (pix):'};
        dlg_title = 'Parameter and scaling inputs:';
        num_lines = 1;
        def = {num2str(PixScale), num2str(dt), ...
            num2str(ArrowScale), num2str(Rad)};
        answer = inputdlg(prompt,dlg_title,num_lines,def);
        
        PixScale = str2double(answer{1});
        dt = str2double(answer{2});
        ArrowScale = str2double(answer{3});
        Rad = str2double(answer{4});
        
        ReDraw();
    end

%% create interpolation method dropdown
InterpTypes = {'Powell Sabin' 'Linear' 'Cubic' 'MCR RadSq' ...
    'MCR RadSq no V'};
InterpMethodChk = uicontrol('Style','popupmenu','Position',[300 1 80 20], ...
    'String',InterpTypes,'Value', InterpMethod, ...
    'Callback',@ReDraw);

%% create save button and function
SaveButton = uicontrol('Style','pushbutton','Position',[400 1 80 20], ...
    'String','Save','Callback',@SaveArray);

    function SaveArray(~,~)
        [SaveName, SavePath] = uiputfile('*.mat',...
            'Select save file:');
        XIS = NaN([size(XI) NDel]);
        YIS = NaN([size(XI) NDel]);
        dXIS = NaN([size(XI) NDel]);
        dYIS = NaN([size(XI) NDel]);
        ReturnFrame = Frame;
        for F = 1:NDel
            Frame = F;
            Interpolate();
            XIS(:,:,F) = XI*PixScale;
            YIS(:,:,F) = YI*PixScale;
            dXIS(:,:,F) = dXI*PixScale/dt;
            dYIS(:,:,F) = dYI*PixScale/dt;
        end
        save([SavePath SaveName],'XIS','YIS','dXIS','dYIS');
        Frame = ReturnFrame;
    end

%% create plot stats button and function
SaveButton = uicontrol('Style','pushbutton','Position',[500 1 80 20], ...
    'String','Plot Stats','Callback',@PlotStats);

    function PlotStats(~,~)
        WindowTitle = 'Mean X Displacement';
        PlotXLabel = 'Frame';
        PlotYLabel = 'mean disp, std, and 95% conf on mean (pixels)';
        vals = reshape(XDelta(:,5,:),NArr,NDel);
        FrameStatsPlot(vals, WindowTitle,PlotXLabel,PlotYLabel);
        TileImage(2,2,1,1);
        
        WindowTitle = 'Mean Y Displacement';
        vals = reshape(XDelta(:,6,:),NArr,NDel);
        FrameStatsPlot(vals, WindowTitle,PlotXLabel,PlotYLabel);
        TileImage(2,2,2,1);
        
        WindowTitle = 'Mean Angle1 Displacement';
        PlotXLabel = 'Frame';
        PlotYLabel = 'mean disp, std, and 95% conf on mean (rad)';
        vals = reshape(XDelta(:,7,:),NArr,NDel);
        FrameStatsPlot(vals, WindowTitle,PlotXLabel,PlotYLabel);
        TileImage(2,2,2,2);
    end

%% main calculation and refresh functions
    function NewDataType(~,~)
        DataType = get(DataSelect,'value');
        ShowImage();
    end

    function ReDraw(~,~)
        Frame = round(get(Slider,'Value'));
        set(Slider,'Value', Frame);        
        DataType = get(DataSelect,'value');
        InterpMethod = get(InterpMethodChk,'Value');
        
        if Frame == 1
            FigName = ['Displacement: ' XDelName ' Frame: AVG'];
        else
            FigName = ['Displacement: ' XDelName ...
                ' Frame: ' int2str(Frame-1)];
        end
        set(fig,'Name', FigName);

        set(im,'xdata',XPix*PixScale,'ydata',YPix*PixScale);
        set(ax,'XLim',XLim*PixScale,'YLim',YLim*PixScale);
        
        Interpolate();
        ShowImage();
        DrawArrows();
        drawnow;
    end

    function DrawArrows()
        figure(fig);
        delete(arrows(arrows ~= 0));
        hold all

        for j = 1:NArr
            if sum(isnan(XDelta(j,:,Frame))) == 0
                coords = XDelta(j,[1:2 5:6],Frame)*PixScale;
                coords(3:4) = coords(3:4)*ArrowScale;
                len = sqrt(coords(3)^2 + coords(4)^2);
                HL = len*.3;
                HW = HL * .5;
                arrows(j) = ArrowMCR(coords,HW,HL,'k',1);
            else
                arrows(j) = 0;
            end
        end
    end

    function ShowImage()
        switch DataType
            case 1
                ImArray = dXI*PixScale/dt;
            case 2
                ImArray = dYI*PixScale/dt;
            case 3
                ImArray = sqrt(dXI.^2 + dYI.^2)*PixScale/dt;
            case 4
                ImArray = Vort4dXdY(dXI,dYI)/dt;
        end
        
        GP = ~isnan(ImArray);
        SP = sort(ImArray(GP));
        n = numel(SP);
        d = ceil(n*.01);
        set(im,'cdata',ImArray,'AlphaData',GP);
        set(ax,'CLim',[SP(d) SP(n-d)]);        
    end

    function Interpolate()   
        if InterpMethod == 1
            [dXI dYI] = PowellSabinInterp(XDelta(:,:,Frame),XI,YI);
        else
            X = XDelta(:,1,Frame);
            Y = XDelta(:,2,Frame);
            dX = XDelta(:,5,Frame);
            dY = XDelta(:,6,Frame);
            if InterpMethod == 2
                dXI = griddata(X,Y,dX,XI,YI);
                dYI = griddata(X,Y,dY,XI,YI);
            elseif InterpMethod == 3
                dXI = griddata(X,Y,dX,XI,YI,'cubic');
                dYI = griddata(X,Y,dY,XI,YI,'cubic');
            elseif InterpMethod == 4
                V = sum(XDelta(:,7:8,Frame),2);
                [dXI dYI] = RadSqInterp(X,Y,dX,dY,XI,YI,Rad,V);
            elseif InterpMethod == 5
                [dXI dYI] = RadSqInterp(X,Y,dX,dY,XI,YI,Rad);
            end
        end
    end
end