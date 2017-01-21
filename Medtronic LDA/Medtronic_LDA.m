%% Load Data
FileName = 'Placeholder';
Data = importdata(FileName);
X = Data(:,3);

%{
% This is the Exploring-Cloud Coefficients
Detector = xmlParser('Generated_Coefficient.xml');
Normalized_X = (X - Detector.Coefficients.NormConstA1) * str2double(Detector.Coefficients.NormConstB1);
Detection = Normalized_X * str2double(Detector.Coefficients.W1) - str2double(Detector.Coefficients.b);
%}

%% Generate Coefficients
Coefficients = generateCoefficients(X,'Normalize',false);
Normalized_X = (X - Coefficients.NormConstA1) * Coefficients.NormConstB1;
Detection = Normalized_X * Coefficients.W1 - Coefficients.b;

% Plots 
largeFigure(150, [1280 720]); clf; hold on; box on;
plot(X,'b','linewidth',1);
YLim = get(gca,'YLIM');
plot((Detection>0)*YLim(2)+YLim(1),'r','linewidth',1);
xlabel('Sample','fontsize',15);
ylabel('Sense Power','fontsize',15);
title('Prediction','fontsize',18);

subplot(2,1,2); cla;
area(sign(Detection)<0);
