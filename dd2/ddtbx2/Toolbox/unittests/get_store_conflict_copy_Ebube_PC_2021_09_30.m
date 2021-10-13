function app = get_store()
%UNTITLED Summary of this function goes here
%   Unsupervised because it is coming from the network's prediction
    f=datestr(now,"yyyymmddHHMMSS");
    T= join(['Toolbox/logger/' f '.txt'],'');
    L = log4m.getLogger(T);
    % Properties of log4m {'ALL','TRACE','DEBUG','INFO','WARN','ERROR','FATAL','OFF'}
    L.setCommandWindowLevel(L.DEBUG);
    L.setLogLevel(L.ALL);
    L.warn(mfilename,join(['Log changed to ' T]));
    mapp.log=L;
    mapp.toolbox=store();
    app = mapp;
end

