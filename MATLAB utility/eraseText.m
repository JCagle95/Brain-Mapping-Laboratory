function eraseText( string )
%Remove printed string on 
%   eraseText(string);
%       Remove string from command line window
%   eraseText(N);
%       Remove N characters from command line window
%
%   J. Cagle, University of Florida, 2017

if ischar(string)
    fprintf('%s',char(8)*ones(length(string),1));
else isnumeric(string)
    fprintf('%s',char(8)*ones(string,1));
end
end

