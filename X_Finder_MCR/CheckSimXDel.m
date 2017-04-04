function [rmsError rmsAngVar] = CheckSimXDel(XDelta)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

if nargin < 1
    [XDelFile, XDelPath] = uigetfile({'*.xdel'},...
        'Select XDelta File');
    L = load([XDelPath XDelFile],'-mat');
    XDelta = L.XDelta;
end

for i = 1:size(XDelta,3)
    [u v] = DisplaceFun(XDelta(:,1,i), XDelta(:,2,i));
    
    Error = [u v] - XDelta(:,5:6,i);
    rmsError(i,:) = nanstd(Error,1);
%     rmsError(i,:) = nanstd(XDelta(:,5:6,i),1);
    rmsAngVar(i,:) = nanstd(XDelta(:,7:8,i),1);
end

end