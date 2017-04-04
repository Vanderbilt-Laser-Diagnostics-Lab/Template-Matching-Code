function [dXI dYI] = RadSqInterp(X,Y,dX,dY,Xi,Yi,Rad,V)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

X0 = Xi(1);
Y0 = Yi(1);

ind = find(isfinite(dX));

TRI = delaunay(X(ind),Y(ind));
T = tsearch(X(ind),Y(ind),TRI,Xi,Yi);
AP = find(isfinite(T));

[height width] = size(Xi);
XBin = NaN(height, width);
YBin = NaN(height, width);
XBin(AP) = 0;
YBin(AP) = 0;
WBin = zeros(height, width);

for i = 1:numel(ind)
    j = ind(i);
    
    Col = X(j)-X0 + 1;
    Row = Y(j)-Y0 + 1;

    Row0 = ceil(Row-Rad);
    RowMax = floor(Row+Rad);

    for r = Row0 : RowMax
        if r<1 || r>height
            continue;
        end;
        dr = r-Row;
        dcLim = sqrt( Rad^2 - dr^2);
        for c = ceil(Col-dcLim) : floor(Col+dcLim)
            if  c<1 || c>width || isnan(XBin(r,c))
                continue;
            end;
            dc = c-Col;
            R = sqrt((dr)^2 + (dc)^2);
            
%             weight = (Rad - R)^2;
            
            t = R/Rad;
            t2 = t^2;
            t3 = t^3;
            weight = 2*t3-3*t2+1;
            
            if weight > 0
                XBin(r,c) = XBin(r,c) + dX(j) * weight;
                YBin(r,c) = YBin(r,c) + dY(j) * weight;
                WBin(r,c) = WBin(r,c) + weight;

                if nargin > 7
                    SinT = dr/R;
                    CosT = dc/R;
                    
%                     VortMag = R * V(j);
%                     XBin(r,c) = XBin(r,c) - VortMag*SinT * weight;
%                     YBin(r,c) = YBin(r,c) + VortMag*CosT * weight;
                    
                    HmW = (t3-2*t2+t)*Rad;
                    dxdt = -V(j)*SinT;
                    dydt = V(j)*CosT;
                    
                    XBin(r,c) = XBin(r,c) + dxdt*HmW;
                    YBin(r,c) = YBin(r,c) + dydt*HmW;
                end
            end
        end
    end
end

warning off all;
dXI = XBin ./ WBin;
dYI = YBin ./ WBin;
warning on all;

end