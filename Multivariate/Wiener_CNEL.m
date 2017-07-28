function [ W_Vector ] = Wiener_CNEL( Data, Desired, Filter_Order, Window_Length, Start )
%Compute Adaptive FIR Weight Based on Wiener Theorem

R_Matrix = zeros(Filter_Order);
Data = Data(Start:Start-1+Window_Length);
Data = (Data - mean(Data));
Desired = Desired(Start:Start-1+Window_Length);
Desired = (Desired - mean(Desired));
cross_corr=xcorr(Desired,Data,Window_Length);
P_Vector=flip(cross_corr(1+Window_Length:Window_Length+Filter_Order));

for k = 1:Filter_Order
    ACF = AutoCorFunc(Data,1-k,0);
    R_Matrix(k,:) = ACF(1:Filter_Order);
end

W_Vector = inv(R_Matrix)*P_Vector;

end

