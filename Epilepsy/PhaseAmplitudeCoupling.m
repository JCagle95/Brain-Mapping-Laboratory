%% Phase Amplitude Coupling

PhaseFreqVector=4:2:45;
AmpFreqVector=4:4:100;
surrogates=1;
numsurrogates=200;

files = dir('*.mat');
tic;
for i = 1:length(files)
    load(files(i).name);
    Comodulogram = cell(1,size(dataStruct.data,2));
    pComodulogram = cell(1,size(dataStruct.data,2));
    zComodulogram = cell(1,size(dataStruct.data,2));
    for Channel = 1:size(dataStruct.data,2);
        skip=floor(rand(numsurrogates,1).*length(dataStruct.data(:,Channel)));
        bad_times=[1];
        [Comodulogram{Channel},pComodulogram{Channel},zComodulogram{Channel},Phase_PWR,Phase_dir,AmpFreqTransformed,PhaseFreqTransformed] = pac_art_reject_surr_2part(dataStruct.data(:,Channel)',dataStruct.data(:,Channel)',dataStruct.iEEGsamplingRate,PhaseFreqVector,AmpFreqVector,bad_times,skip);
    end
    save([files(i).name(1:end-4),'_PAC.mat'],'Comodulogram','pComodulogram','zComodulogram');
    fprintf('Completed Item: %d/%d - Elapsed Time %.2f\n',i,length(files),toc/60);
end

%% Plots

Preictal = dir('*1_PAC.mat');
Interictal = dir('*0_PAC.mat');

PhaseFreqVector=4:2:45;
AmpFreqVector=4:4:100;

Preictal_All = cell(1,16);
Interictal_All = cell(1,16);
for Channel = 1:16
    Preictal_All{Channel} = zeros(length(PhaseFreqVector), length(AmpFreqVector), length(Preictal));
    Interictal_All{Channel} = zeros(length(PhaseFreqVector), length(AmpFreqVector), length(Interictal));
    for i = 1:length(Preictal)
        PAC_Data = load(Preictal(i).name);
        Temp = PAC_Data.Comodulogram{Channel};
        Temp(PAC_Data.zComodulogram{Channel} < 4.5) = 0;
        Preictal_All{Channel}(:,:,i) = Temp;
    end
    for i = 1:length(Interictal)
        PAC_Data = load(Interictal(i).name);
        Temp = PAC_Data.Comodulogram{Channel};
        Temp(PAC_Data.zComodulogram{Channel} < 4.5) = 0;
        Interictal_All{Channel}(:,:,i) = Temp;
    end
end

largeFigure(1805,[1600 900]); clf; hold on;
for Channel = 1:16
    subplot(4,4,Channel); cla;
    surf(PhaseFreqVector, AmpFreqVector, double(mean(Preictal_All{Channel},3)'));
    view(2); shading interp; axis tight;
    addColorbar('Power');
end

largeFigure(1806,[1600 900]); clf; hold on;
for Channel = 1:16
    subplot(4,4,Channel); cla;
    surf(PhaseFreqVector, AmpFreqVector, double(mean(Interictal_All{Channel},3)'));
    view(2); shading interp; axis tight;
    addColorbar('Power');
end

%% Individual Analysis
Channel = 8;
for i = 1:length(Preictal)
    largeFigure(0,[800 600]);
    PAC_Data = load(Preictal(i).name);
    load([Preictal(i).name(1:end-8),'.mat']);
    Temp = PAC_Data.Comodulogram{Channel};
    Temp(PAC_Data.zComodulogram{Channel} < 4.5) = 0;
    
    surf(PhaseFreqVector, AmpFreqVector, double(Temp'));
    view(2); shading interp; axis tight;
    title(sprintf('%d',dataStruct.sequence));
    addColorbar('Power');
end

Channel = 8;
for i = 1:length(Interictal)
    largeFigure(0,[800 600]);
    PAC_Data = load(Interictal(i).name);
    Temp = PAC_Data.Comodulogram{Channel};
    Temp(PAC_Data.zComodulogram{Channel} < 4.5) = 0;
    
    surf(PhaseFreqVector, AmpFreqVector, double(Temp'));
    view(2); shading interp; axis tight;
    addColorbar('Power');
end