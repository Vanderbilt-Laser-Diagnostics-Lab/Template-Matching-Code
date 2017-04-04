function [NewPnts f] = MovePnts(Image, Pnts)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

HelpStr = ['Drag one, or drag on image to move all. ' ...
    'Right click to deactivate.'];

f = figure();
im = imshow(Image,[min(Image(:)), max(Image(:))]);
set(gcf,'Name',HelpStr)
AddBrightnessScroll(gcf,gca);

    function Deactivate(src, ED)
        UD = get(gco,'UserData');
        UD.Active = false;
        setColor(UD.h,'r');
        set(gco,'UserData',UD);
    end

    function Activate(src, ED)
        UD = get(gco,'UserData');
        UD.Active = true;
        setColor(UD.h,'b');
        set(gco,'UserData',UD);
    end

cmenu = uicontextmenu;
uimenu(cmenu, 'Label', 'deactivate', 'Callback', @Deactivate);
uimenu(cmenu, 'Label', 'activate', 'Callback', @Activate);

h = cell(1, size(Pnts,1));
for i = 1:size(Pnts,1)
    h{i} = impoint(gca,Pnts(i,:));
    UD.h = h{i};
    UD.Active = true;
    set(h{i},'UIContextMenu',cmenu,'UserData',UD);
end

P0 = [0 0];
Pnts0 = 0;
scale = 1;

    function DragPnts(src, eventdata)
        CP = get(f,'CurrentPoint');
        dP = (CP-P0)*scale;
        
        for i = 1:numel(h)
            setPosition(h{i},Pnts0(i,:)+[dP(1) -dP(2)]);
        end
    end

    function StartMove(src, eventdata)
        ST = get(f,'SelectionType');
        if isequal(ST, 'normal');
            P0 = get(f,'CurrentPoint');
            set(gca,'Units','pixels');
            pos = get(gca,'Position');
            set(gca,'Units','normalized');
            xlim = get(gca,'XLim');
            scale = (xlim(2)-xlim(1))/pos(3);
            
            Pnts0 = zeros(numel(h),2);
            for i = 1:numel(h)
                Pnts0(i,:) = getPosition(h{i});
            end
            set(f, 'WindowButtonMotionFcn', @DragPnts);
        end
    end

    function EndMove(src, eventdata)
        set(f, 'WindowButtonMotionFcn', '');
    end

set(im,'ButtonDownFcn',@StartMove)
set(f,'WindowButtonUpFcn',@EndMove);

uih = uicontrol('Position', [0 0 150 30], 'String', 'Continue', ...
    'Callback', 'uiresume(gcbf)');
disp(HelpStr);
uiwait(gcf);

NewPnts = NaN(numel(h),2);
for i = 1:numel(h)
    UD = get(h{i},'UserData');
    if UD.Active
        NewPnts(i,:) = getPosition(h{i});
    else
        NewPnts(i,:) = [NaN NaN];
    end
end
end