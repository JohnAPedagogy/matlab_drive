% function  t_lstm_dloc()
%TITLED -  TO COMPARE HOW A TRAINED NETWORK PERFORMS ON AN INDEPENDENT DATA
%   Unsupervised because it is coming from the network's prediction
    f=datestr(now,"yyyymmddHHMMSS");
    T= join(['Toolbox/logger/' f '.txt'],'');
    L = log4m.getLogger(T);
    % Properties of log4m {'ALL','TRACE','DEBUG','INFO','WARN','ERROR','FATAL','OFF'}
    L.setCommandWindowLevel(L.DEBUG);
    L.setLogLevel(L.ALL);
    L.warn(mfilename,join(['Log changed to ' T]));
    mapp.log=L;
    %% The input data from a different network
    mapp.toolbox1 = lstmddtbx1; % Point cloud of a different network but must be in workspace
    x=mapp.toolbox1.get_tps_point_cloud();
    classes = mapp.toolbox1.get_tps_rclasses();
    allx=mapp.toolbox1.get_tps_rndata();
    
    % Dimensionality reduction
    data = allx(1:end-1,:); %for subtracting sequence   
%     data(1:end+1,:) = data(1) ; % For adding to sequence
    
    %% The network for performing dloc
    exp = '20210723064919';
    mapp.toolbox = load(join(["LSTMTraining/" exp '.mat'],'')).lstmddtbx;
    %   somex=mapp.toolbox.get_tps_rdata();
    fig_UPS = figure('Visible',"off");
    mapp.PreTrainAxes=axes('Parent',fig_UPS);
    net = mapp.toolbox.get_m_network();
    acc = mapp.toolbox.get_mb_accuracy();
    L.info(mfilename, join(['Classifying using network from 20210723064919, with accuracy:' string(acc)]));
    YPred = classify(net,data);
    acc = sum(YPred == data)./numel(data);
%     dloc(mapp,x,string(YPred));
% end


%% Run dloc for original
dloc(mapp,x,string(classes));
title('Classified')

%% Run dloc for predicted
dloc(mapp,x,string(YPred));
title('Predicted')
