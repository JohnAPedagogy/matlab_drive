%% get data
load lstm_data1.mat
load lstm_classes1.mat

%% attempt ftplot
pspectrum(xd(1,:))

%% attempt ftplots
for i = 1:length(xd)
    x1 = xd(i,:);
    pspectrum(x1, 100, 'spectrogram');
end
 
v = pad(num2str(i),3,'left','0');
        fig=sprintf('MATLAB Drive/Model_process/LSTM/Pspectrum%s%s.png', v);
        saveCurrentFigure(fig,600);
        
%%
% fileFolder = fullfile(matlabroot,'toolbox','images','imdata');
% dirOutput = dir(fullfile(fileFolder,'AT3_1m4_*.tif'));
% fileNames = string({dirOutput.name});
% dir('/MATLAB Drive/Model_process/LSTM/FT_Plot')

