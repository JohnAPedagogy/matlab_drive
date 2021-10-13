% clear; close all; clc;
%% Run Simulation
app = get_store();
app.toolbox.set_tpps_simulation_count(1);
mylstm2(app)
app.toolbox.set_g_uid(datestr(now,"yyyymmddHHMMSS"));
save_net(app)
%% dloc parameters
allx=app.toolbox.get_tps_rndata();
net = app.toolbox.get_m_network();
acc = app.toolbox.get_mb_accuracy();
YPred = classify(net,allx);
classes = app.toolbox.get_tps_rclasses();
cylinder_pc = app.toolbox.get_tps_point_cloud();
%% Run dloc for original
dloc(app,cylinder_pc,string(classes));
title('Classified')

%% Run dloc for predicted
dloc(app,cylinder_pc,string(YPred));
title('Predicted')



