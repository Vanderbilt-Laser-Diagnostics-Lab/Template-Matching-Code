function FindXPattern(Im)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

%% get image file
[fig im ax SavePath SaveName ImageArray CurrFrame] = ...
    MultiPageTiffViewer();
disp('Adjust image, then press "continue".');

%% add go button
uicontrol('Style','pushbutton','Position',[1 1 50 20], ...
    'String','GO','Callback',@GoFit);

    function GoFit(hObj,EData)
        Im = double(get(im,'CData'));
        
        %% get shape estimate from user
        [X Uncer MaxN] = GetUserXEst(fig,ax);
        Shape = X(3:7);
        MinDist = ceil(Shape(5));

        %% find potential intersection locations
        [IX temph] = InterestX(Im, Shape, MaxN, MinDist,.5);
        close(temph);
        GXL = GaussXList(IX, Shape);
        GXL.Image = Im;

        [Rad NRad Gen ShrnkFctr] = uiGetXQuadOptParams(Shape, Uncer);

        %% optimize locations based on image
        C = GXL.QuadOpt(Rad,NRad,Gen,ShrnkFctr);

        %% report
        fh(1) = figure();
        hold all
        plot(C);
        plot(mean(C,2),'Color','r','LineWidth',5);

        fh(2) = GXL.Show();
        fh(3) = GXL.ShowRecon();
        fh(4) = GXL.ShowDiff();

        %% return and save intersection list
        XFit = GXL.X;

        [SaveName, SavePath] = uiputfile('*.xpat',...
            'Select save file:', [SavePath SaveName]);
        save([SavePath SaveName],'XFit');
        
    end
end