function ImOut = UserClipIm()

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

[ImageFile, ImagePath] = uigetfile({'*.tif'},...
    'Select TIFF image file');
[path,name,ext] = fileparts(ImageFile);
ImageArray = GetMultiPageTiff(ImagePath, ImageFile);
Im = uint16(mean(ImageArray,3));

mn = min(Im(:));
mx = max(Im(:));

f = figure();
imh = imshow(Im,[mn mx]);

Slider = uicontrol('Style','slider','Position',[1 1 300 20], ...
    'BusyAction','cancel','Interruptible','off', ...
    'Min',mn,'Max', mx,'Value', mx,'SliderStep',[1/(mx-mn) .1], ...
    'Callback',@Apply);
ApplyButton = uicontrol('Style','pushbutton','Position',[300 1 110 20], ...
    'String','Apply to File','CallBack', @Save);

lim = 0;
tempim = Im;

    function Apply(hObj,EData)
        figure(f);
        lim = round(get(Slider,'Value'));
        set(Slider,'Value', lim);
        tempim = Im;
        tempim(Im>lim) = mn;
        set(imh,'cdata',tempim);
        set(gca,'CLim',[mn lim]);
        drawnow;
    end

    function Save(hO,Ed)
       Im(Im > lim) = lim;
       imwrite(Im,[ImagePath name '_clip' ext],'tiff');
    end

end