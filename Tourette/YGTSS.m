%% Scoring
NUM = xlsread('YGTSS.xlsx','Baseline');
SIMPLE_MOTOR_TIC.Baseline = sum(NUM(1:11,1));
COMPLEX_MOTOR_TIC.Baseline = sum(NUM(14:31,1));
PHONIC_TIC.Baseline = sum(NUM(34,1));
COMPLEX_PHONIC_TIC.Baseline = sum(NUM(38:44,1));

YGTSS.Baseline.MotorTic = sum(NUM(46:3:58,1));
YGTSS.Baseline.PhonicTic = sum(NUM(46:3:58,2));
YGTSS.Baseline.Impairment = NUM(60,1);

YGTSS.Baseline.Total = YGTSS.Baseline.MotorTic + YGTSS.Baseline.PhonicTic + YGTSS.Baseline.Impairment;

NUM = xlsread('YGTSS.xlsx','Month 1 Pre');
SIMPLE_MOTOR_TIC.M1A = sum(NUM(1:11,1));
COMPLEX_MOTOR_TIC.M1A = sum(NUM(14:31,1));
PHONIC_TIC.M1A = sum(NUM(34,1));
COMPLEX_PHONIC_TIC.M1A = sum(NUM(38:44,1));

YGTSS.M1A.MotorTic = sum(NUM(46:3:58,1));
YGTSS.M1A.PhonicTic = sum(NUM(46:3:58,2));
YGTSS.M1A.Impairment = NUM(60,1);

YGTSS.M1A.Total = YGTSS.M1A.MotorTic + YGTSS.M1A.PhonicTic + YGTSS.M1A.Impairment;

NUM = xlsread('YGTSS.xlsx','Month 1 Post');
SIMPLE_MOTOR_TIC.M1B = sum(NUM(1:11,1));
COMPLEX_MOTOR_TIC.M1B = sum(NUM(14:31,1));
PHONIC_TIC.M1B = sum(NUM(34,1));
COMPLEX_PHONIC_TIC.M1B = sum(NUM(38:44,1));

YGTSS.M1B.MotorTic = sum(NUM(46:3:58,1));
YGTSS.M1B.PhonicTic = sum(NUM(46:3:58,2));
YGTSS.M1B.Impairment = NUM(60,1);

YGTSS.M1B.Total = YGTSS.M1B.MotorTic + YGTSS.M1B.PhonicTic + YGTSS.M1B.Impairment;

NUM = xlsread('YGTSS.xlsx','Month 2 Pre');
SIMPLE_MOTOR_TIC.M2A = sum(NUM(1:11,1));
COMPLEX_MOTOR_TIC.M2A = sum(NUM(14:31,1));
PHONIC_TIC.M2A = sum(NUM(34,1));
COMPLEX_PHONIC_TIC.M2A = sum(NUM(38:44,1));

YGTSS.M2A.MotorTic = sum(NUM(46:3:58,1));
YGTSS.M2A.PhonicTic = sum(NUM(46:3:58,2));
YGTSS.M2A.Impairment = NUM(60,1);

YGTSS.M2A.Total = YGTSS.M2A.MotorTic + YGTSS.M2A.PhonicTic + YGTSS.M2A.Impairment;

NUM = xlsread('YGTSS.xlsx','Month 2 Post');
SIMPLE_MOTOR_TIC.M2B = sum(NUM(1:11,1));
COMPLEX_MOTOR_TIC.M2B = sum(NUM(14:31,1));
PHONIC_TIC.M2B = sum(NUM(34,1));
COMPLEX_PHONIC_TIC.M2B = sum(NUM(38:44,1));

YGTSS.M2B.MotorTic = sum(NUM(46:3:58,1));
YGTSS.M2B.PhonicTic = sum(NUM(46:3:58,2));
YGTSS.M2B.Impairment = NUM(60,1);

YGTSS.M2B.Total = YGTSS.M2B.MotorTic + YGTSS.M2B.PhonicTic + YGTSS.M2B.Impairment;

