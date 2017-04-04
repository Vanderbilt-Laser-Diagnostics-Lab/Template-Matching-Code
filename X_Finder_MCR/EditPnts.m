function [NewPnts f] = EditPnts(Image, Pnts)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

f = figure();
im = imshow(Image,[min(Image(:)), max(Image(:))]);
set(gcf,'Name','Left click to create or move, right click to delete.')

cmenu = uicontextmenu;
cb = ['delete(gco)'];
menu1 = uimenu(cmenu, 'Label', 'delete', 'Callback', cb);

for i = 1:size(Pnts,1)
    h = impoint(gca,Pnts(i,:));
    set(h,'UIContextMenu',cmenu,'UserData',{h});
end

    function ClickNewPoint(src, eventdata)
        CP = get(gca,'CurrentPoint');
         h = impoint(gca,CP(1,1:2));
         set(h,'UIContextMenu',cmenu,'UserData',{h});
    end

set(im,'ButtonDownFcn',@ClickNewPoint);

h = uicontrol('Position', [0 0 150 30], 'String', 'Continue', ...
    'Callback', 'uiresume(gcbf)');
disp('Left click to create or move, right click to delete.');
uiwait(gcf);

imp = findobj(gca,'Type','hggroup');

NewPnts = NaN(numel(imp),2);
for i = 1:numel(imp)
    himp = get(imp(i),'UserData');
    NewPnts(i,:) = getPosition(himp{1});
end
end