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