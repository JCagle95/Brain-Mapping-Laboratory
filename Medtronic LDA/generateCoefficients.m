function Coefficients = generateCoefficients( Data, varargin )
%generateCoefficients will output coefficients for Linear Discriminant Analysis
%   
%   Coefficients = generateCoefficients( Data );
%   
%   Coefficients = generateCoefficients( Data, 'Normalize', false );
%       will return coefficients without normalization. Default is Z-score
%       normalization.
%
%   generateCoefficients will render "pseudo-Graphical User Interface" that
%   mimic the exploring-cloud functionality from Medtronic's Web-based 
%   coefficient generator. 
%
% J. Cagle, University of Florida 2017

Coefficients = struct('NormConstA1',0,'NormConstA2',0,'NormConstA3',0,'NormConstA4',0, ...
                      'NormConstB1',1,'NormConstB2',1,'NormConstB3',1,'NormConstB4',1, ...
                      'W1',0,'W2',0,'W3',0,'W4',0,'b',0);
SampleRate = 5;
Zscore = true;
Target = [];
filename = 'Coefficients';

% Input Parsing
if nargin > 1
    if rem(nargin - 1,2) ~= 0
        error('Incorrect number of input arguments.');
    end
    
    for n = 1:2:length(varargin)
        if ~ischar(varargin{n})
            error('Incorrect number of input arguments.');
        end
        switch upper(varargin{n})
            case 'NORMALIZE'
                Zscore = varargin{n+1};
            case 'SAMPLERATE'
                SampleRate = varargin{n+1};
            otherwise
                error('Unknown input arguments.');
        end
    end
end

% Preprocessing
if Zscore
    Coefficients.NormConstA1 = round(mean(Data));
    Coefficients.NormConstB1 = 1/std(Data);
    Data = (Data - Coefficients.NormConstA1) * Coefficients.NormConstB1;
end
TimeIndex = 0:1/SampleRate:(length(Data)-1)/SampleRate;

% Display the plots
drawFigure(TimeIndex, Data, Zscore);

% Graphical Representation of Target Region
while true
    [TimePoint, ~, button] = ginput(1);
    if button == 3
        break;
    end
    
    ret = checkTimePoint(Target,TimePoint);
    if ret > 0
        if length(Target) > ret + 2
            Target = [Target(1:ret-1),Target(ret+2:end)];
        else
            Target = Target(1:ret-1);
        end
        
        drawFigure(TimeIndex, Data, Zscore);
        if ~isempty(Target)
            addShading(gca, Target, [0 max(TimeIndex)]);
        end
        
        continue;
    else
        Target = [Target, TimePoint];
    end
    
    [TimePoint, ~, button] = ginput(1);
    if button == 3
        Target = Target(1:end-1);
    else
        if TimePoint < Target(end)
            Target = [Target, Target(end)];
            Target(end-1) = TimePoint;
        else
            Target = [Target, TimePoint];
        end
        addShading(gca, Target(end-1:end), [0 max(TimeIndex)]);
    end
end

% Compute Label Vector based on Input
Label = zeros(size(TimeIndex))';
for i = 1:2:length(Target)
    Label(TimeIndex < Target(i+1) & TimeIndex > Target(i)) = 1;
end

% Compute LDA Coefficients
W = computeLDA(Data, Label);
PreditiveScore = W'*Data';

% Display ROC Curve, or Histogram
largeFigure(1000, [1280 820]); clf;
AX1 = subplot(2,1,1); cla; hold on; box on;
H1 = histogram(PreditiveScore(Label==0),'Normalization','probability','BinWidth',range(PreditiveScore)/100);
H2 = histogram(PreditiveScore(Label==1),'Normalization','probability','BinWidth',range(PreditiveScore)/100);
title('Probabiltiy Density Function','fontsize',18);
Legend_Font(gca,{'Non-Event States','Event States'},{'fontsize',12});
xlim([min(PreditiveScore),max(PreditiveScore)]);
ylim(get(AX1,'YLIM'));
set(gca,'XTickLabel',{});

