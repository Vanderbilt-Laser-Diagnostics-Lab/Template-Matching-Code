function f = FrameStatsPlot(vals, WindowTitle,PlotXLabel,PlotYLabel,f)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

NFrames = size(vals,2);
FrameStats = zeros(NFrames,3);
for i = 1:NFrames
    x = vals(find(~isnan(vals(:,i))),i);
    N = numel(x);
    u = mean(x);
    s = std(x);
    su = s/sqrt(N);
    uConf95 = tinv(.95,N)*su;
    FrameStats(i,:) =[u s uConf95];
end

XVals = (0:NFrames-1)';

if nargin<5
    f = figure();
else
    figure(f);
    cla;
end

set(gcf,'Name',WindowTitle,'NumberTitle','off');
hold all
errorbar(XVals,FrameStats(:,1) , FrameStats(:,2),'.b');
eb95 = errorbar(XVals,FrameStats(:,1) , FrameStats(:,3),'ok');
set(eb95,'MarkerEdgeColor','r','MarkerFaceColor','r', ...
    'LineWidth',2);
set(gca,'XLim',[-1 NFrames]);
xlabel(PlotXLabel);
ylabel(PlotYLabel);

title(['mean std: ' num2str(sqrt(mean(FrameStats(2:NFrames,2).^2))) ...
    '  max: ' num2str(max(FrameStats(2:NFrames,1))) ...
    '  min: ' num2str(min(FrameStats(2:NFrames,1))) ...
    '  mean: ' num2str(mean(FrameStats(2:NFrames,1))) ...
    '  std: ' num2str(std(FrameStats(2:NFrames,1)))]);