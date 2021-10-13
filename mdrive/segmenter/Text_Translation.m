% 1. Load Training Data
% Download the decimal-Roman numeral pairs from "romanNumerals.csv"

%filename = fullfile("romanNumerals.csv");
filename = fullfile("mle.csv");

options = detectImportOptions(filename, ...
    'TextType','string', ...
    'ReadVariableNames',false);
options.VariableNames = ["Source" "Target"];
options.VariableTypes = ["string" "string"];
%% 2

data = readtable(filename,options);

% Split the data into training and test partitions containing 50% of the data each.
idx = randperm(size(data,1),500);
dataTrain = data(idx,:);
dataTest = data;
dataTest(idx,:) = [];

% View some of the decimal-Roman numeral pairs.
head(dataTrain)
%% 3

% Preprocess Data
startToken = "<start>";
stopToken = "<stop>";

strSource = dataTrain{:,1};
documentsSource = transformText(strSource,startToken,stopToken);

% Create a wordEncoding object that maps tokens to a numeric index and vice-versa using a vocabulary.
encSource = wordEncoding(documentsSource);
%% 4

% Using the word encoding, convert the source text data to numeric sequences.
sequencesSource = doc2sequence(encSource, documentsSource,'PaddingDirection','none');

% Convert the target data to sequences using the same steps.
strTarget = dataTrain{:,2};
documentsTarget = transformText(strTarget,startToken,stopToken);
encTarget = wordEncoding(documentsTarget);
sequencesTarget = doc2sequence(encTarget, documentsTarget,'PaddingDirection','none');
%% 5

% Initialize the model parameters. for both the encoder and decoder, specify an embedding dimension of 128, two LSTM layers with 200 hidden units, and dropout layers with random dropout with probability 0.05.
embeddingDimension = 128;
numHiddenUnits = 200;
dropout = 0.05;

% Initialize the weights of the encoding embedding using the Gaussian using the initializeGaussian function which is attached to this example as a supporting file. Specify a mean of 0 and a standard deviation of 0.01. To learn more, see Gaussian Initialization.
inputSize = encSource.NumWords + 1;
sz = [embeddingDimension inputSize];
mu = 0;
sigma = 0.01;
parameters.encoder.emb.Weights = initializeGaussian(sz,mu,sigma);

% Initialize the learnable parameters for the first encoder LSTM operation.
sz = [4*numHiddenUnits embeddingDimension];
numOut = 4*numHiddenUnits;
numIn = embeddingDimension;

parameters.encoder.lstm1.InputWeights = initializeGlorot(sz,numOut,numIn);
parameters.encoder.lstm1.RecurrentWeights = initializeOrthogonal([4*numHiddenUnits numHiddenUnits]);
parameters.encoder.lstm1.Bias = initializeUnitForgetGate(numHiddenUnits);

% Initialize the learnable parameters for the second encoder LSTM operation.
sz = [4*numHiddenUnits numHiddenUnits];
numOut = 4*numHiddenUnits;
numIn = numHiddenUnits;

parameters.encoder.lstm2.InputWeights = initializeGlorot(sz,numOut,numIn);
parameters.encoder.lstm2.RecurrentWeights = initializeOrthogonal([4*numHiddenUnits numHiddenUnits]);
parameters.encoder.lstm2.Bias = initializeUnitForgetGate(numHiddenUnits);

% Initialize the weights of the encoding embedding using the Gaussian using the initializeGaussian function. Specify a mean of 0 and a standard deviation of 0.01.
outputSize = encTarget.NumWords + 1;
sz = [embeddingDimension outputSize];
mu = 0;
sigma = 0.01;
parameters.decoder.emb.Weights = initializeGaussian(sz,mu,sigma);

% Initialize the weights of the attention mechanism using the Glorot initializer using the initializeGlorot function.
sz = [numHiddenUnits numHiddenUnits];
numOut = numHiddenUnits;
numIn = numHiddenUnits;
parameters.decoder.attn.Weights = initializeGlorot(sz,numOut,numIn);


% Initialize the learnable parameters for the first decoder LSTM operation
sz = [4*numHiddenUnits embeddingDimension+numHiddenUnits];
numOut = 4*numHiddenUnits;
numIn = embeddingDimension + numHiddenUnits;

