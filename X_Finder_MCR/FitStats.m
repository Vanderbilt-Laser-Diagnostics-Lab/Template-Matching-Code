% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

[FitFiles, FitPath] = GetCellFileList('*.xfit',...
    'Select fit file','on');

FitData = cell(numel(FitFiles)+1,10);
FitData(1,:) = {'File' 'Frames' 'Intersects' 'Total Found' 'Mean Corr' ...
    'Mean Signal' 'Mean SNR' 'AVG Mean Corr' 'AVG Mean Signal' ...
    'AVG Mean SNR'};

for i = 1:numel(FitFiles)
    L = load([FitPath FitFiles{i}],'-mat');
    XFit = L.XFit;
    
    AFit = XFit(:,:,1);
    
    [NX eleven NFit] = size(XFit);
    XFit = XFit(:,:,2:NFit);
    [NX eleven NFit] = size(XFit);
    
    FitData{i+1,1} = FitFiles{i};
    FitData{i+1,2} = NFit;
    FitData{i+1,3} = NX;
    FitData{i+1,4} = numel(find(~isnan(XFit(:,1,:))));
    FitData{i+1,5} = nanmean(nanmean(XFit(:,8,:)));
    FitData{i+1,6} = nanmean(nanmean(XFit(:,9,:)-XFit(:,10,:)));
    FitData{i+1,7} = nanmean(nanmean((XFit(:,9,:)-XFit(:,10,:))./XFit(:,11,:)));
    
    FitData{i+1,8} = nanmean(AFit(:,8));
    FitData{i+1,9} = nanmean(AFit(:,9)-AFit(:,10));
    FitData{i+1,10} = nanmean((AFit(:,9)-AFit(:,10))./AFit(:,11));
end