function tpps_desc_reducer(app, event)
    app.log.trace(mfilename,join(['ToolboxAction =' string(event.action) ':' string(event.value)]));%log description change
    if event.action == ToolBoxActions.G_UID_SET
        if app.toolbox.helper.starting
%             app.log.trace(mfilename, 'setting app.toolbox.starting to false');
            app.toolbox.helper.starting=false;
            app.toolbox.set_g_description(app,event);
            app.ConfigureDescription.Value = app.toolbox.get_g_description();
            app.ModelDescription.Value = app.toolbox.get_g_description_fmt();
            return 
        end
        return
     end
%     app.log.trace(mfilename, 'setting app.toolbox.starting to true');
    app.toolbox.helper.starting=true;
    app.toolbox.set_g_description(app,event);
    app.ConfigureDescription.Value = app.toolbox.get_g_description_fmt(); 
    app.ModelDescription.Value = app.toolbox.get_g_description_fmt();
end