NUM = xlsread('YGTSS.xlsx','Month 3 Pre');
SIMPLE_MOTOR_TIC.M3A = sum(NUM(1:11,1));
COMPLEX_MOTOR_TIC.M3A = sum(NUM(14:31,1));
PHONIC_TIC.M3A = sum(NUM(34,1));
COMPLEX_PHONIC_TIC.M3A = sum(NUM(38:44,1));

YGTSS.M3A.MotorTic = sum(NUM(46:3:58,1));
YGTSS.M3A.PhonicTic = sum(NUM(46:3:58,2));
YGTSS.M3A.Impairment = NUM(60,1);

YGTSS.M3A.Total = YGTSS.M3A.MotorTic + YGTSS.M3A.PhonicTic + YGTSS.M3A.Impairment;

NUM = xlsread('YGTSS.xlsx','Month 3 Post');
SIMPLE_MOTOR_TIC.M3B = sum(NUM(1:11,1));
COMPLEX_MOTOR_TIC.M3B = sum(NUM(14:31,1));
PHONIC_TIC.M3B = sum(NUM(34,1));
COMPLEX_PHONIC_TIC.M3B = sum(NUM(38:44,1));

YGTSS.M3B.MotorTic = sum(NUM(46:3:58,1));
YGTSS.M3B.PhonicTic = sum(NUM(46:3:58,2));
YGTSS.M3B.Impairment = NUM(60,1);

YGTSS.M3B.Total = YGTSS.M3B.MotorTic + YGTSS.M3B.PhonicTic + YGTSS.M3B.Impairment;

NUM = xlsread('YGTSS.xlsx','Month 4 Pre');
SIMPLE_MOTOR_TIC.M4A = sum(NUM(1:11,1));
COMPLEX_MOTOR_TIC.M4A = sum(NUM(14:31,1));
PHONIC_TIC.M4A = sum(NUM(34,1));
COMPLEX_PHONIC_TIC.M4A = sum(NUM(38:44,1));

YGTSS.M4A.MotorTic = sum(NUM(46:3:58,1));
YGTSS.M4A.PhonicTic = sum(NUM(46:3:58,2));
YGTSS.M4A.Impairment = NUM(60,1);

YGTSS.M4A.Total = YGTSS.M4A.MotorTic + YGTSS.M4A.PhonicTic + YGTSS.M4A.Impairment;

NUM = xlsread('YGTSS.xlsx','Month 4 Post');
SIMPLE_MOTOR_TIC.M4B = sum(NUM(1:11,1));
COMPLEX_MOTOR_TIC.M4B = sum(NUM(14:31,1));
PHONIC_TIC.M4B = sum(NUM(34,1));
COMPLEX_PHONIC_TIC.M4B = sum(NUM(38:44,1));

YGTSS.M4B.MotorTic = sum(NUM(46:3:58,1));
YGTSS.M4B.PhonicTic = sum(NUM(46:3:58,2));
YGTSS.M4B.Impairment = NUM(60,1);

YGTSS.M4B.Total = YGTSS.M4B.MotorTic + YGTSS.M4B.PhonicTic + YGTSS.M4B.Impairment;

NUM = xlsread('YGTSS.xlsx','Month 5 Pre');
SIMPLE_MOTOR_TIC.M5A = sum(NUM(1:11,1));
COMPLEX_MOTOR_TIC.M5A = sum(NUM(14:31,1));
PHONIC_TIC.M5A = sum(NUM(34,1));
COMPLEX_PHONIC_TIC.M5A = sum(NUM(38:44,1));

YGTSS.M5A.MotorTic = sum(NUM(46:3:58,1));
YGTSS.M5A.PhonicTic = sum(NUM(46:3:58,2));
YGTSS.M5A.Impairment = NUM(60,1);

YGTSS.M5A.Total = YGTSS.M5A.MotorTic + YGTSS.M5A.PhonicTic + YGTSS.M5A.Impairment;

NUM = xlsread('YGTSS.xlsx','Month 5 Post');
SIMPLE_MOTOR_TIC.M5B = sum(NUM(1:11,1));
COMPLEX_MOTOR_TIC.M5B = sum(NUM(14:31,1));
PHONIC_TIC.M5B = sum(NUM(34,1));
COMPLEX_PHONIC_TIC.M5B = sum(NUM(38:44,1));

