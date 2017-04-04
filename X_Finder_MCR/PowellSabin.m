function [bnet, tri, X,Y,Z] = PowellSabin(p1,p2,p3,d1,d2,d3, x0,x1,x2,x3)
% PowellSabin -- Powell-Sabin Hermite Spline Interpolant
%  Usage
%    Bnet = PowellSabin(p1,p2,p3,d1,d2,d3)
%  Inputs
%    p1,p2,p3        vertices of triangle, 2x1 vectors
%    d1, d2, d3      order 1 Hermite data at p1, p2, p3, 3x1 vectors
%    x0, x1, x2, x3  PS-split points, 2x1 vectors. Optional, default: 
%                    x0 = centroid of triangle (p1,p2,p3), x1,x2,x3 = midpoint of
%                    edges 
%  Outputs
%    bnet            Bnet representation of the (unique) Powell-Sabin
%                    Hermite Interpolant, cell array of length 6, recording
%                    the Bezeir control points of the 6 quadratic
%                    polynomials in the P-S Hermite interpolant.
%                    
%                    We use the following convention in our data-structure:
%                     1. The six triangles are enumerated as i=1,...,6, in a
%                     counter-clockwise order, starting from the one with
%                     vertex p1, and edge (p1,x1).
%                     2. Within each sub-triangle, the Bezeir coefficients
%                     are labelled as 
%                     bnet{i}.b200, bnet{i}.b110, bnet{i}.b020,
%                     bnet{i}.b011, bnet{i}.b002, bnet{i}.b101
%                     based on the Berstein basis of the sub-triangle i
%                     w.r.t. the counterclock labelling of the three
%                     vertices, beginning with the unique vertex of the micro triangle
%                     that is also a vertex of the macro triangle.
%                    
%                    This data-structure is redundant, e.g. bnet{1}.b020 =
%                    bnet{2}.b002, etc.
% 
%  Note I:
%    Thanks to the object-oriented capability in Matlab, this code runs in 
%    both numerical mode and symbolic mode, depending on the class of the
%    input data.
%    In the numerical mode, some graphics is provided to visualize
%    the Powell-Sabin interpolant. Try:
%    bnet = PowellSabin([0;0],[1;0],[cos(2*pi/6);sin(2*pi/6)], rand(3,1),rand(3,1),rand(3,1));
%
%  Note II:
%    Powell and Sabin in 1977 published a neat way to interpolate any given
%    order 1 Hermite data (d1,d2,d3 above) specified at the three vertices 
%    of any given triangle (p1,p2,p3 above.) The trick is to split the 
%    given `macro' triangle into 6 `micro'
%    sub-triangles, and it turns out that there is a unique piecewise
%    quadratic function that matches the given Hermite data and is C^1
%    smooth over the whole 'macro' triangle.
% 
%    How to compute it? 
%    Once we know that such an interpolant is unique 
%    (as Powell and Sabin showed), then, in principle,
%    it is just a matter of solving a small linear system.
%    
%    Gerald Farin and Carl de Boor in the 80's & early 90's 
%    promoted the use of Berstein-Bezeir form  to
%    study multivariate splines. In review articles by them, they showed that
%    the P-S interpolant can be determined very easily -- without solving
%    any linear system -- if written in Berstein bases. This essentially
%    means that that the Berstein basis diagonalizes the linear system underlying
%    the interpolation problem. 
%    This routine is based on the BB-form approach.
% 

% Default of PS split points
if nargin == 6,
    x0 = (p1+p2+p3)/3; % centroid of (p1,p2,p3)
    x1 = (p1+p2)/2; % midpoint of (p1,p2)
    x2 = (p2+p3)/2;  
    x3 = (p3+p1)/2;
end
%%

mode = class(p1); % either 'sym' or 'double'

