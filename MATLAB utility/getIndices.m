function indices = getIndices( N, Window, Overlap, varargin )
%Get the beginning indices for moving window applications
%   indices = getIndices( N, Window, Overlap )
%   J. Cagle, University of Florida, 2017

indices = 1:(Window-Overlap):(N-Window)+1;
if ~isempty(varargin)
    if strcmpi(varargin{1}, 'floor') && indices(end)+Window > N
        indices = indices(1:end-1);
    end
end

end

