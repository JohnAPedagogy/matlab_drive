function  tdloc()
%UNTITLED Summary of this function goes here
%   This is a supervised LSTM model
    f=datestr(now,"yyyymmddHHMMSS");
    T= join(['Toolbox/logger/' f '.txt'],'');
    L = log4m.getLogger(T);
    %{'ALL','TRACE','DEBUG','INFO','WARN','ERROR','FATAL','OFF'}
    L.setCommandWindowLevel(L.DEBUG);
    L.setLogLevel(L.ALL);
    L.warn(mfilename,join(['Log changed to' T]));
    mapp.log=L;

    exp = '20210723101847';
    mapp.toolbox = load(join(["LSTMTraining/" exp '.mat'],'')).lstmddtbx;
    fig_UPS = figure('visible',false);
    mapp.PreTrainAxes=axes('Parent',fig_UPS);
    x=mapp.toolbox.get_tps_point_cloud(); 
    y=mapp.toolbox.get_tps_rclasses(); % y is the classes originally set by user
    acc = mapp.toolbox.get_mb_accuracy();
    L.info(mfilename, join(['Classifying using network from exeriment' exp ...
        ', with accuracy:' string(acc)]));
    dloc(mapp,x,y); 
end

