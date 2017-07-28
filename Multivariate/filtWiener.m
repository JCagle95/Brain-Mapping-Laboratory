function [ Filt ] = filtWiener( Data, Window, Filter_Order )
% Filter signal with Wiener Filter. 
%
% J. Cagle, University of Florida, 2017

Block = floor(length(Data)/Window);
Output = zeros(size(Data));

if Block == 1
    W_vector = Wiener_CNEL(Data(1:end-1),Data(2:end),Filter_Order,Window-1,1);
    Output = filterSignal(W_vector, Data(1:end-1));
else
    X = Data(1:Window);
    W_vector = Wiener_CNEL(X(1:end-1),X(2:end),Filter_Order,Window-1,1);
    Output(1:Window) = filterSignal(W_vector, X);
    for i = 2:Block-1
        X = Data((i-1)*Window+1:i*Window);
        W_vector = Wiener_CNEL(X(1:end-1),X(2:end),Filter_Order,Window-1,1);
        subOutput = filterSignal(W_vector, Data((i-1)*Window+1-Filter_Order:i*Window));
        Output((i-1)*Window+1:i*Window) = subOutput(21:end);
    end
    X = Data((Block-1)*Window+1:end);
    W_vector = Wiener_CNEL(X(1:end-1),X(2:end),Filter_Order,Window-1,1);
    subOutput = filterSignal(W_vector, Data((Block-1)*Window+1-Filter_Order:end));
    Output((Block-1)*Window+1:end) = subOutput(21:end);
end

Output(2:end) = Output(1:end-1);
Output(1) = Data(1);
Filt = Data-Output;

end

function Output = filterSignal(W, Input)

Output = zeros(size(Input));
for i = 1:length(Input)
    if i <= length(W)
        Output(i) = sum(Input(1:i).*W(end-i+1:end));
    else
        Output(i) = sum(Input(i-length(W)+1:i).*W);
    end
end

end

