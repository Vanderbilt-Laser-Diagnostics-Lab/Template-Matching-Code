% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

[DelFiles, DelPath] = GetCellFileList('*.xdel',...
    'Select Xdelta files','on');

DelData = cell(numel(DelFiles)+1,10);
DelData(1,:) = {'File' 'Frames' 'Intersects' 'Total Found' 'x uncer' ...
    'x jitter' 'y uncer' 'y jitter' 'a uncer' ...
    'a jitter'};

for i = 1:numel(DelFiles)
    L = load([DelPath DelFiles{i}],'-mat');
    XDelta = L.XDelta;
    
    AFit = XDelta(:,:,1);
    
    [NX eleven NFit] = size(XDelta);
    XDelta = XDelta(:,:,2:NFit);
    [NX eleven NFit] = size(XDelta);
    
    DelData{i+1,1} = DelFiles{i};
    DelData{i+1,2} = NFit;
    DelData{i+1,3} = NX;
    DelData{i+1,4} = numel(find(~isnan(XDelta(:,3,:))));
    DelData{i+1,5} = sqrt(nanmean(nanvar(XDelta(:,3,:))));
    DelData{i+1,6} = nanstd(nanmean(XDelta(:,3,:)));
    DelData{i+1,7} = sqrt(nanmean(nanvar(XDelta(:,4,:))));
    DelData{i+1,8} = nanstd(nanmean(XDelta(:,4,:)));
    DelData{i+1,9} = nanmean(nanvar(XDelta(:,5,:)));
    DelData{i+1,10} = nanstd(nanmean(XDelta(:,5,:)));
    
%     DelData{i+1,8} = nanmean(AFit(:,8));
%     DelData{i+1,9} = nanmean(AFit(:,9)-AFit(:,10));
%     DelData{i+1,10} = nanmean((AFit(:,9)-AFit(:,10))./AFit(:,11));
end