bnet{1} = struct('b200',d1(1),'b110',[],'b020',[],'b011',[],'b002',[],'b101',[]);
bnet{2} = struct('b200',d2(1),'b110',[],'b020',[],'b011',[],'b002',[],'b101',[]);
bnet{3} = struct('b200',d2(1),'b110',[],'b020',[],'b011',[],'b002',[],'b101',[]);
bnet{4} = struct('b200',d3(1),'b110',[],'b020',[],'b011',[],'b002',[],'b101',[]);
bnet{5} = struct('b200',d3(1),'b110',[],'b020',[],'b011',[],'b002',[],'b101',[]);
bnet{6} = struct('b200',d1(1),'b110',[],'b020',[],'b011',[],'b002',[],'b101',[]);
% sub-triangle 1
PHI = inv([[p1,x1,x0];[1,1,1]]); if strcmp(mode,'sym'), PHI = simple(PHI); end
b = inv([[1,0,0];[2*PHI(:,1:2)']]) * d1; if strcmp(mode,'sym'), b = simple(b); end
bnet{1}.b110 = b(2); bnet{1}.b101 = b(3);
% sub-triangle 2
PHI = inv([[p2,x0,x1];[1,1,1]]); if strcmp(mode,'sym'), PHI = simple(PHI); end
b = inv([[1,0,0];[2*PHI(:,1:2)']]) * d2; if strcmp(mode,'sym'), b = simple(b); end
bnet{2}.b110 = b(2); bnet{2}.b101 = b(3);
% sub-triangle 3
PHI = inv([[p2,x2,x0];[1,1,1]]); if strcmp(mode,'sym'), PHI = simple(PHI); end
b = inv([[1,0,0];[2*PHI(:,1:2)']]) * d2; if strcmp(mode,'sym'), b = simple(b); end
bnet{3}.b110 = b(2); bnet{3}.b101 = b(3);
% sub-triangle 4
PHI = inv([[p3,x0,x2];[1,1,1]]); if strcmp(mode,'sym'), PHI = simple(PHI); end
b = inv([[1,0,0];[2*PHI(:,1:2)']]) * d3; if strcmp(mode,'sym'), b = simple(b); end
bnet{4}.b110 = b(2); bnet{4}.b101 = b(3);
% sub-triangle 5
PHI = inv([[p3,x3,x0];[1,1,1]]); if strcmp(mode,'sym'), PHI = simple(PHI); end
b = inv([[1,0,0];[2*PHI(:,1:2)']]) * d3; if strcmp(mode,'sym'), b = simple(b); end
bnet{5}.b110 = b(2); bnet{5}.b101 = b(3);
% sub-triangle 6
PHI = inv([[p1,x0,x3];[1,1,1]]); if strcmp(mode,'sym'), PHI = simple(PHI); end
b = inv([[1,0,0];[2*PHI(:,1:2)']]) * d1; if strcmp(mode,'sym'), b = simple(b); end
bnet{6}.b110 = b(2); bnet{6}.b101 = b(3);
%%
bnet{1}.b020 = (bnet{1}.b110 + bnet{2}.b101)/2; bnet{2}.b002 = bnet{1}.b020;
bnet{3}.b020 = (bnet{3}.b110 + bnet{4}.b101)/2; bnet{4}.b002 = bnet{3}.b020;
bnet{5}.b020 = (bnet{5}.b110 + bnet{6}.b101)/2; bnet{6}.b002 = bnet{5}.b020;
%%
bnet{1}.b011 = (bnet{1}.b101 + bnet{2}.b110)/2; bnet{2}.b011 = bnet{1}.b011;
bnet{3}.b011 = (bnet{3}.b101 + bnet{4}.b110)/2; bnet{4}.b011 = bnet{3}.b011;
bnet{5}.b011 = (bnet{5}.b101 + bnet{6}.b110)/2; bnet{6}.b011 = bnet{5}.b011;
%%
c = (bnet{1}.b011+bnet{3}.b011+bnet{5}.b011)/3; if strcmp(mode,'sym'), c = simple(c); end
bnet{1}.b002 = c; bnet{2}.b020 = c;
bnet{3}.b002 = c; bnet{4}.b020 = c;
bnet{5}.b002 = c; bnet{6}.b020 = c;

% plot the Powell-Sabin patch if input consists of floating point data:
% if strcmp(mode,'double'),
%     h=.2;
%     for tri = 1:6,
%         b200 = bnet{tri}.b200; b110 = bnet{tri}.b110; b020 = bnet{tri}.b020;
%         b011 = bnet{tri}.b011; b002 = bnet{tri}.b002; b101 = bnet{tri}.b101;
%         if tri==1,
%             P1=p1; P2=x1; P3=x0;
%         elseif tri==2,
%             P1=p2; P2=x0; P3=x1;
%         elseif tri==3,
%             P1=p2; P2=x2; P3=x0;
%         elseif tri==4,
%             P1=p3; P2=x0; P3=x2;
%         elseif tri==5,
%             P1=p3; P2=x3; P3=x0;
%         elseif tri==6,
%             P1=p1; P2=x0; P3=x3;
%         end
%         X = []; Y = []; Z = [];
%         for u = 0:h:1, 
%             for v=0:h:1-u,
%                 w = 1-u-v;
%                 x = u*P1(1)+v*P2(1)+w*P3(1); X = [X x];
%                 y = u*P1(2)+v*P2(2)+w*P3(2); Y = [Y y];
%                 z = b200*u^2 + 2*b110*u*v + b020*v^2 + 2*b011*v*w + b002*w^2 + 2*b101*u*w;
%                 Z = [Z,z];
%             end, 
%         end
%         tri = delaunay(X,Y);
%         trisurf(tri,X,Y,Z), hold on, % trisurf(tri,X,Y,zeros(size(Z))),
%     end
%     hold off
%     axis equal
% end

% 
% Copyright (c) 2004. Thomas P.Y. Yu
% 

