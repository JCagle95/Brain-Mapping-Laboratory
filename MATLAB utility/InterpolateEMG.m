function [ Output ] = InterpolateEMG( Data )
%Simple Replacement for missing data in Delsys EMG system
%   [ Output ] = InterpolateEMG( Data )
%
% J. Cagle, University of Florida, 2016

Output = Data;
for x = 2:length(Output)
    if Output(x) == 0
        Output(x) = Output(x-1);
    end
end

end

