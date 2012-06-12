function [vertices, faces, facevertexcdata] = u3d_pre_surface(ax)
%U3D_PRE_SURFACE    Preprocess surface output to u3d.
%    U3D_PRE generates the input for the MESH_TO_LATEX function from
%    Alexandre Gramfort from your surface-graphs. The surface graphs 3d-model can be
%    displayed in u3d - format in pdf or if you don't delete the u3d-files
%    which are generated by MESH_TO_LATEX you can use deepview from
%    righthemisphere(http://www.righthemisphere.com/products/client-products/deep-view) 
%    to embed the modell in Microsoft-Office products (Word, Excel, PowerPoint). 
%
% usage 
%   [vertices, faces, facevertexcdata] = U3D_PRE_SURFACE
%   [vertices, faces, facevertexcdata] = U3D_PRE_SURFACE(h)
%
% optional input
%   ax = axes object handle
%
% output
%   vertices = row vectors of point positions, as row cell array
%              for multiple surfaces
%            = {1 x #surfaces}
%            = {[#vertices x 3], ... }
%   faces = for each surface triangle face, indices of its 3 vertices,
%           these indices refer to the columns of matrix vertices,
%           as row cell array for multiple surfaces
%         = {1 x #surfaces}
%         = {[#faces x 3], ... }
%   facevertexcdata = RGB color information at each vertex,
%                     as row cell array for multiple surfaces
%                   = {1 x #surfaces}
%                   = {[#vertices x 3], ... }
%
% See also FIG2IDTF, U3D_PRE_LINE, U3D_PRE_QUIVERGROUP.
%
% File:      u3d_pre_surface.m
% Original Author: Sven Koerner, koerner(underline)sven(add)gmx.de
% Author:    Ioannis Filippidis, jfilippidis@gmail.com (added support for multiple surfaces)
% Date:      2012.06.10 - 
% Language:  MATLAB R2012a
% Purpose:   preprocess surface children of axes for u3d export
% Copyright:
%
% License to use and modify this code is granted freely to all interested,
% as long as the original author is referenced and attributed as such.
% The original author maintains the right to be solely associated with this work.

%% input
if nargin < 1
    sh = findobj('type', 'surface');
else
    objs = get(ax, 'Children');
    sh = findobj(objs, 'type', 'surface');
end

if isempty(sh)
    disp('No surfaces found.');
    vertices            = [];
    faces               = [];
    facevertexcdata     = [];
    return
end

%% process each surface
N = size(sh, 1); % number of surfaces
vertices = cell(1, N);
faces = cell(1, N);
facevertexcdata = cell(1, N);
for i=1:N
    disp(['     Preprocessing surface No.', num2str(i) ] );
    h = sh(i, 1);
    
    [v, f, fvx] = single_surf_preprocessor(h);
    
    vertices{1, i} = v;
    faces{1, i} = f;
    facevertexcdata{1, i} = fvx;
end

function [vertices, faces, facevertexcdata] = single_surf_preprocessor(h)
% get defined data-points
X = get(h, 'XData');
Y = get(h, 'YData');
Z = get(h, 'ZData');

%{
n = size(X, 1);
m = size(X, 2);
Vi = n *m; % number of vertices
Fi = 2 *(n-1) *(m -1); % number of faces, due to wraping (closing of the surface)
disp([num2str(j) ' Object Vertex # = ', num2str(Vi) ] )
disp([num2str(j) ' Object Face # = ', num2str(Fi) ] )
%}
% scaled color to unscaled r
cdata = get(h, 'CData');

siz = size(cdata);
cmap = colormap;
nColors = size(cmap, 1);
cax = caxis;
idx = ceil( (double(cdata) -cax(1) ) / (cax(2) -cax(1) ) *nColors);
idx(idx < 1) = 1;
idx(idx > nColors) = nColors;
%handle nans in idx
nanmask = isnan(idx);
idx(nanmask) = 1; %temporarily replace w/ a valid colormap index
realcolor = zeros(siz);
for i = 1:3,
    c = cmap(idx, i);
    c = reshape(c, siz);
    realcolor(:, :, i) = c;
end

fvc = surf2patch(X, Y, Z, realcolor, 'triangles');

vertices = fvc.vertices;
faces = fvc.faces;
facevertexcdata = fvc.facevertexcdata;

%% surface concatenation (obsolete - although it reduces file size)
%tempfvc.faces = tempfvc.faces +V; % shift to account for previous vertices

% append to previous
%fvc.vertices = [fvc.vertices; tempfvc.vertices];
%fvc.faces = [fvc.faces; tempfvc.faces];
%fvc.facevertexcdata = [fvc.facevertexcdata; tempfvc.facevertexcdata];

%V = size(fvc.vertices, 1); %V = V +Vi;

%{
F = size(fvc.faces, 1);
C1 = size(fvc.facevertexcdata, 1);
C2 = size(fvc.facevertexcdata, 2);
disp(['Vertex # = ', num2str(V) ] )
disp(['Face # = ', num2str(F) ] )
disp(['Vertex Colors = ', num2str(C1), ' x ', num2str(C2) ] )
%}