AX2 = subplot(2,1,2); cla; hold on; box on;
[FalsePositive,TruePositive,Threshold] = perfcurve(Label,PreditiveScore,1);
plot(Threshold,FalsePositive * 100,'b-','linewidth',2);
plot(Threshold,TruePositive * 100,'r-','linewidth',2);
title('Predictor Bias','fontsize',18);
Legend_Font(gca,{'False Positive Rate','True Positive Rate'},{'fontsize',12});
xlabel('Predictor Scores','fontsize',15);
ylabel('Percent %','fontsize',15);
xlim([min(PreditiveScore),max(PreditiveScore)]);
ylim([0 120]);

% Select the bias for separating conditions
ln1 = plot(AX1,[0,0],get(AX1,'YLIM')*1.2,'k','linewidth',2);
ln2 = plot(AX2,[0,0],get(AX2,'YLIM')*1.2,'k','linewidth',2);
while true
    [bias,~,button] = ginput(1);
    if button == 1
        Coefficients.b = bias;
        delete(ln1); ln1 = plot(AX1,[bias,bias],get(AX1,'YLIM')*1.2,'k','linewidth',2);
        delete(ln2); ln2 = plot(AX2,[bias,bias],get(AX2,'YLIM')*1.2,'k','linewidth',2);
        title(AX2,sprintf('Predictor Bias = %.2g | True Positive = %.1f%% | False Positive = %.1f%%',bias,TruePositive(find(bias>Threshold,1))*100,FalsePositive(find(bias>Threshold,1))*100),'fontsize',18);
    else
        break;
    end
end
Coefficients.W1 = W(1);

writeXML([filename,'.xml'],Coefficients);

end

function ret = checkTimePoint( Target, TimePoint )

ret = 0;
for i = 1:2:length(Target)
    if TimePoint > Target(i) && TimePoint < Target(i+1)
        ret = i;
    end
end

end

function h = drawFigure( TimeIndex, Data, Zscore )

h = largeFigure(999, [1280 720]); clf; hold on;
plot(TimeIndex, Data, 'linewidth', 1);
xlabel('Time (s)','fontsize',15);
if Zscore
    ylabel('Normalized Power','fontsize',15);
else
    ylabel('Power','fontsize',15);
end
title('Please Select the Region of Detection','fontsize',18);
xlim([0 max(TimeIndex)]);

end

function W = computeLDA( Data, Label )

ClassA = Data(Label == 1,:);
ClassB = Data(Label == 0,:);

muA = mean(ClassA);
muB = mean(ClassB);
scatterA = cov(ClassA) * (length(ClassA) - 1);
scatterB = cov(ClassB) * (length(ClassB) - 1);

classScatter = scatterA + scatterB;
W = inv(classScatter)*(muA - muB);

end

function writeXML( filename, Coefficients )

fid = fopen(filename,'w+');
fprintf(fid, '<Coefficients>\n');
fprintf(fid, '  <W1>%.9f</W1>\n', Coefficients.W1);
fprintf(fid, '  <W2>%.9f</W2>\n', Coefficients.W2);
fprintf(fid, '  <W3>%.9f</W3>\n', Coefficients.W3);
fprintf(fid, '  <W4>%.9f</W4>\n', Coefficients.W4);
fprintf(fid, '  <b>%.9f</b>\n', Coefficients.b);
fprintf(fid, '  <NormConstB1>%.9f</NormConstB1>\n', Coefficients.NormConstB1);
fprintf(fid, '  <NormConstB2>%.9f</NormConstB2>\n', Coefficients.NormConstB2);
fprintf(fid, '  <NormConstB3>%.9f</NormConstB3>\n', Coefficients.NormConstB3);
fprintf(fid, '  <NormConstB4>%.9f</NormConstB4>\n', Coefficients.NormConstB4);
fprintf(fid, '  <NormConstA1>%d</NormConstA1>\n', Coefficients.NormConstA1);
fprintf(fid, '  <NormConstA2>%d</NormConstA2>\n', Coefficients.NormConstA2);
fprintf(fid, '  <NormConstA3>%d</NormConstA3>\n', Coefficients.NormConstA3);
fprintf(fid, '  <NormConstA4>%d</NormConstA4>\n', Coefficients.NormConstA4);
fprintf(fid, '</Coefficients>');
fclose(fid);

end
