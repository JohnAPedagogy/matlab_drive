function m_reducer(app,event)
%m_reducer - output model parameter handler
%   Detailed explanation goes here
% LSTM_DDTB_experiments = LSTM_DamageDetectionToolBox_experiment
% ToolBoxActions.MB_ACCURACY_SET = ToolBoxActions.ModelBasic_ACCURACY_SET
 switch(event.action)
    case ToolBoxActions.MB_ACCURACY_SET
        app.Accuracy.Text = join([string(event.value * 100) '%']);
        if(app.toolbox.helper.network_ready)
            app.log.warn(mfilename,'Warning: Load accuracy and model not yet implemented!');
            app.toolbox.set_t_started(false);
            lstmddtbx = app.toolbox;
            app.log.debug(mfilename, join(['check accuracy variable =' string(app.toolbox.get_mb_accuracy() * 100) '%']));
            save(join(['LSTMTraining/' app.toolbox.get_g_uid() '.mat'],''),'lstmddtbx');
            msgbox('Training complete!', mfilename);
            app.TabGroup.SelectedTab = app.LSTMModelTab;
        end
        
    case ToolBoxActions.M_NETWORK_SET
         app.log.info(mfilename,'Network is set...saving');
         
    case ToolBoxActions.MB_CONF_MATRIX_READY
         app.log.info(mfilename,'Plotting confusion matrix...');
         YTest = app.toolbox.get_mt_rclassestest();
         YPred = app.toolbox.get_mt_rclassespred();
         bar3(app.ConfusionAxes, plotConfusion(string(YTest), string(YPred)));
    otherwise 
        app.log.warn('m_reducer',join(['Warning:' string(event.action) 'not implemented']));
        msgbox(strcat(string(event.action),' not implemented'),mfilename);
        
 end
 
end

