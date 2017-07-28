%% Plots of Motion
clear; clc; close all;
TimeIndex{1} = [3.46,18.01;25,41.1;49.6,63.6;70.1,86.3;93.3,105.1;127.4,143.8;153.2,169.1;176.5,188.9];
TimeIndex{2} = [5.39,16.6;27.8,41.3;47.5,59.3;66.9,83.4;92.3,105.4;111.3,121.2;];
TimeIndex{3} = [10.67 20.45;37.07 51.71;60.49 73.39;82.16 94.43;106.3 117.5;123.7 137.2;151.6 163.2;174.3 184.3];
TimeIndex{4} = [4.76,17;24.32,35.9];
TimeIndex{5} = [5.9,13;23,37.1;47.2,54.3;60,73.2;79.5,89.6;96.6,107.9;114.6,126.5;131.8,142;];
TimeIndex{6} = [2.1,14.2;17,30.7;34.2,46.2;50.9,62.6;67.4,79;82.1,93.7;99.6,115.9;121.1,131.6;139.2,149.2;156.5,167.4];
StartPoint = [120 90 70 70 130 110];

files = dir('*Volitional.mat');

for fid = 1:length(files)
    load(files(fid).name);
    Volitional_Task = TimeIndex{fid};
    FS = Left_DBS.SamplingRate;

    Time_Left = Left_DBS.TimeRange(Left_DBS.TimeRange-DBS_Bias(1) > StartPoint(fid));
    Time_Left = Time_Left - Time_Left(1);
    Time_Right = Right_DBS.TimeRange(Right_DBS.TimeRange-DBS_Bias(2) > StartPoint(fid));
    Time_Right = Time_Right - Time_Right(1);
    LeftLFP = Left_DBS.data(Left_DBS.TimeRange-DBS_Bias(1) > StartPoint(fid),[3,1]);
    RightLFP = Right_DBS.data(Right_DBS.TimeRange-DBS_Bias(2) > StartPoint(fid),[3,1]);

    % Filter and Processing
    [bH,aH] = cheby2(6,20,1*2/FS,'high');
    [bL,aL] = cheby2(6,50,80*2/FS,'low');
    for i = 1:2
        LeftLFP(:,i) = filtfilt(bH,aH,LeftLFP(:,i));
        RightLFP(:,i) = filtfilt(bH,aH,RightLFP(:,i));
        %LeftLFP(:,i) = filtfilt(bL,aL,LeftLFP(:,i));
        %RightLFP(:,i) = filtfilt(bL,aL,RightLFP(:,i));
        LeftLFP(:,i) = zscore(LeftLFP(:,i));
        RightLFP(:,i) = zscore(RightLFP(:,i));
    end


    Epochs = cell(size(Volitional_Task,1),2);
    Rest = cell(size(Volitional_Task,1),2);
    for n = 1:size(Volitional_Task,1)
        Epochs{n,1} = LeftLFP(Time_Left > Volitional_Task(n,1) & Time_Left < Volitional_Task(n,2),:);
        Epochs{n,2} = RightLFP(Time_Right > Volitional_Task(n,1) & Time_Right < Volitional_Task(n,2),:);
        if n < size(Volitional_Task,1)
            Rest{n,1} = LeftLFP(Time_Left > Volitional_Task(n,2) & Time_Left < Volitional_Task(n+1,1),:);
            Rest{n,2} = RightLFP(Time_Right > Volitional_Task(n,2) & Time_Right < Volitional_Task(n+1,1),:);
        else
            Rest{n,1} = LeftLFP(Time_Left > Volitional_Task(n,2),:);
            Rest{n,2} = RightLFP(Time_Right > Volitional_Task(n,2),:);
        end
    end

    Fxx = 0:0.5:100;
    MotionPSD = cell(2,1);
    Beta = zeros(size(Volitional_Task,1),1);
    RestPSD = cell(2,1);
    MotionPSD{1} = zeros(size(Volitional_Task,1),length(Fxx));
    RestPSD{1} = zeros(size(Volitional_Task,1),length(Fxx));
    for n = 1:size(Volitional_Task,1)
        MotionPSD{1}(n,:) = pwelch(Epochs{n,1}(:,1),512,256,Fxx,FS);
        RestPSD{1}(n,:) = pwelch(Rest{n,1}(:,1),512,256,Fxx,FS);
        MotionPSD{2}(n,:) = pwelch(Epochs{n,1}(:,2),512,256,Fxx,FS);
        RestPSD{2}(n,:) = pwelch(Rest{n,1}(:,2),512,256,Fxx,FS);
        Beta(n) = mean(MotionPSD{1}(n,Fxx > 17.5 & Fxx < 25))/mean(RestPSD{1}(n,Fxx > 17.5 & Fxx < 25));
    end

    largeFigure(5,[1600 600]); clf; 
    subplot(1,2,1); cla; hold on; box on;
    H1 = shadedErrorBar(Fxx,mean(10*log10(MotionPSD{1}),1),std(10*log10(MotionPSD{1}),[],1),{'r','linewidth',2},0.25);
    H2 = shadedErrorBar(Fxx,mean(10*log10(RestPSD{1}),1),std(10*log10(RestPSD{1}),[],1),{'b','linewidth',2},0.25);
    legendFont([H1.mainLine H2.mainLine],{'Volitional','Baseline'},{'fontsize',13});
    title('Left Hemisphere Cortex','fontsize',15);
    xlabel('Frequency (Hz)','fontsize',13);
    ylabel('Power (dB)','fontsize',13);
    
    subplot(1,2,2); cla; hold on; box on;
    H1 = shadedErrorBar(Fxx,mean(10*log10(MotionPSD{2}),1),std(10*log10(MotionPSD{2}),[],1),{'r','linewidth',2},0.25);
    H2 = shadedErrorBar(Fxx,mean(10*log10(RestPSD{2}),1),std(10*log10(RestPSD{2}),[],1),{'b','linewidth',2},0.25);
    legendFont([H1.mainLine H2.mainLine],{'Volitional','Baseline'},{'fontsize',13});
    title('Left Hemisphere Thalamus','fontsize',15);
    xlabel('Frequency (Hz)','fontsize',13);
    ylabel('Power (dB)','fontsize',13);
    print([files(fid).name(11:29),'_Power'],'-dpng','-r500');

    Order = 60;
    Realization = 10;
    Granger_Frequency = 0:0.001:1;
    Volitional_Coherence = zeros(size(Volitional_Task,1),length(Granger_Frequency));
    Volitional_Fx2y = zeros(size(Volitional_Task,1),length(Granger_Frequency));
    Volitional_Fy2x = zeros(size(Volitional_Task,1),length(Granger_Frequency));
    Volitional_Fxy = zeros(size(Volitional_Task,1),length(Granger_Frequency));
    Rest_Coherence = zeros(size(Volitional_Task,1),length(Granger_Frequency));
    Rest_Fx2y = zeros(size(Volitional_Task,1),length(Granger_Frequency));
    Rest_Fy2x = zeros(size(Volitional_Task,1),length(Granger_Frequency));
    Rest_Fxy = zeros(size(Volitional_Task,1),length(Granger_Frequency));
    for n = 1:size(Volitional_Task,1)
        [~,~,~,Volitional_Coherence(n,:),Volitional_Fx2y(n,:),Volitional_Fy2x(n,:),Volitional_Fxy(n,:)] = pwcausalr(Epochs{n,1}',Realization,floor(length(Epochs{n,1})/Realization),Order,1,Granger_Frequency);
        [~,~,~,Rest_Coherence(n,:),Rest_Fx2y(n,:),Rest_Fy2x(n,:),Rest_Fxy(n,:)] = pwcausalr(Rest{n,1}',Realization,floor(length(Rest{n,1})/Realization),Order,1,Granger_Frequency);
    end

    largeFigure(6,[1280 900]); clf;
    subplot(3,1,1); cla; hold on; box on;
    H1 = shadedErrorBar(Granger_Frequency*FS,mean(Volitional_Coherence,1),std(Volitional_Coherence,[],1)/sqrt(size(Volitional_Task,1)),{'r','linewidth',2},0.25);
    H2 = shadedErrorBar(Granger_Frequency*FS,mean(Rest_Coherence,1),std(Rest_Coherence,[],1)/sqrt(size(Volitional_Task,1)),{'b','linewidth',2},0.25);
    axis([0 100 0 0.2]);
    legendFont([H1.mainLine H2.mainLine],{'Volitional','Baseline'},{'fontsize',13});
    xlabel('Frequency (Hz)','fontsize',13);
    ylabel('Coherence','fontsize',13);
    title('Coherence M1 - CM thalamus','fontsize',15);

    subplot(3,1,2); cla; hold on; box on;
    H1 = shadedErrorBar(Granger_Frequency*FS,mean(Volitional_Fx2y,1),std(Volitional_Fx2y,[],1)/sqrt(size(Volitional_Task,1)),{'r','linewidth',2},0.25);
    H2 = shadedErrorBar(Granger_Frequency*FS,mean(Rest_Fx2y,1),std(Rest_Fx2y,[],1)/sqrt(size(Volitional_Task,1)),{'b','linewidth',2},0.25);
    axis([0 100 0 0.2]);
    legendFont([H1.mainLine H2.mainLine],{'Volitional','Baseline'},{'fontsize',13});
    xlabel('Frequency (Hz)','fontsize',13);
    ylabel('Coherence','fontsize',13);
    title('Causality M1 -> CM thalamus','fontsize',15);

    subplot(3,1,3); cla; hold on; box on;
    H1 = shadedErrorBar(Granger_Frequency*FS,mean(Volitional_Fy2x,1),std(Volitional_Fy2x,[],1)/sqrt(size(Volitional_Task,1)),{'r','linewidth',2},0.25);
    H2 = shadedErrorBar(Granger_Frequency*FS,mean(Rest_Fy2x,1),std(Rest_Fy2x,[],1)/sqrt(size(Volitional_Task,1)),{'b','linewidth',2},0.25);
    axis([0 100 0 0.2]);
    legendFont([H1.mainLine H2.mainLine],{'Volitional','Baseline'},{'fontsize',13});
    xlabel('Frequency (Hz)','fontsize',13);
    ylabel('Coherence','fontsize',13);
    title('Causality M1 <- CM thalamus','fontsize',15);

    largeFigure(7,[800 600]); clf; hold on;
    H1 = bar(0.9,mean(trapz(Granger_Frequency,Volitional_Fx2y,2)),0.2,'r');
    bar(1.9,mean(trapz(Granger_Frequency,Volitional_Fy2x,2)),0.2,'r');
    bar(2.9,mean(trapz(Granger_Frequency,Volitional_Fxy,2)),0.2,'r');
    errorbar(0.9,mean(trapz(Granger_Frequency,Volitional_Fx2y,2)),std(trapz(Granger_Frequency,Volitional_Fx2y,2),[],1)/sqrt(size(Volitional_Task,1)),'k','linewidth',2);
    errorbar(1.9,mean(trapz(Granger_Frequency,Volitional_Fy2x,2)),std(trapz(Granger_Frequency,Volitional_Fy2x,2),[],1)/sqrt(size(Volitional_Task,1)),'k','linewidth',2);
    errorbar(2.9,mean(trapz(Granger_Frequency,Volitional_Fxy,2)),std(trapz(Granger_Frequency,Volitional_Fxy,2),[],1)/sqrt(size(Volitional_Task,1)),'k','linewidth',2);
    H2 = bar(1.1,mean(trapz(Granger_Frequency,Rest_Fx2y,2)),0.2,'b');
    bar(2.1,mean(trapz(Granger_Frequency,Rest_Fy2x,2)),0.2,'b');
    bar(3.1,mean(trapz(Granger_Frequency,Rest_Fxy,2)),0.2,'b');
    errorbar(1.1,mean(trapz(Granger_Frequency,Rest_Fx2y,2)),std(trapz(Granger_Frequency,Rest_Fx2y,2),[],1)/sqrt(size(Volitional_Task,1)),'k','linewidth',2);
    errorbar(2.1,mean(trapz(Granger_Frequency,Rest_Fy2x,2)),std(trapz(Granger_Frequency,Rest_Fy2x,2),[],1)/sqrt(size(Volitional_Task,1)),'k','linewidth',2);
    errorbar(3.1,mean(trapz(Granger_Frequency,Rest_Fxy,2)),std(trapz(Granger_Frequency,Rest_Fxy,2),[],1)/sqrt(size(Volitional_Task,1)),'k','linewidth',2);

    set(gca,'XTick',1:3,'XTickLabel',{'Cortex to Thalamus','Thalamus to Cortex','Instantaneous Granger'},'fontsize',13);
    title('Granger Causality (Left Hemisphere)','fontsize',18);
    legendFont([H1 H2],{'Movement','Resting'},{'fontsize',15});
    
    largeFigure(8,[800 600]); clf;
    scatter(trapz(Granger_Frequency,Rest_Fx2y,2),Beta,'filled');
    
    save([files(fid).name(11:29),'_Granger.mat'],'Volitional_Coherence','Volitional_Fx2y','Volitional_Fxy','Volitional_Fy2x','Rest_Coherence','Rest_Fx2y','Rest_Fxy','Rest_Fy2x','Beta','Granger_Frequency');
end