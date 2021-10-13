function [net, XTest, YTest] = mlstm(app, xd, yd)

    [XTrain,XTest,YTrain1,YTest1,YTrain,YTest] = plstm(xd,yd);
    YTrain = categorical(vertcat(YTrain{:}));
    YTest = categorical(vertcat(YTest{:}));
    XTrain = transpose(XTrain);
    XTest = transpose(XTest);
    YTrain = transpose(YTrain);
    YTest = transpose(YTest);

    %%
    X = XTrain(:,1); % an insight to what the typical training data into LSTM looks like
    classes = categories(YTrain); % Maybe plot(scoresA')i.e. transposing before 
    % plotting might display the data better e.g. plot(datasize(:,1))

%     figure(1)
%     for j = 1:numel(classes)
%         label = classes(j);
%         idx = find(YTrain == label)
%         hold on
%         plot(idx,X(idx))
%     end
%     hold off
%     xlabel("Points number")
%     ylabel("Radius")
%     title("Training Sequence 1, Feature 1")
%     legend(classes,'Location','northwest')
    
   figure(1)
    plot(X)
    xlabel("Points number")
    ylabel("Radius")
    title("Visualize one training sequence")
    
    numFeatures = size(XTrain,1);
    numHiddenUnits = 200;
    numClasses = 2;
    maxEpochs = app.toolbox.get_tpps_epochs();

    
    % Making LSTM networks deeper by inserting extra LSTM layers with 
    %the output mode 'sequence' before the LSTM layer. A dropout layer is 
    % used to prevent overfitting, 
  
    layers = [ ...
        sequenceInputLayer(numFeatures)
        lstmLayer(numHiddenUnits,'OutputMode','sequence')
        dropoutLayer(0.2)
        lstmLayer(numHiddenUnits,'OutputMode','sequence')
        dropoutLayer(0.2) 
        fullyConnectedLayer(numClasses)
        softmaxLayer
        classificationLayer];

    % miniBatchSize=32;
   
    options = trainingOptions('adam', ...
        'MaxEpochs',maxEpochs, ...
        'GradientThreshold',2, ...
        'Verbose',0, ...
        'InitialLearnRate',0.0001,...
        'ValidationData',{XTest YTest},...
        'Plots','training-progress');
    %         'ValidationFrequency',...

    net = trainNetwork(XTrain,YTrain,layers,options);

    
end
