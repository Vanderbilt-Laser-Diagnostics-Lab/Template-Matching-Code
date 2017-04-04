% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

classdef GaussXList < handle
    properties
        X %[X Y Ang1 Ang2 RelIntens LinWid LegLen Corr Peak BG Noise]
        Image % associated image array
        NumPar = 11; % number of X params
    end
    
    methods(Static)
        function [pnts trigs] = EndPoints(Xin)
            % Xin = [x y Ang1 Ang2 RelIntens LinWid LegLen]

            trigs = [cos(Xin(3)) sin(Xin(3)); cos(Xin(4)) sin(Xin(4))];
            delta = Xin(7) * trigs;
            pnts = [-delta(1,:); delta(1,:); -delta(2,:); delta(2,:)] + ...
                [Xin(1:2); Xin(1:2); Xin(1:2); Xin(1:2)];
        end
        
        function [TemplateArray MinCorner] = Array(Xin, Lim)
            % Xin = [x y Ang1 Ang2 RelIntens LinWid LegLen]
            %
            % Lim = [XMin, XMax, YMin, YMax]

            [EP TR] = GaussXList.EndPoints(Xin);
            
            minX = round(min(EP(:,1)));
            maxX = round(max(EP(:,1)));
            minY = round(min(EP(:,2)));
            maxY = round(max(EP(:,2)));
            
            if nargin > 1
                minX = max([Lim(1), minX]);
                maxX = min([Lim(2), maxX]);
                minY = max([Lim(3), minY]);
                maxY = min([Lim(4), maxY]);
            end            
            
            [Xa Ya] = meshgrid(minX:maxX, minY:maxY);

            Xa = Xa - Xin(1);
            Ya = Ya - Xin(2);

            YRotRev1 = [-TR(1,2); TR(1,1)];
            YRotRev2 = [-TR(2,2); TR(2,1)];

            YR1 = [Xa(:) Ya(:)] * YRotRev1;
            YR2 = [Xa(:) Ya(:)] * YRotRev2;
            
            Mag1 = Xin(5);
            Mag2 = 1-Xin(5);

            TemplateArray = Mag1*exp(-YR1.^2 / (2*Xin(6)^2)) + ...
                Mag2*exp(-YR2.^2 / (2*Xin(6)^2));
            TemplateArray = reshape(TemplateArray, size(Xa));

            MinCorner = [minX minY];
        end
    end

    methods        
        function obj = GaussXList(CPnt, Shape)
        % XL = GaussXList(CPnt, Shape) returns an GaussXList object.
        %
        %   CPnt = Nx2 array of [x y]
        %   Shape = [Ang1, Ang2, RelIntens, LinWid, LegLen]

            if nargin == 0; return; end;
            
            N = size(CPnt,1);
            obj.X = NaN(N, obj.NumPar);
            obj.X(:,1:2) = CPnt;
            
            for i = 1:N
                obj.X(i,3:7) = Shape;
            end
        end
        
        function h = Draw(obj, Fmt, LineWidth)
            % GaussXList.Draw(Fmt, LineWidth)
            %   draws line representations of all X's on gca
            %   'Fmt' is optional, default is '-r'
            %   'LineWidth' is optional, default is 0.5

            if nargin < 2; Fmt = '-r'; end;

            N = size(obj.X,1);
            h = zeros(N,2);            

            for i = 1:N
                EP = obj.EndPoints(obj.X(i,:));
                h(i,:) = plot(EP(1:2,1),EP(1:2,2),Fmt, ...
                    EP(3:4,1),EP(3:4,2),Fmt);
            end

            if nargin > 2;
                set(h,'LineWidth',LineWidth);
            end
        end
        
        function h = DrawArray(obj)
            % GaussXList.DrawArrayXL()
            %   draws gaussian images of X's on gca scaled by current CLim

            N = size(obj.X,1);
            h = zeros(N,1);
            [YL XL] = size(obj.Image);

            for i = 1:N
                [I M] = obj.Array(obj.X(i,:), [1 XL 1 YL]);
                s = size(I);
                CLim = get(gca,'CLim');
                scaledI = I * (CLim(2)-CLim(1)) + CLim(1);
                h(i,1) = image([M(1) M(1)+s(2)-1], ...
                    [M(2) M(2)+s(1)-1], scaledI, ...
                    'CDataMapping', 'scaled');
            end
        end
        
        function Diff = Correlate(obj)
            %  GaussXList.Correlate()
            %    computes correlation, Peak, and BG of all X's 
            %    and stores in X(i,8:10)
            %
            %    if nargout > 0, returs difference array in Diff
            %    and peak to peak noise level in X(i,11)

            N = size(obj.X,1);
            [YL XL] = size(obj.Image);
            if nargout > 0; Diff = cell(N,2); end;
            
            for i = 1:N
                [T MC] = obj.Array(obj.X(i,:), [1 XL 1 YL]);
                dims = size(T);

                ImMinRow = MC(2);
                ImMaxRow = (MC(2)+dims(1)-1);
                ImMinCol = MC(1);
                ImMaxCol = (MC(1)+dims(2)-1);
                [Height Width] = size(obj.Image);

                if ImMinRow < 1 || ImMaxRow > Height || ...
                        ImMinCol < 1 || ImMaxCol > Width
                    obj.X(i,8:11) = [NaN NaN NaN NaN];
                else

                    ImRowRange = ImMinRow:ImMaxRow;
                    ImColRange = ImMinCol:ImMaxCol;
                    TpltOffset = mean(T(:));
                    TpltScale = std(T(:));
                    TN = (T-TpltOffset) / TpltScale;

                    I = obj.Image(ImRowRange,ImColRange);
                    I = double(I);
                    ImOffset = mean(I(:));
                    ImScale = std(I(:));
                    IN = (I-ImOffset) / ImScale;

                    obj.X(i,8) = 1/(numel(TN)-1)*sum(IN(:).*TN(:));
                    obj.X(i,9) = (1-TpltOffset)/TpltScale*ImScale + ...
                        ImOffset;
                    obj.X(i,10) = -TpltOffset/TpltScale*ImScale + ImOffset;
                    obj.X(i,11) = NaN;
                    
                    if nargout > 0
                        Diff{i,1} = (IN-TN)*ImScale;
                        Diff{i,2} = MC;
                        
                        %obj.X(i,11) = max(Diff{i,1}(:)) - ...
                        %    min(Diff{i,1}(:));
                        
                        %obj.X(i,11) = 6*std(Diff{i,1}(:),1);
                        
                        [dh dw] = size(Diff{i,1});
                        FiltDiff = filter2(ones(3),Diff{i,1},'valid')/9;
                        DiffNoise = Diff{i,1}(2:dh-1,2:dw-1)-FiltDiff;
                        obj.X(i,11) = 5*std(DiffNoise(:));
                    end
                end
            end
        end
        
        function Corr = QuadOpt(obj, Rad, NRad, Gen, ShrnkFctr, LockAng)
            N = size(obj.X,1);
            
            TempGXL = GaussXList();
            TempGXL.Image = obj.Image;
            NumVars = 1 + numel(find( Rad(3:7)>0 & NRad(3:7)>0));
            Corr = NaN(NumVars*Gen+1,N);
            warning off all
            for i = 1:N
                if nargout > 0
                    count = 1;
                    TempGXL.X = obj.X(i,:);
                    TempGXL.Correlate();
                    Corr(count,i) = TempGXL.X(1,8);
                end
                
                for G = 1:Gen
                    R = Rad / ShrnkFctr^(G-1);
                    inc = R ./ NRad;

                    XR = (obj.X(i,1) - R(1)): inc(1) :(obj.X(i,1) + R(1));
                    YR = (obj.X(i,2) - R(2)): inc(2) :(obj.X(i,2) + R(2));
                    [X Y] = meshgrid(XR, YR);
                    
                    Num = numel(X);
                    TempGXL.X = NaN(Num, obj.NumPar);
                    for k = 1:Num
                        TempGXL.X(k,:) = obj.X(i,:);
                        TempGXL.X(k,1) = X(k);
                        TempGXL.X(k,2) = Y(k);
                    end

                    TempGXL.Correlate();
                    [obj.X(i,1) obj.X(i,2)] = ...
                        QuadOpt2(TempGXL.X(:,1), TempGXL.X(:,2), ...
                        TempGXL.X(:,8));
                    
                    if nargout > 0
                        count = count+1;
                        TempGXL.X = obj.X(i,:);
                        TempGXL.Correlate();
                        Corr(count,i) = TempGXL.X(1,8);
                        %obj.X(i,8) = TempGXL.X(1,8);
                    end

                    VarRng = 3:7;
                    if nargin > 5 && LockAng
                        if R(3)>0 && NRad(3)>0

                            MinRng = -R(3);
                            MaxRng = R(3);
                            Incs = MinRng : inc(3) : MaxRng;
                            vals3 = obj.X(i,3) + Incs;
                            vals4 = obj.X(i,4) + Incs;

                            Num = numel(Incs);
                            TempGXL.X = NaN(Num,obj.NumPar);
                            for k = 1:Num
                                TempGXL.X(k,:) = obj.X(i,:);
                                TempGXL.X(k,3) = vals3(k);
                                TempGXL.X(k,4) = vals4(k);
                            end
                            TempGXL.Correlate();
                            P = polyfit(Incs', TempGXL.X(:,8), 2);

                            FitLoc = -P(2)/(2*P(1));
                            if P(1)>=0 || FitLoc<MinRng || FitLoc>MaxRng
                                [MaxVal MaxInd] = max(TempGXL.X(:,8));
                                obj.X(i,3) = vals3(MaxInd);
                                obj.X(i,4) = vals4(MaxInd);
                            else
                                obj.X(i,3) = obj.X(i,3) + FitLoc;
                                obj.X(i,4) = obj.X(i,4) + FitLoc;
                            end
                            if nargout > 0
                                count = count+1;
                                TempGXL.X = obj.X(i,:);
                                TempGXL.Correlate();
                                Corr(count,i) = TempGXL.X(1,8);
                                %obj.X(i,8:11) = TempGXL.X(1,8:11);
                            end
                        end
                        VarRng = 5:7;
                    end

                    for j = VarRng                        
                        if R(j)>0 && NRad(j)>0
                            
                            MinV = obj.X(i,j) - R(j);
                            MaxV = obj.X(i,j) + R(j);
                            vals = MinV : inc(j) : MaxV;
                            
                            Num = numel(vals);
                            TempGXL.X = NaN(Num,obj.NumPar);
                            for k = 1:Num
                                TempGXL.X(k,:) = obj.X(i,:);
                                TempGXL.X(k,j) = vals(k);
                            end
                            TempGXL.Correlate();
                            P = polyfit(vals', TempGXL.X(:,8), 2);
                            
                            FitLoc = -P(2)/(2*P(1));
                            if P(1)>=0 || FitLoc<MinV || FitLoc>MaxV
                                [MaxVal MaxInd] = max(TempGXL.X(:,8));
                                obj.X(i,j) = vals(MaxInd);
                            else
                                obj.X(i,j) = FitLoc;
                            end
                            if nargout > 0
                                count = count+1;
                                TempGXL.X = obj.X(i,:);
                                TempGXL.Correlate();
                                Corr(count,i) = TempGXL.X(1,8);
                                %obj.X(i,8:11) = TempGXL.X(1,8:11);
                            end
                        end
                    end
                end
            end    
            warning on all
            TD = obj.Correlate();
        end
        
        function [FigH ImageH PlotH] = Show(obj, FigH)
            if nargin > 1
                figure(FigH);
            else
                FigH = figure();
            end
            ImageH = imshow(obj.Image, ...
                [min(obj.Image(:)) max(obj.Image(:))]);
            hold all
            %set(gca,'position',[0 0 1 1]);
            PlotH = obj.Draw;
        end
        
        function FigHandle = ShowDiff(obj)
            FigHandle = figure();
            patchim = obj.Image;
            Diff = obj.Correlate();
            for i = 1:size(Diff,1)
                sd = size(Diff{i,1});
                MC = Diff{i,2};
                patchim(MC(2):(MC(2)+sd(1)-1), ...
                    MC(1):(MC(1)+sd(2)-1)) = Diff{i,1}+obj.X(i,10);
            end
            imshow(patchim,[min(patchim(:)) max(patchim(:))]);
        end
        
        function FigHandle = ShowRecon(obj)
            FigHandle = figure();
            patchim = obj.Image;
            [YL XL] = size(obj.Image);
            for i = 1:size(obj.X,1)
                [array MC] = obj.Array(obj.X(i,:), [1 XL 1 YL]);
                array = array*(obj.X(i,9) - obj.X(i,10)) + obj.X(i,10);
                sd = size(array);
                patchim(MC(2):(MC(2)+sd(1)-1), ...
                    MC(1):(MC(1)+sd(2)-1)) = array;
            end
            imshow(patchim,[min(patchim(:)) max(patchim(:))]);
        end
    end
end
