function  t_lstm_dloc()
%UNTITLED Summary of this function goes here
% %   Unsupervised because it is coming from the network's prediction
%     f=datestr(now,"yyyymmddHHMMSS");
%     T= join(['Toolbox/logger/' f '.txt'],'');
%     L = log4m.getLogger(T);
%     % Properties of log4m {'ALL','TRACE','DEBUG','INFO','WARN','ERROR','FATAL','OFF'}
%     L.setCommandWindowLevel(L.DEBUG);
%     L.setLogLevel(L.ALL);
%     L.warn(mfilename,join(['Log changed to ' T]));
%     mapp.log=L;
% %     exp = '20210723072505';
%     exp = '20210723101847';
%     mapp.toolbox = load(join(["LSTMTraining/" exp '.mat'],'')).lstmddtbx;
    fig_UPS = figure('Visible',"off");
    mapp.PreTrainAxes=axes('Parent',fig_UPS);
%     x=mapp.toolbox.get_tps_point_cloud();
   %     somex=mapp.toolbox.get_tps_rdata();
%     allx=mapp.toolbox.get_tps_rndata();
%     net = mapp.toolbox.get_m_network();
%     acc = mapp.toolbox.get_mb_accuracy();
%     L.info(mfilename, join(['Classifying using network from 20210723072505, with accuracy:' string(acc)]));
%     YPred = classify(net,allx);
    dloc(mapp,cylinder_pc,string(YPred));
end