YGTSS.M5B.MotorTic = sum(NUM(46:3:58,1));
YGTSS.M5B.PhonicTic = sum(NUM(46:3:58,2));
YGTSS.M5B.Impairment = NUM(60,1);

YGTSS.M5B.Total = YGTSS.M5B.MotorTic + YGTSS.M5B.PhonicTic + YGTSS.M5B.Impairment;

%% Scores in Time Series
subfields = fields(YGTSS);
Scores = zeros(size(subfields));
for i = 1:length(subfields)
    Scores(i) = YGTSS.(subfields{i}).Total;
end

largeFigure(50, [1500 900]); clf; hold on; box on; grid on;
plot(1:length(Scores), Scores, 'g', 'linewidth', 3);
S1 = scatter(1, Scores(1), 150, 'k', 'filled');
S2 = scatter(2:2:length(Scores), Scores(2:2:end), 150, 'b', 'filled');
S3 = scatter(3:2:length(Scores), Scores(3:2:end), 150, 'r', 'filled');
legendFont([S1, S2, S3], {'Baseline', 'Visit', 'Post-programming'}, {'fontsize',18});
axis([0 length(Scores)+1 20 90]);

set(gca,'XTick',2.5:2:length(Scores));
set(gca,'XTickLabel', {'Month 1', 'Month 2', 'Month 3', 'Month 4', 'Month 5'});
set(gca, 'fontsize',15);

title('TS03 YGTSS Scores', 'fontsize', 20);
print('YGTSS Scores','-dpng','-r500');

%% Scores in Time Series
subfields = fields(YGTSS);
Scores = zeros(size(subfields));
for i = 1:length(subfields)
    Scores(i) = YGTSS.(subfields{i}).MotorTic;
end

largeFigure(50, [1500 900]); clf; hold on; box on; grid on;
plot(1:length(Scores), Scores, 'g', 'linewidth', 3);
S1 = scatter(1, Scores(1), 150, 'k', 'filled');
S2 = scatter(2:2:length(Scores), Scores(2:2:end), 150, 'b', 'filled');
S3 = scatter(3:2:length(Scores), Scores(3:2:end), 150, 'r', 'filled');
legendFont([S1, S2, S3], {'Baseline', 'Visit', 'Post-programming'}, {'fontsize',18});
axis([0 length(Scores)+1 5 25]);

set(gca,'XTick',2.5:2:length(Scores));
set(gca,'XTickLabel', {'Month 1', 'Month 2', 'Month 3', 'Month 4', 'Month 5'});
set(gca, 'fontsize',15);

title('TS03 YGTSS Motor Scores', 'fontsize', 20);
print('YGTSS Scores - Motor','-dpng','-r500');

%% Scores in Time Series
subfields = fields(YGTSS);
Scores = zeros(size(subfields));
for i = 1:length(subfields)
    Scores(i) = YGTSS.(subfields{i}).PhonicTic;
end

largeFigure(50, [1500 900]); clf; hold on; box on; grid on;
plot(1:length(Scores), Scores, 'g', 'linewidth', 3);
S1 = scatter(1, Scores(1), 150, 'k', 'filled');
S2 = scatter(2:2:length(Scores), Scores(2:2:end), 150, 'b', 'filled');
S3 = scatter(3:2:length(Scores), Scores(3:2:end), 150, 'r', 'filled');
legendFont([S1, S2, S3], {'Baseline', 'Visit', 'Post-programming'}, {'fontsize',18});
axis([0 length(Scores)+1 5 25]);

set(gca,'XTick',2.5:2:length(Scores));
set(gca,'XTickLabel', {'Month 1', 'Month 2', 'Month 3', 'Month 4', 'Month 5'});
set(gca, 'fontsize',15);

title('TS03 YGTSS Phonic Scores', 'fontsize', 20);
print('YGTSS Scores - Phonic','-dpng','-r500');