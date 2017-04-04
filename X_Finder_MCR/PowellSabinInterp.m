function [u v] = PowellSabinInterp(XDel, XI, YI)

% Software supplied with no explicit or implied claims or warranty
% of suitability for any application.
%
% Copyright Marc C. Ramsey, 2010

% [u v] = PowellSabinInterp(XDel, XI, YI)
%
% XDel(i,:) = [x y t1 t2 dx dy dy1dx1 dy2dx2]
% XI and YI are coordinate matrices of equal size
%
% u and v are velocities interpolated at XI and YI

%% turn off Matlab warning
disp('Note: PowellSabinInterp uses tsearch, a Matlab deprecated function.');
warning('off','MATLAB:tsearch:DeprecatedFunction');

%% reject invalid data points
XDel = XDel(isfinite(XDel(:,5)),:);
n = size(XDel,1);

%% triangulate data
X = XDel(:,1);
Y = XDel(:,2);
TRI = delaunay(X,Y);
A = abs(  ( X(TRI(:,1)).*(Y(TRI(:,2))-Y(TRI(:,3))) + ...
            X(TRI(:,2)).*(Y(TRI(:,3))-Y(TRI(:,1))) + ...
            X(TRI(:,3)).*(Y(TRI(:,1))-Y(TRI(:,2))) ) / 2);
TRI(A < .1*median(A),:) = [];

nT = size(TRI,1);
T = tsearch(XDel(:,1),XDel(:,2),TRI,XI,YI);

%% estimate local gradients by planar fit to neighbors
UDat = zeros(n,3);
VDat = zeros(n,3);
for i = 1:n
    [rows cols] = find(TRI==i);
    set = unique(TRI(rows,:));
    
%     DerU = DerEst2LS(XDel(set,1:2),XDel(set,5),XDel(i,1:2));
%     DerV = DerEst2LS(XDel(set,1:2),XDel(set,6),XDel(i,1:2));
    DerU = DerEstLS(XDel(set,1:2),XDel(set,5));
    DerV = DerEstLS(XDel(set,1:2),XDel(set,6));
    
    EstDers = [DerU(1) DerV(1) DerU(2) DerV(2)]; 
    TDers = TransformDerivs(XDel(i,3:4), XDel(i,7:8), EstDers);
    %[EstDers - TDers']
    
    UDat(i,:) = [XDel(i,5) TDers([1 3])'];
    VDat(i,:) = [XDel(i,6) TDers([2 4])'];
%     UDat(i,:) = [XDel(i,5) EstDers([1 3])];
%     VDat(i,:) = [XDel(i,6) EstDers([2 4])];
%     UDat(i,:) = [XDel(i,5) 0 0];
%     VDat(i,:) = [XDel(i,6) 0 0];
end

%% get Powell-Sabin Nodes and BNets
Nodes = cell(nT,1);
BNetsU = cell(nT,1);
BNetsV = cell(nT,1);
for i = 1:nT
    p1 = XDel(TRI(i,1),1:2);
    p2 = XDel(TRI(i,2),1:2);
    p3 = XDel(TRI(i,3),1:2);
    
    Nodes{i}=[p1; p2; p3];
    
    d1U = UDat(TRI(i,1),:)';
    d2U = UDat(TRI(i,2),:)';
    d3U = UDat(TRI(i,3),:)';
    BNetsU{i} = PowellSabin(p1',p2',p3',d1U,d2U,d3U);
    
    d1V = VDat(TRI(i,1),:)';
    d2V = VDat(TRI(i,2),:)';
    d3V = VDat(TRI(i,3),:)';
    BNetsV{i} = PowellSabin(p1',p2',p3',d1V,d2V,d3V);
end

%% interpolate    
u = NaN(size(XI));
v = NaN(size(XI));
for i = 1:size(TRI,1)
    ind = T==i;
    x = XI(ind); y = YI(ind);
    u(ind) = PSEval(BNetsU{i},Nodes{i},[x y]);
    v(ind) = PSEval(BNetsV{i},Nodes{i},[x y]);
end

end

function der = DerEstLS(X,Z)

% der = DerEstLS(X,Z)
% estimates gradient of Z(x,y) with a LS planar fit
%
% for i = 1:n input values
% X(i,:) = [x y]
% Z = [z_1:z_n]'
%
% der = [dzdx dzdy]

if size(X,1) >= 3
    A = [X ones(size(X,1),1)];
    C = A\Z;
    der = [C(1) C(2)];
else
    der = [0 0];
end

end

function ders = TransformDerivs(Angles, MeasuredDers, EstDers)

% ders = TransformDerivs(Angles, MeasuredDers, EstDers)
% ders = [Ux Vx Uy Vy];
%
% Angles = [A1 A2];
% MeasuredDers = [dV1dX1 dV2dX2];
% EstDers = [Ux Vx Uy Vy];

s = sin(Angles);
c = cos(Angles);

A = [ c(1)*[-s(1) c(1)] s(1)*[-s(1) c(1)] ; ...
      c(2)*[-s(2) c(2)] s(2)*[-s(2) c(2)] ; ...
     -s(1)*[-s(1) c(1)] c(1)*[-s(1) c(1)] ; ...
     -s(2)*[-s(2) c(2)] c(2)*[-s(2) c(2)] ];
%       c(2)*[-s(1) c(1)] s(2)*[-s(1) c(1)] ; ...
%       c(1)*[-s(2) c(2)] s(1)*[-s(2) c(2)] ];
  
b = [MeasuredDers'; A(3:4,:)* EstDers'];

ders = A\b;

end

function out = PSEval(bnet,P,pnts)
% out = PSEval(bnet,P,pnts)
%
% bnet = output from PowellSabin
% P = [p1 p2 p3]' where pn are 1x2 vectors [x y]
%     or [p1 p2 p3 x0 x1 x2 x3]'
% pnts = n by 2 column vector of x,y coordinates
%
% out = column vector of PowellSabin values at pnts

%% calculate centroid and midpoints if not provided
if size(P,1) == 3
    x0 = (P(1,:)+P(2,:)+P(3,:))/3; % centroid of (p1,p2,p3)
    x1 = (P(1,:)+P(2,:))/2; % midpoint of (p1,p2)
    x2 = (P(2,:)+P(3,:))/2;  
    x3 = (P(3,:)+P(1,:))/2;
    
    P = [P; x0; x1; x2; x3];
end

%% define sub-triangles and identify corresponding pnts
SubTris = [1 5 4; 2 4 5; 2 6 4; 3 4 6; 3 7 4; 1 4 7];
T = tsearch( P(:,1),P(:,2),SubTris,pnts(:,1),pnts(:,2) );

%% calculate PowellSabin output
out = NaN(size(pnts,1),1);
for i = 1:6
    ind = find(T==i);
    n = numel(ind);
    
    b200 = bnet{i}.b200; b110 = bnet{i}.b110; 
    b020 = bnet{i}.b020; b011 = bnet{i}.b011;
    b002 = bnet{i}.b002; b101 = bnet{i}.b101;
    
    A = [1 1 1; P(SubTris(i,:),1)'; P(SubTris(i,:),2)'];
    Z = [ones(1,n); pnts(ind,:)'];
    b = A\Z;
    
    out(ind) = b200*b(1,:).^2 + 2*b110*b(1,:).*b(2,:) + ...
                b020.*b(2,:).^2 + 2*b011*b(2,:).*b(3,:) + ...
                b002*b(3,:).^2 + 2*b101*b(1,:).*b(3,:);
end

end