parameters.decoder.lstm1.InputWeights = initializeGlorot(sz,numOut,numIn);
parameters.decoder.lstm1.RecurrentWeights = initializeOrthogonal([4*numHiddenUnits numHiddenUnits]);
parameters.decoder.lstm1.Bias = initializeUnitForgetGate(numHiddenUnits);

% Initialize the learnable parameters for the second decoder LSTM operation
sz = [4*numHiddenUnits numHiddenUnits];
numOut = 4*numHiddenUnits;
numIn = numHiddenUnits;

parameters.decoder.lstm2.InputWeights = initializeGlorot(sz,numOut,numIn);
parameters.decoder.lstm2.RecurrentWeights = initializeOrthogonal([4*numHiddenUnits numHiddenUnits]);
parameters.decoder.lstm2.Bias = initializeUnitForgetGate(numHiddenUnits);

% Initialize the learnable parameters for the decoder fully connected operation
sz = [outputSize 2*numHiddenUnits];
numOut = outputSize;
numIn = 2*numHiddenUnits;

parameters.decoder.fc.Weights = initializeGlorot(sz,numOut,numIn);
parameters.decoder.fc.Bias = initializeZeros([outputSize 1]);

%% 6

% Specify Training Options
% Train with a mini-batch size of 32 for 75 epochs with a learning rate of 0.002.
miniBatchSize = 32;
numEpochs = 75;
learnRate = 0.002;

% Initialize the options from Adam.
gradientDecayFactor = 0.9;
squaredGradientDecayFactor = 0.999;

% Train Model
% Train the model using a custom training loop.
% Sort the sequences by length.
sequenceLengths = cellfun(@(sequence) size(sequence,2), sequencesSource);
[~,idx] = sort(sequenceLengths);
sequencesSource = sequencesSource(idx);
sequencesTarget = sequencesTarget(idx);
%% 7

% Initialize the training progress plot.
figure
lineLossTrain = animatedline('Color',[0.85 0.325 0.098]);
ylim([0 inf])

xlabel("Iteration")
ylabel("Loss")
grid on

% Initialize the values for the adamupdate function.
trailingAvg = [];
trailingAvgSq = [];

% Training the model
numObservations = numel(sequencesSource);
numIterationsPerEpoch = floor(numObservations/miniBatchSize);

iteration = 0;
start = tic;
%% 8

% Loop over epochs.
for epoch = 1:numEpochs
        
    % Loop over mini-batches.
    for i = 1:numIterationsPerEpoch
        iteration = iteration + 1;
        
        % Read mini-batch of data and pad.
        idx = (i-1)*miniBatchSize+1:i*miniBatchSize;
        [X, sequenceLengthsSource] = padSequences(sequencesSource(idx), inputSize);
        [T, sequenceLengthsTarget] = padSequences(sequencesTarget(idx), outputSize);

        % Convert mini-batch of data to dlarray.
        dlX = dlarray(X);
        
        % Compute loss and gradients.
        [gradients, loss] = dlfeval(@modelGradients, parameters, dlX, T, ...
            sequenceLengthsSource, sequenceLengthsTarget, dropout);
        
        % Update parameters using adamupdate.
        [parameters, trailingAvg, trailingAvgSq] = adamupdate(parameters, gradients, trailingAvg, trailingAvgSq, ...
            iteration, learnRate, gradientDecayFactor, squaredGradientDecayFactor);
        
        % Display the training progress.
        D = duration(0,0,toc(start),'Format','hh:mm:ss');
        addpoints(lineLossTrain,iteration,double(gather(loss)))
        title("Epoch: " + epoch + ", Elapsed: " + string(D))
        drawnow
    end
end
%% 9

% Generating Translation
strSource = dataTest{:,1};
strTarget = dataTest{:,2};

%Translate the text using the modelPredictions function.
maxSequenceLength = 10;
delimiter = "";

strTranslated = translateText(parameters,strSource,maxSequenceLength,miniBatchSize, ...
    encSource,encTarget,startToken,stopToken,delimiter);

