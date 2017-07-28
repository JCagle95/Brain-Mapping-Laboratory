function [ ACF ] = AutoCorFunc( X, Start, Max_Length )
%Autocorrelation with Brute Force Computation (No Optimization)
%   [ ACF ] = AutoCorFunc( X, Start )
%   
%   J. Cagle, University of Florida, 2017

ACF = zeros(length(X)+length(X)-1,1);

for i = 1:length(X)
    ACF(i) = sum(X(end-i+1:end).*X(1:i));
end

for k = 1:length(X)-1
    ACF(length(X)+k) = sum(X(k+1:end).*X(1:end-k));
end

[~,I] = max(ACF);
if Max_Length == 0
    ACF = ACF(I+Start:I+Start+length(X)-1);
else
    ACF = ACF(I+Start:I+Start+Max_Length);
end

end

