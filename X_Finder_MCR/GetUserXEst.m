function [X Uncer MaxN] = GetUserXEst(fig,ax)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

%% initialize figure
figure(fig);
FigName = get(fig,'Name');
msg = 'Draw best X, double click on each line to continue.';
set(fig,'Name',msg);
disp(msg);

%% get position estimate from user
fcn = makeConstrainToRectFcn('imline',get(ax,'XLim'),get(ax,'YLim'));
for i = 1:2
    h(i) = imline;
    setPositionConstraintFcn(h(i),fcn);
    pos(i,:,:) = wait(h(i));
end

delete(h);

%% get parameters from user
prompt = {'Approx line width FWHM:' ...
    'Fraction of light in positive slope line:' ...
    'Location uncertainty (pixels):' ...
    'Max number of intersections:'};
name = 'Input Required';
numlines = 1;
defaultanswer = {'4' '0.5' '1' '121'};
options.WindowStyle = 'normal';
answer = inputdlg(prompt,name,numlines,defaultanswer,options);

LinWid = str2double(answer{1}) / 2.35;
Intens1 = str2double(answer{2});
Uncer = str2double(answer{3});
MaxN = round(str2double(answer{4}));

%% calculate and return shape
for i = 1:2
    seg(i) = SegmentMCR(pos(i,1,:) , pos(i,2,:));
end

a = atan([seg(1).u(2)/seg(1).u(1) seg(2).u(2)/seg(2).u(1)]);

Ang1 = max(a);
Ang2 = min(a);
[IB t CPnt] = seg(1).Intersect(seg(2));
LegLen = mean([seg(1).L seg(2).L])/2;

X = [CPnt(1) CPnt(2) Ang1 Ang2 Intens1 LinWid LegLen];

%% reset figure name
set(fig,'Name',FigName);