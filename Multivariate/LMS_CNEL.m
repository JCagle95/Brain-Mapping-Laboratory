function [ Filtered_Output, Error, Iterative_Weights ] = LMS_CNEL(Input, Desire, Filter_Order, Step_Size, Regularizer)
%Least Mean Square Algorithm, implmented by Jackson Cagle
%   [ Filtered_Output, Error, Iterative_Weights ] = LMS_CNEL( Input, Desire, Filter_Order, Step_Size, Regularizer )


Pad_Input = [zeros(Filter_Order-1,1);Input];
Pad_Output = [zeros(Filter_Order-1,1);Desire];

iteration = 1;
Iterative_Weights = zeros(Filter_Order,1);
Error = zeros(length(Pad_Input)-Filter_Order+1,1);
Filtered_Output = zeros(length(Pad_Input)-Filter_Order+1,1);

for n = Filter_Order:length(Pad_Input)
    Var = sum(Pad_Input(n-Filter_Order+1:n).*Pad_Input(n-Filter_Order+1:n));
    Filtered_Output(n-Filter_Order+1) = sum(Iterative_Weights(:,iteration).*Pad_Input(n-Filter_Order+1:n));
    Error(n-Filter_Order+1) = Pad_Output(n) - sum(Iterative_Weights(:,iteration).*Pad_Input(n-Filter_Order+1:n));
    Iterative_Weights(:,iteration+1) = Iterative_Weights(:,iteration) + Step_Size / (Regularizer + Var) * Pad_Input(n-Filter_Order+1:n) * Error(n-Filter_Order+1);
    iteration = iteration + 1;
end

end