% Create a table containing the test source text, target text, and translations.
tbl = table;
tbl.Source = strSource;
tbl.Target = strTarget;
tbl.Translated = strTranslated;

% View a random selection of the translations.
idx = randperm(size(dataTest,1),miniBatchSize);
tbl(idx,:)

% Text Transformation Function
% The transformText function preprocesses and tokenizes the input text for translation by splitting the text into characters and adding start and stop tokens. To translate text by splitting the text into words instead of characters, skip the first step.

function documents = transformText(str,startToken,stopToken)

str = strip(replace(str,""," "));
str = startToken + str + stopToken;
documents = tokenizedDocument(str,'CustomTokens',[startToken stopToken]);

end
%% f1

% Sequence Padding Function
% The padSequences function takes a mini-batch of sequences and a padding value and returns padded sequences with the corresponding padding masks.

function [X, sequenceLengths] = padSequences(sequences, paddingValue)

    % Initialize mini-batch with padding.
    numObservations = size(sequences,1);
    sequenceLengths = cellfun(@(x) size(x,2), sequences);
    maxLength = max(sequenceLengths);
    X = repmat(paddingValue, [1 numObservations maxLength]);
    
    % Insert sequences.
    for n = 1:numObservations
        X(1,n,1:sequenceLengths(n)) = sequences{n};
    end

end

% Model Gradients Function (f2)
% The modelGradients function takes the encoder and decoder model parameters, a mini-batch of input data and the padding masks corresponding to the input data, and the dropout probability and returns the gradients of the loss with respect to the learnable parameters in the models and the corresponding loss.

function [gradients, loss] = modelGradients(parameters, dlX, T, ...
    sequenceLengthsSource, sequenceLengthsTarget, dropout)

    % Forward through encoder.
    [dlZ, hiddenState] = modelEncoder(parameters.encoder, dlX, sequenceLengthsSource);
    
    % Decoder Output.
    doTeacherForcing = rand < 0.5;
    sequenceLength = size(T,3);
    dlY = decoderPredictions(parameters.decoder,dlZ,T,hiddenState,dropout,...
         doTeacherForcing,sequenceLength);
    
    % Masked loss.
    dlY = dlY(:,:,1:end-1);
    T = T(:,:,2:end);
    T = onehotencode(T,1,'ClassNames',1:size(dlY,1));
    loss = maskedCrossEntropy(dlY,T,sequenceLengthsTarget-1);
    
    % Update gradients.
    gradients = dlgradient(loss, parameters);
    
    % For plotting, return loss normalized by sequence length.
    loss = extractdata(loss) ./ sequenceLength;

end
 
%% f3
% Encoder Model Function
% The function modelEncoder takes the input data, the model parameters, the optional mask that is used to determine the correct outputs for training and returns the model output and the LSTM hidden state.
% If sequenceLengths is empty, then the function does not mask the output. Specify and empty value for sequenceLengths when using the modelEncoder function for prediction.

function [dlZ, hiddenState] = modelEncoder(parametersEncoder, dlX, sequenceLengths)

    % Embedding.
    weights = parametersEncoder.emb.Weights;
    dlZ = embed(dlX,weights,'DataFormat','CBT');
    
    % LSTM 1.
    inputWeights = parametersEncoder.lstm1.InputWeights;
    recurrentWeights = parametersEncoder.lstm1.RecurrentWeights;
    bias = parametersEncoder.lstm1.Bias;
    
    numHiddenUnits = size(recurrentWeights, 2);
    initialHiddenState = dlarray(zeros([numHiddenUnits 1]));
    initialCellState = dlarray(zeros([numHiddenUnits 1]));
    
    dlZ = lstm(dlZ, initialHiddenState, initialCellState, inputWeights, ...
        recurrentWeights, bias, 'DataFormat', 'CBT');
    
    % LSTM 2.
    inputWeights = parametersEncoder.lstm2.InputWeights;
    recurrentWeights = parametersEncoder.lstm2.RecurrentWeights;
    bias = parametersEncoder.lstm2.Bias;
    
    [dlZ, hiddenState] = lstm(dlZ,initialHiddenState, initialCellState, ...
        inputWeights, recurrentWeights, bias, 'DataFormat', 'CBT');
    
    % Masking for training.
    if ~isempty(sequenceLengths)
        miniBatchSize = size(dlZ,2);
        for n = 1:miniBatchSize
            hiddenState(:,n) = dlZ(:,n,sequenceLengths(n));
        end
    end

