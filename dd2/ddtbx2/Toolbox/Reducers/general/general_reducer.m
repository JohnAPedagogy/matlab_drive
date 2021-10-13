function general_reducer(app, event)
    toolbox=app.toolbox;
    app.log.info(mfilename, join([ 'event is ' string(event.action)]))
    toolbox.set_tpps_start_angle(toolbox.get_tpps_start_angle());
    toolbox.set_tpps_end_angle(toolbox.get_tpps_end_angle());
    toolbox.set_tpps_radius(toolbox.get_tpps_radius());
    toolbox.set_tpps_height(toolbox.get_tpps_height());
    toolbox.set_tpps_plot_graphs(toolbox.get_tpps_plot_graphs());
    toolbox.set_tpps_resolution(toolbox.get_tpps_resolution());
    toolbox.set_tpps_simulation_count(toolbox.get_tpps_simulation_count());
    toolbox.set_tpps_epochs(toolbox.get_tpps_epochs());
    toolbox.set_tpps_topview_dmg_loc(toolbox.get_tpps_topview_dmg_loc());
    toolbox.set_tpps_sideview_dmg_loc(toolbox.get_tpps_sideview_dmg_loc());
end