function Slider = AddBrightnessScroll(fig, ax)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

MM = get(ax,'CLim');

Slider = uicontrol('Style','slider','Position',[1 50 20 200], ...
    'BusyAction','cancel','Interruptible','off', ...
    'Min',MM(1),'Max', MM(2),'Value', MM(2),'SliderStep', ...
    [.01 .1], 'Callback',@Apply);

function Apply(hObj,EData)
        figure(fig);
        lim = round(get(Slider,'Value'));
        set(Slider,'Value', lim);
        set(gca,'CLim',[MM(1) lim]);
        drawnow;
end

end