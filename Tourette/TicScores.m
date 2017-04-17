%% Scoring for TS01

[~,TS01_Visits] = xlsfinfo('MRVRSFT_TS01.xlsx');
for n = 1:length(TS01_Visits)
    NUM = xlsread('MRVRSFT_TS01.xlsx',TS01_Visits{n});
    TS01.Count(n) = NUM(1);
    TS01.MotorFreq(n) = NUM(2);
    TS01.PhonicFreq(n) = NUM(3);
    TS01.MotorServ(n) = NUM(4);
    TS01.PhonicServ(n) = NUM(5);
    TS01.Total(n) = sum(NUM);
    NUM = xlsread('YGTSS_TS01.xlsx',TS01_Visits{n});
    TS01_YGTSS.SIMPLE_MOTOR_TIC(n) = sum(NUM(1:11,1));
    TS01_YGTSS.COMPLEX_MOTOR_TIC(n) = sum(NUM(14:31,1));
    TS01_YGTSS.PHONIC_TIC(n) = sum(NUM(34,1));
    TS01_YGTSS.COMPLEX_PHONIC_TIC(n) = sum(NUM(38:44,1));
    TS01_YGTSS.Impairment(n) = NUM(60,1);
    TS01_YGTSS.Total(n) = sum(NUM(46:3:58,1))+sum(NUM(46:3:58,2))+NUM(60,1);
end

largeFigure(60, [1500 600]); clf; hold on; box on; 
yyaxis left;
plot(1:length(TS01.Total([1,2:2:end])), TS01.Total([1,2:2:end]), 'b', 'linewidth', 3);
scatter(1, TS01.Total(1), 150, 'ks', 'filled');
scatter(2:length(TS01.Total([1,2:2:end])), TS01.Total(2:2:end), 150, 'bs', 'filled');
axis([0 11 0 20]);
set(gca,'XTick',1:length(TS01.Total([1,2:2:end])), 'YTick', 0:4:20);

yyaxis right;
plot(1:length(TS01_YGTSS.Total([1,2:2:end])), TS01_YGTSS.Total([1,2:2:end]), 'r', 'linewidth', 3);
scatter(1, TS01_YGTSS.Total(1), 150, 'ks', 'filled');
scatter(2:length(TS01_YGTSS.Total([1,2:2:end])), TS01_YGTSS.Total(2:2:end), 150, 'rs', 'filled');
axis([0 11 0 100]);
set(gca,'XTick',1:length(TS01.Total([1,2:2:end])), 'YTick', 0:20:100);

set(gca,'XTickLabel', {''});
set(gca, 'fontsize',13);
title('TS01 Modified Rush Videotape Rating Score for Tic', 'fontsize', 20);
%print('TS01 MRVRSFT Scores','-dpng','-r500');
print('TS01 MRVRSFT Scores','-depsc','-r500');

%% Scoring for TS02

[~,TS02_Visits] = xlsfinfo('MRVRSFT_TS02.xlsx');
count = 1;
for n = 1:length(TS02_Visits)
    NUM = xlsread('MRVRSFT_TS02.xlsx',TS02_Visits{n});
    if strcmp(TS02_Visits{n}, 'Month 6 Blind OFF')
        TS02.BlindOFF = sum(NUM);
    else
        NUM = xlsread('MRVRSFT_TS02.xlsx',TS02_Visits{n});
        TS02.Count(count) = NUM(1);
        TS02.MotorFreq(count) = NUM(2);
        TS02.PhonicFreq(count) = NUM(3);
        TS02.MotorServ(count) = NUM(4);
        TS02.PhonicServ(count) = NUM(5);
        TS02.Total(count) = sum(NUM);
        NUM = xlsread('YGTSS_TS02.xlsx',TS02_Visits{n});
        TS02_YGTSS.SIMPLE_MOTOR_TIC(count) = sum(NUM(1:11,1));
        TS02_YGTSS.COMPLEX_MOTOR_TIC(count) = sum(NUM(14:31,1));
        TS02_YGTSS.PHONIC_TIC(count) = sum(NUM(34,1));
        TS02_YGTSS.COMPLEX_PHONIC_TIC(count) = sum(NUM(38:44,1));
        TS02_YGTSS.Impairment(count) = NUM(60,1);
        TS02_YGTSS.Total(count) = sum(NUM(46:3:58,1))+sum(NUM(46:3:58,2))+NUM(60,1);
        count = count+1;
    end
end

largeFigure(60, [1500 600]); clf; hold on; box on; 
yyaxis left;
plot(1:length(TS02.Total([1,2:2:end])), TS02.Total([1,2:2:end]), 'b', 'linewidth', 3);
scatter(1, TS02.Total(1), 150, 'ks', 'filled');
scatter(2:length(TS02.Total([1,2:2:end])), TS02.Total(2:2:end), 150, 'bs', 'filled');
axis([0 11 0 20]);
set(gca,'XTick',1:length(TS01.Total([1,2:2:end])), 'YTick', 0:4:20);

yyaxis right;
plot(1:length(TS02_YGTSS.Total([1,2:2:end])), TS02_YGTSS.Total([1,2:2:end]), 'r', 'linewidth', 3);
scatter(1, TS02_YGTSS.Total(1), 150, 'ks', 'filled');
scatter(2:length(TS02_YGTSS.Total([1,2:2:end])), TS02_YGTSS.Total(2:2:end), 150, 'rs', 'filled');
axis([0 11 0 100]);
set(gca,'XTick',1:length(TS01.Total([1,2:2:end])), 'YTick', 0:20:100);