end

%% f4

% Decoder Model Function
% The function modelDecoder takes the input data, the model parameters, the context vector, the LSTM initial hidden state, the outputs of the encoder, and the dropout probability and outputs the decoder output, the updated context vector, the updated LSTM state, and the attention scores.

function [dlY, context, hiddenState, attentionScores] = modelDecoder(parametersDecoder, dlX, context, ...
    hiddenState, dlZ, dropout)

    % Embedding.
    weights = parametersDecoder.emb.Weights;
    dlX = embed(dlX, weights,'DataFormat','CBT');
    
    % RNN input.
    sequenceLength = size(dlX,3);
    dlY = cat(1, dlX, repmat(context, [1 1 sequenceLength]));
    
    % LSTM 1.
    inputWeights = parametersDecoder.lstm1.InputWeights;
    recurrentWeights = parametersDecoder.lstm1.RecurrentWeights;
    bias = parametersDecoder.lstm1.Bias;
    
    initialCellState = dlarray(zeros(size(hiddenState)));
    
    dlY = lstm(dlY, hiddenState, initialCellState, inputWeights, recurrentWeights, bias, 'DataFormat', 'CBT');
    
    % Dropout.
    mask = ( rand(size(dlY), 'like', dlY) > dropout );
    dlY = dlY.*mask;
    
    % LSTM 2.
    inputWeights = parametersDecoder.lstm2.InputWeights;
    recurrentWeights = parametersDecoder.lstm2.RecurrentWeights;
    bias = parametersDecoder.lstm2.Bias;
    
    [dlY, hiddenState] = lstm(dlY, hiddenState, initialCellState,inputWeights, recurrentWeights, bias, 'DataFormat', 'CBT');
    
    % Attention.
    weights = parametersDecoder.attn.Weights;
    [attentionScores, context] = attention(hiddenState, dlZ, weights);
    
    % Concatenate.
    dlY = cat(1, dlY, repmat(context, [1 1 sequenceLength]));
    
    % Fully connect.
    weights = parametersDecoder.fc.Weights;
    bias = parametersDecoder.fc.Bias;
    dlY = fullyconnect(dlY,weights,bias,'DataFormat','CBT');
    
    % Softmax.
    dlY = softmax(dlY,'DataFormat','CBT');

end

%% f5

% Attention Function
% The attention function returns the attention scores according to Luong "general" scoring and the updated context vector. The energy at each time step is the dot product of the hidden state and the learnable attention weights times the encoder output.

function [attentionScores, context] = attention(hiddenState, encoderOutputs, weights)

    % Initialize attention energies.
    [miniBatchSize, sequenceLength] = size(encoderOutputs, 2:3);
    attentionEnergies = zeros([sequenceLength miniBatchSize],'like',hiddenState);
    
    % Attention energies.
    hWX = hiddenState .* pagemtimes(weights,encoderOutputs);
    for tt = 1:sequenceLength
        attentionEnergies(tt, :) = sum(hWX(:, :, tt), 1);
    end
    
    % Attention scores.
    attentionScores = softmax(attentionEnergies, 'DataFormat', 'CB');
    
    % Context.
    encoderOutputs = permute(encoderOutputs, [1 3 2]);
    attentionScores = permute(attentionScores,[1 3 2]);
    context = pagemtimes(encoderOutputs,attentionScores);
    context = squeeze(context);

end
% % % 
%% f6
% Masked Cross Entropy Loss
% The maskedCrossEntropy function calculates the loss between the specified input sequences and target sequences ignoring any time steps containing padding using the specified vector of sequence lengths.

function loss = maskedCrossEntropy(dlY,T,sequenceLengths)

    % Initialize loss.
    loss = 0;
    
    % Loop over mini-batch.
    miniBatchSize = size(dlY,2);
    for n = 1:miniBatchSize
        idx = 1:sequenceLengths(n);
        loss = loss + crossentropy(dlY(:,n,idx), T(:,n,idx),'DataFormat','CBT');
    end
    
    % Normalize.
    loss = loss / miniBatchSize;

