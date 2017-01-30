function [handles] = addShading( aH, Positive, Duration, varargin )
%Add Color Shading to a graphical axes. 
%   handles = addShading(aH, Positive, Duration);
%       Positive is either a Vector with Odd-element indicating beginning
%       of the shading and Even-element indicating finishing of the
%       shading. The Duration is the Window Size that the shading want to
%       be added to. The default Color is green.
%
%   handles = addShading(aH, Positive, Duration, Color);
%       Color can be modified by adding to the input arguments.
%
%   J. Cagle, University of Florida, 2016

hold(aH, 'on');

Color = 'g';
if length(varargin)==1
    Color = varargin{1};
end

Limit = get(aH,'YLim');
X = linspace(Duration(1),Duration(2),1000);
Y = zeros(size(X)) - 10 + Limit(1);

if size(Positive,2) > 2 && size(Positive,1) == 1
    for i = 1:2:size(Positive,2)
        Y(X < Positive(i+1) & X > Positive(i)) = Limit(2) + 10;
    end
else
    for i = 1:size(Positive,1)
        Y(X < Positive(i,2) & X > Positive(i,1)) = Limit(2) + 10;
    end
end
handles = area(aH, X, Y, min(Y), 'facecolor', Color, 'edgecolor', Color);
alpha(handles, 0.4);
ylim(aH, Limit);

hold(aH, 'off');

end

