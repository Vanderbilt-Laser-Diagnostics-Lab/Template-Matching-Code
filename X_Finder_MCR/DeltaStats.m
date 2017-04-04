% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

[DelFiles, DelPath] = GetCellFileList('*.xdel',...
    'Select Xdelta files','on');

DelData = cell(numel(DelFiles)+1,15);
DelData(1,:) = {'File' 'Frames' 'Intersects' ...
    'val frames' 'Int / Frame' ...
    'xbar mean' 'xbar min' 'xbar max' 'xbar std' 'avg x std'...
    'ybar mean' 'ybar min' 'ybar max' 'ybar std' 'avg y std'};

for i = 1:numel(DelFiles)
    L = load([DelPath DelFiles{i}],'-mat');
    XDelta = L.XDelta;
    
    AFit = XDelta(:,:,1);
    
    [NX eleven NFit] = size(XDelta);
    XDelta = XDelta(:,:,2:NFit);
    [NX eleven NFit] = size(XDelta);
    
    Nt = 0;
    for j = 1:NFit
        NXF = numel(find(~isnan(XDelta(:,3,j))));
        if NXF > 30
            Nt = Nt+1;
        else
            XDelta(:,:,j) = NaN;
        end
    end
    
    DelData{i+1,1} = DelFiles{i};
    DelData{i+1,2} = NFit;
    DelData{i+1,3} = NX;
    DelData{i+1,4} = Nt;
    DelData{i+1,5} = numel(find(~isnan(XDelta(:,3,:))))/Nt;
    
    xbar = nanmean(XDelta(:,3,:));
    DelData{i+1,6} = nanmean(xbar);
    DelData{i+1,7} = min(xbar);
    DelData{i+1,8} = max(xbar);
    DelData{i+1,9} = nanstd(xbar);
    DelData{i+1,10} = sqrt(nanmean(nanstd(XDelta(:,3,:))));
    
    ybar = nanmean(XDelta(:,4,:));
    DelData{i+1,11} = nanmean(ybar);
    DelData{i+1,12} = min(ybar);
    DelData{i+1,13} = max(ybar);
    DelData{i+1,14} = nanstd(ybar);
    DelData{i+1,15} = sqrt(nanmean(nanstd(XDelta(:,4,:))));
    
%     DelData{i+1,8} = nanmean(AFit(:,8));
%     DelData{i+1,9} = nanmean(AFit(:,9)-AFit(:,10));
%     DelData{i+1,10} = nanmean((AFit(:,9)-AFit(:,10))./AFit(:,11));
end