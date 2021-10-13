function arr = tabledataread() 
    Files=dir('C:\Users\Ebube\MATLAB Drive\Model_process\LSTM\LSTM meeting\LSTMTraining\*.mat');
    FileNames= [];
    for k=1:length(Files)
       FileNames{k} = join([Files(k).folder "\" Files(k).name],"");
    end
    arr = FileNames;
end