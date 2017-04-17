function [ cHandle ] = addColorbar( Title, varargin )
%Modified Colorbar Function
%   [ cHandle ] = addColorbar( Title )
%
%   Add colorbar to current axis with title string given in input.
%   Resize current axis to maintain the same scale as before colorbar
%   added.
%
%   J. Cagle, University of Florida 2016

imageAxis = get(gca, 'position');
cHandle = colorbar();
textH = ylabel(cHandle,Title,'fontsize',12,'Rotation',-90.0,'VerticalAlignment','bottom');
set(gca, 'position', imageAxis);

if length(varargin) == 1
    set(textH,'fontsize',varargin{1})
end

end

