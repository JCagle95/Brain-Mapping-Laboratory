function [ Apriori_Error, Iterative_Weights ] = RLS_CNEL( Input, Desire, Filter_Order, alpha )
%Least Mean Square Algorithm, implmented by Jackson Cagle
%   [ Apriori_Error, Iterative_Weights ] = RLS_CNEL( Input, Desire, Filter_Order, alpha )

    Pad_Input = [zeros(Filter_Order-1,1);Input];
    Pad_Output = [zeros(Filter_Order-1,1);Desire];
    
    Iterative_Weights = zeros(Filter_Order,length(Pad_Input));
    Normalized_Kalman = cell(length(Pad_Input),1);
    Normalized_Power = zeros(length(Pad_Input),1);
    Apriori_Error = zeros(length(Pad_Input),1);
    AutoCorr_Matrix = cell(length(Pad_Input),1);
    AutoCorr_Matrix{Filter_Order-1} = 1*alpha*eye(Filter_Order);

    for n = Filter_Order:length(Pad_Input)
        Input_Vector = Pad_Input(n-Filter_Order+1:n);
        Apriori_Error(n) = Pad_Output(n) - Iterative_Weights(:,n-1)'*Input_Vector;
        Normalized_Kalman{n} = AutoCorr_Matrix{n-1}*Input_Vector*(alpha + Input_Vector'*AutoCorr_Matrix{n-1}*Input_Vector)^-1;
        Normalized_Power(n) = alpha + Input_Vector'*AutoCorr_Matrix{n-1}*Input_Vector;
        Iterative_Weights(:,n) = Iterative_Weights(:,n-1) + Normalized_Kalman{n}*Apriori_Error(n);
        AutoCorr_Matrix{n} = AutoCorr_Matrix{n-1}/alpha-Normalized_Kalman{n}*Input_Vector'/alpha*AutoCorr_Matrix{n-1};
    end

    Apriori_Error = Apriori_Error(Filter_Order:end);
    Iterative_Weights = Iterative_Weights(:,Filter_Order:end);
    
end

