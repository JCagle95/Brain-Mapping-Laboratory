function [ handler ] = largeFigure( x, size )
%largeFigure is a aliased version of figure function with pre-determined
%windows size.
%
%   h = largeFigure( x, size );
%
% J. Cagle, University of Florida, 2013

if x > 0
    handler = figure(x);
else
    handler = figure();
end
set(handler,'Position',[0 0 size]);
set(handler,'PaperPositionMode','auto');
end

