function Entropy = SampEn( Data, m, r )
%Sample Entropy Calculation with Chebyshev Distance
%   Entropy = SampEn(Data,m,r);
%       Implemented based on Richman et. al. 's Sample Entropy
%       Calculation [1].
%
%   [1] Richman, J. S., Lake, D. E., & Moorman, J. R. (2004). Sample Entropy. Methods in Enzymology, 384, 172–184. https://doi.org/10.1016/S0076-6879(04)84011-4
%
%   J. Cagle, University of Florida, 2017

N = length(Data);
endIndex = N-m+1;
Threshold = r * std(Data);

B = 0;
A = 0;
for i = 1:N-m
    B = B + 1; % This is for i = k, which should be 0 all the time
    A = A + 1; % This is for i = k, which should be 0 all the time
    for k = i+1:N-m
        D = max(abs(Data(i:i+m-1) - Data(k:k+m-1)));
        if D < Threshold
            B = B + 1;
        end
        if max([D,Data(i+m)-Data(k+m)]) < Threshold
            A = A + 1;
        end
    end
    if max(abs(Data(i:i+m-1) - Data(endIndex:endIndex+m-1))) < Threshold
        B = B + 1;
    end
end

Entropy = -log(A/B);

end