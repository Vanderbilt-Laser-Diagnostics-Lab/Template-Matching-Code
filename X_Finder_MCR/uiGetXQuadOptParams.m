function [Rad NRad Gen ShrnkFctr LockAng] = ...
    uiGetXQuadOptParams(Shape, Uncer, NR, Gen, ShrnkFctr)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

% Shape = [Ang1 Ang2 RelIntens LinWid LegLen]

if nargin < 2; Uncer = 1; end;
if nargin < 3; NR = 5; end;
if nargin < 4; Gen = 3; end;
if nargin < 5; ShrnkFctr = 2; end;

DefAngU = atan(Uncer/Shape(5));
DefIntensU = min(Shape(3), 1-Shape(3)) / 2;
DefLinWidU = .75*Shape(3);

prompt = {'Location uncertainty (pixels):' ...
    'Angle uncertainty (radians):' 'Lock X angle (true/false)?' ...
    'Intensity uncertainty:' 'Linewidth sigma uncertainty:' ...
    'Number of intervals (>2):' 'Generations:' 'Shrink factor:'};
name = 'XQuadOpt: Input Required';
numlines = 1;
defaultanswer = {num2str(2*Uncer) num2str(DefAngU) 'false' ...
    num2str(DefIntensU) num2str(DefLinWidU) num2str(NR) ...
    num2str(Gen) num2str(ShrnkFctr)};
options.WindowStyle = 'normal';
answer = inputdlg(prompt,name,numlines,defaultanswer,options);

LocR = str2double(answer{1});
AngR = str2double(answer{2});
LockAng = str2num(answer{3});
if ~islogical(LockAng); LockAng = false; end;
IR = str2double(answer{4});
LWR = str2double(answer{5});
NR = str2double(answer{6});
Gen = str2double(answer{7});
ShrnkFctr = str2double(answer{8});

NRPos = ceil(NR/2);

Rad = [LocR LocR AngR AngR IR LWR 0];
NRad = [NRPos NRPos NR NR NR NR 0];

end