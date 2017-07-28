function [ hL ] = legendFont( Handler, Input, Config )
%legendFont is the aliased version of legend with box off.
%   [ hL ] = legendFont( Handler, Input, Config );
%
% J. Cagle, University of Florida, 2013

hL = legend(Handler,Input);
for n = 1:length(Config)/2
    set(hL,Config{(n-1)*2+1},Config{n*2});
end
legend(gca,'boxoff');

end