set(gca,'XTickLabel', {''});
set(gca, 'fontsize',13);
title('TS02 Modified Rush Videotape Rating Score for Tic', 'fontsize', 20);
%print('TS02 MRVRSFT Scores','-dpng','-r500');
print('TS02 MRVRSFT Scores','-depsc','-r500');

%% Scoring for TS03

[~,TS03_Visits] = xlsfinfo('MRVRSFT_TS03.xlsx');
count = 1;
for n = 1:length(TS03_Visits)
    NUM = xlsread('MRVRSFT_TS03.xlsx',TS03_Visits{n});
    TS03.Count(count) = NUM(1);
    TS03.MotorFreq(count) = NUM(2);
    TS03.PhonicFreq(count) = NUM(3);
    TS03.MotorServ(count) = NUM(4);
    TS03.PhonicServ(count) = NUM(5);
    TS03.Total(count) = sum(NUM);
    NUM = xlsread('YGTSS_TS03.xlsx',TS03_Visits{n});
    TS03_YGTSS.SIMPLE_MOTOR_TIC(count) = sum(NUM(1:11,1));
    TS03_YGTSS.COMPLEX_MOTOR_TIC(count) = sum(NUM(14:31,1));
    TS03_YGTSS.PHONIC_TIC(count) = sum(NUM(34,1));
    TS03_YGTSS.COMPLEX_PHONIC_TIC(count) = sum(NUM(38:44,1));
    TS03_YGTSS.Impairment(count) = NUM(60,1);
    TS03_YGTSS.Total(count) = sum(NUM(46:3:58,1))+sum(NUM(46:3:58,2))+NUM(60,1);
    count = count+1;
end

largeFigure(60, [1500 600]); clf; hold on; box on; 
yyaxis left;
plot(1:length(TS03.Total([1,2:2:end])), TS03.Total([1,2:2:end]), 'b', 'linewidth', 3);
scatter(1, TS03.Total(1), 150, 'ks', 'filled');
scatter(2:length(TS03.Total([1,2:2:end])), TS03.Total(2:2:end), 150, 'bs', 'filled');
axis([0 11 0 20]);
set(gca,'XTick',1:length(TS03.Total([1,2:2:end])), 'YTick', 0:4:20);

yyaxis right;
plot(1:length(TS03_YGTSS.Total([1,2:2:end])), TS03_YGTSS.Total([1,2:2:end]), 'r', 'linewidth', 3);
scatter(1, TS03_YGTSS.Total(1), 150, 'ks', 'filled');
scatter(2:length(TS03_YGTSS.Total([1,2:2:end])), TS03_YGTSS.Total(2:2:end), 150, 'rs', 'filled');
axis([0 11 0 100]);
set(gca,'XTick',1:length(TS03.Total([1,2:2:end])), 'YTick', 0:20:100);

set(gca,'XTickLabel', {''});
set(gca, 'fontsize',13);
title('TS03 Modified Rush Videotape Rating Score for Tic', 'fontsize', 20);
%print('TS03 MRVRSFT Scores','-dpng','-r500');
print('TS03 MRVRSFT Scores','-depsc','-r500');

%% Plotting
subfields = fields(MRVRSFT);
Count = zeros(size(subfields));
MotorFreq = zeros(size(subfields));
PhonicFreq = zeros(size(subfields));
MotorServ = zeros(size(subfields));
PhonicServ = zeros(size(subfields));
Total = zeros(size(subfields));
for i = 1:length(subfields)
    Count(i) = MRVRSFT.(subfields{i}).Count;
    MotorFreq(i) = MRVRSFT.(subfields{i}).MotorFreq;
    PhonicFreq(i) = MRVRSFT.(subfields{i}).PhonicFreq;
    MotorServ(i) = MRVRSFT.(subfields{i}).MotorServ;
    PhonicServ(i) = MRVRSFT.(subfields{i}).PhonicServ;
    Total(i) = MRVRSFT.(subfields{i}).Total;
end

largeFigure(60, [1500 900]); clf; hold on; box on; 
%{
cmap = hsv(6);
plot(1:length(Count), Count, 'color', cmap(1,:), 'linewidth', 2);
plot(1:length(MotorFreq), MotorFreq, 'color', cmap(2,:), 'linewidth', 2);
plot(1:length(PhonicFreq), PhonicFreq, 'color', cmap(3,:), 'linewidth', 2);
plot(1:length(MotorServ), MotorServ, 'color', cmap(4,:), 'linewidth', 2);
plot(1:length(PhonicServ), PhonicServ, 'color', cmap(5,:), 'linewidth', 2);
plot(1:length(Total), Total, 'color', cmap(6,:), 'linewidth', 2);
%}
plot(1:length(Total), Total, 'g', 'linewidth', 3);
scatter(1, Total(1), 150, 'ks', 'filled');
scatter(2:2:length(Total), Total(2:2:end), 150, 'bs', 'filled');
scatter(3:2:length(Total), Total(3:2:end), 150, 'rs', 'filled');
axis([0 length(Total)+1 0 25]);

set(gca,'XTick',2.5:2:length(Total));
set(gca,'XTickLabel', {'Month 1', 'Month 2', 'Month 3', 'Month 4', 'Month 5'});
set(gca, 'fontsize',15);

title('TS03 MRVRSFT Scores', 'fontsize', 20);
print('MRVRSFT Scores','-dpng','-r500');