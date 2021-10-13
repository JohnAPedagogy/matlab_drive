function tpps_reducer(app, event)
 tpps_desc_reducer(app,event);
 switch(event.action)
    case ToolBoxActions.TPPS_EDIT_EPOCHS
%         app.EpochsSlider.Value = event.value;  % this has been
%         implemented by the UI
        app.EpochsLabel.Text = join(['Epochs:' string(event.value)]);
%     case ToolBoxActions.TPS_RCLASSES_READY
    case ToolBoxActions.TPPS_EDIT_SIMULATION_COUNT
       app.toolbox.set_tpps_height(app.toolbox.get_tpps_height());
    otherwise 
      app.log.trace(mfilename,join(['Warning:' string(event.action) 'not implemented']));
 end
end
