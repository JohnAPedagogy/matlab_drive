function mt_reducer(app,event)
%m_reducer - output model parameter handler
%   Detailed explanation goes here
% LSTM_DDTB_experiments = LSTM_DamageDetectionToolBox_experiment
% ToolBoxActions.MB_ACCURACY_SET = ToolBoxActions.ModelBasic_ACCURACY_SET
 switch(event.action)       
    case ToolBoxActions.MT_DATA_TEST_SPLIT
         app.log.info(mfilename,'Obtaining radius testdata....');
         
    case ToolBoxActions.MT_CLASSES_TEST_SPLIT
         app.log.info(mfilename,'Obtaining radius testclasses....');
 
    case ToolBoxActions.MT_CLASSES_PRED_READY
         app.log.info(mfilename,'Obtaining radius classespred....');
         
    case ToolBoxActions. TPS_POINT_CLOUD_READY
         app.log.info(mfilename,'Obtaining point cloud....');
    otherwise 
        app.log.warn(mfilename,join(['Warning:' string(event.action) 'not implemented']));
        msgbox(strcat(string(event.action),' not implemented'),mfilename);
        
 end
 
end

