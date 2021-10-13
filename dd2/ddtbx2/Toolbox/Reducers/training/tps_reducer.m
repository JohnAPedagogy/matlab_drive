function tps_reducer(app,event)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 switch(event.action)
    case ToolBoxActions.TPS_RDATA_READY
        app.log.info(mfilename, 'Training radius dataset prepared!')
        app.log.warn(mfilename, 'Training radius description modification not implemented!')
    case ToolBoxActions.TPS_RCLASSES_READY
        app.log.info(mfilename, 'Training radius classes prepared!')
    case ToolBoxActions.TPS_POINT_CLOUD_READY
        app.log.info(mfilename, 'Training point cloud processed!')
        k = event.value;
        scatter3(app.UIAxes, k(:,1),k(:,2),k(:,3),5,k(:,3));
    otherwise 
      app.log.warn(mfilename,join([string(event.action) 'not implemented']));
      msgbox(join([string(event.action) 'not implemented']),mfilename);
 end
end