end

%% f7

% Decoder Model Predicitons Function
% The decoderModelPredictions function returns the predicted sequence dlY given the input sequence, target sequence, hidden state, dropout probability, flag to enable teacher forcing, and the sequence length.

function dlY = decoderPredictions(parametersDecoder,dlZ,T,hiddenState,dropout, ...
    doTeacherForcing,sequenceLength)

% Convert to dlarray.
dlT = dlarray(T);

% Initialize context.
miniBatchSize = size(dlT,2);
numHiddenUnits = size(dlZ,1);
context = zeros([numHiddenUnits miniBatchSize],'like',dlZ);

if doTeacherForcing
    % Forward through decoder.
    dlY = modelDecoder(parametersDecoder, dlT, context, hiddenState, dlZ, dropout);
else
    % Get first time step for decoder.
    decoderInput = dlT(:,:,1);
    
    % Initialize output.
    numClasses = numel(parametersDecoder.fc.Bias);
    dlY = zeros([numClasses miniBatchSize sequenceLength],'like',decoderInput);
    
    % Loop over time steps.
    for t = 1:sequenceLength
        % Forward through decoder.
        [dlY(:,:,t), context, hiddenState] = modelDecoder(parametersDecoder, decoderInput, context, ...
            hiddenState, dlZ, dropout);
        
        % Update decoder input.
        [~, decoderInput] = max(dlY(:,:,t),[],1);
    end
end

end
%% f8

% Text Translation Function
% The translateText function translates an array of text by iterating over mini-batches. The function takes as input the model parameters, the input string array, a maximum sequence length, the mini-batch size, the source and target word encoding objects, the start and stop tokens, and the delimiter for assembling the output.

function strTranslated = translateText(parameters,strSource,maxSequenceLength,miniBatchSize, ...
    encSource,encTarget,startToken,stopToken,delimiter)

    % Transform text.
    documentsSource = transformText(strSource,startToken,stopToken);
    sequencesSource = doc2sequence(encSource,documentsSource, ...
        'PaddingDirection','right', ...
        'PaddingValue',encSource.NumWords + 1);
    
    % Convert to dlarray.
    X = cat(3,sequencesSource{:});
    X = permute(X,[1 3 2]);
    dlX = dlarray(X);
    
    % Initialize output.
    numObservations = numel(strSource);
    strTranslated = strings(numObservations,1);
    
    % Loop over mini-batches.
    numIterations = ceil(numObservations / miniBatchSize);
    for i = 1:numIterations
        idxMiniBatch = (i-1)*miniBatchSize+1:min(i*miniBatchSize,numObservations);
        miniBatchSize = numel(idxMiniBatch);
        
        % Encode using model encoder.
        sequenceLengths = [];
        [dlZ, hiddenState] = modelEncoder(parameters.encoder, dlX(:,idxMiniBatch,:), sequenceLengths);
            
        % Decoder predictions.
        doTeacherForcing = false;
        dropout = 0;
        decoderInput = repmat(word2ind(encTarget,startToken),[1 miniBatchSize]);
        decoderInput = dlarray(decoderInput);
        dlY = decoderPredictions(parameters.decoder,dlZ,decoderInput,hiddenState,dropout, ...
            doTeacherForcing,maxSequenceLength);
        [~, idxPred] = max(extractdata(dlY), [], 1);
        
        % Keep translating flag.
        idxStop = word2ind(encTarget,stopToken);
        keepTranslating = idxPred ~= idxStop;
         
        % Loop over time steps.
        t = 1;
        while t <= maxSequenceLength && any(keepTranslating(:,:,t))
        
            % Update output.
            newWords = ind2word(encTarget, idxPred(:,:,t))';
            idxUpdate = idxMiniBatch(keepTranslating(:,:,t));
            strTranslated(idxUpdate) = strTranslated(idxUpdate) + delimiter + newWords(keepTranslating(:,:,t));
            
            t = t + 1;
        end
    end

end