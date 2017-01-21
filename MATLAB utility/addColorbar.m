function [ cHandle ] = addColorbar( Title )
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
ylabel(cHandle,Title,'fontsize',12,'Rotation',-90.0,'VerticalAlignment','bottom');
set(gca, 'position', imageAxis);

end

