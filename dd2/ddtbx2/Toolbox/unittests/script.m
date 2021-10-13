%     f=datestr(now,"yyyymmddHHMMSS");
%     T= join(['Toolbox/logger/' f '.txt'],'');
%     L = log4m.getLogger(T);
%     %{'ALL','TRACE','DEBUG','INFO','WARN','ERROR','FATAL','OFF'}
%     L.setCommandWindowLevel(L.DEBUG);
%     L.setLogLevel(L.ALL);
%     L.warn(mfilename,join(['Log changed to ' T]));
%     mapp.log=L;
%     exp = '20210723072505';
% fig_UPS = figure('Visible',"off");
% mapp.PreTrainAxes=axes('Parent',fig_UPS);
%%
pwd
%%
% exp = '20210823172937';
exp = '20210930143938';
mapp.toolbox = load(join(["LSTMTraining/" exp '.mat'],'')).lstmddtbx;
damage_cylinder_pc=mapp.toolbox.get_tps_point_cloud();
model_height=mapp.toolbox.get_tpps_height();
model_radius=mapp.toolbox.get_tpps_radius();
acc=mapp.toolbox.get_mb_accuracy();
slice_reso=mapp.toolbox.get_tpps_resolution();
epochs=mapp.toolbox.get_tpps_epochs();
start_angle=mapp.toolbox.get_tpps_start_angle();
end_angle=mapp.toolbox.get_tpps_end_angle();
sim_count=mapp.toolbox.get_tpps_simulation_count(); 
topview_dmg_loc=mapp.toolbox.get_tpps_topview_dmg_loc(); 
sideview_dmg_loc=mapp.toolbox.get_tpps_sideview_dmg_loc(); 
YPred=mapp.toolbox.get_mt_rclassespred();
ConfMat=mapp.toolbox.get_mb_confmatrix();