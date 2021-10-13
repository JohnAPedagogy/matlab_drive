function app = mapp()
    f=datestr(now,"yyyymmddHHMMSS");
    T= join(['Toolbox/logger/' f '.txt'],'');
    L = log4m.getLogger(T);
    %{'ALL','TRACE','DEBUG','INFO','WARN','ERROR','FATAL','OFF'}
    L.setCommandWindowLevel(L.DEBUG);
    L.setLogLevel(L.ALL);
    L.warn(mfilename,join(['Log changed to ' T]));
    app.log=L;
    app.toolbox =store();
end