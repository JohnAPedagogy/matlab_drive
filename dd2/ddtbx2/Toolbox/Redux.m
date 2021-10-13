%% Just a dummy micromodel of the idea of the Redux pattern as applied to LSTMDDToolbox

%% Create store

store.training.prep.params.sim.start_angle = 40;
store.training.prep.params.sim.end_angle = 180;
store.training.prep.params.sim.radius = 10;
store.training.prep.params.sim.height = 20;
store.training.prep.params.sim.plot_graphs = false;
store.training.prep.params.sim.simulation_count = 2;
store.training.prep.params.sim.resolution = 0.05;
store.training.prep.params.sim.epochs = 50;
store.training.prep.params.sim.topview_dmg_loc = [transpose(store.training.prep.params.sim.start_angle),transpose(store.training.prep.params.sim.start_angle)+70];
store.training.prep.params.sim.sideview_dmg_loc=[store.training.prep.params.sim.height-store.training.prep.params.sim.radius/10,store.training.prep.params.sim.height+store.training.prep.params.sim.radius/10];




%% Create actions
% STPPS = store.training.prep.params.sim
stpps_edit_resolution = "STPPS_EDIT_RESOLUTION";
stpps_edit_radius = "STPPS_EDIT_RADIUS";
stpps_edit_height = "STPPS_EDIT_HEIGHT";
stpps_edit_simulation_count = "STPPS_EDIT_SIMULATION_COUNT";
stpps_edit_start_angle = "STPPS_EDIT_START_ANGLE";
stpps_edit_end_angle = "STPPS_EDIT_END_ANGLE";

%% Create reducer

% % classdef Myclass
% %     properties (Access = public)
% %         toolbox  % Description
% %     end
% %     
% %     methods (Access = private)
% % 
% %         function test()
% %             disp('hello')
% %         end
% %     end
% % 
% % end

