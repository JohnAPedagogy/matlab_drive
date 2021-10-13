function  logger = start_logger(app,evt)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    %disp(app.toolbox)
    %toolbox=app.toolbox;
    f=datestr(now,"yyyymmddHHMMSS");
%     create a new file
    if(~app.toolbox.helper.retain_log)
        T= join(['Toolbox/logger/' f '.txt'],'');
        L = log4m.getLogger(T);
        %{'ALL','TRACE','DEBUG','INFO','WARN','ERROR','FATAL','OFF'}
        L.setCommandWindowLevel(L.DEBUG);
        L.setLogLevel(L.ALL);
        app.toolbox.helper.log_started=true;
        app.toolbox.set_g_uid(f);
        L.warn(mfilename,join(['Log changed to toolbox/logger/',app.toolbox.get_g_uid,'.txt'],''))
        logger = L;
        return;
    end
    % use same file
    T= join(['Toolbox/logger/' f '.txt'],'');
    if(~isfile(T) && app.toolbox.helper.retain_log)
        L = log4m.getLogger(T);
        %{'ALL','TRACE','DEBUG','INFO','WARN','ERROR','FATAL','OFF'}
        L.setCommandWindowLevel(L.DEBUG);
        L.setLogLevel(L.ALL);
        app.toolbox.helper.log_started =true;
        app.toolbox.set_g_uid(f);
        logger = L;
    end    
end

