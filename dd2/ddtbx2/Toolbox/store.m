function self = store()
% store() creates a damage detection toolbox store. It is a subject and
% several observers can be attatched
% Example:
% app = application()
% dd_store = store(app);
% dd_store.attach_observer(app);
%
% % John Alamina and Ebube Ezi using Arne Jenssen, ajj@ffi.no
% Cylinder: Using Self-defined Program
% Apply Method: damaged_cylinder_pc([15,10], 0.1,...
%                                   0.00001, 1, [20, 90, 5], 0.5, 0.05);
% Explains:
% Height: 15
% Radius: 10
% Chaos level: 0.1
% Point Cloud Density: 1e-5
% Damage start angle: 20
% Damage end angle: 90
% Damage z-height: 5, the range of damage in z-height is 5+/-(Radius/5)
% Damage level: 0.5
% Noise level: 0.05 - guassian distribution

self.observers = {};
self.store.training.prep.params.sim.start_angle = 20;
self.store.training.prep.params.sim.end_angle = 90;
self.store.training.prep.params.sim.radius = 10;  
self.store.training.prep.params.sim.height = 15;
self.store.training.prep.params.sim.plot_graphs = false;
self.store.training.prep.params.sim.simulation_count = 2;
self.store.training.prep.params.sim.resolution = 0.05;
self.store.training.prep.params.sim.epochs = 50;
self.store.training.prep.params.sim.topview_dmg_loc = [transpose(self.store.training.prep.params.sim.start_angle),transpose(self.store.training.prep.params.sim.start_angle)+70];
self.store.training.prep.params.sim.sideview_dmg_loc=[self.store.training.prep.params.sim.height-self.store.training.prep.params.sim.radius/10,self.store.training.prep.params.sim.height+self.store.training.prep.params.sim.radius/10];

%% Helper flags

self.helper.starting = false;
self.helper.retain_log = true;
self.helper.log_started = false;
self.helper.network_ready = false;

%% Observer functions

    function attach_observer(o)
        self.observers =[self.observers(:)' {o}];
%         o.set_subject(self);
        evt.action=ToolBoxActions.TOOLBOX_OBSERVER_ATTACHED;
        o.update(evt);
    end
    self.attach_observer = @attach_observer;

    function notify(evt)
        for k = 1:length(self.observers)
            self.observers{k}.update(evt);
        end
    end

    %% Training
    % 1_start_angle
    
    function set_tpps_start_angle(s)
        self.store.training.prep.params.sim.start_angle = s;
        evt.action=ToolBoxActions.TPPS_EDIT_START_ANGLE;
        evt.value = s;
        notify(evt);
    end
    function s = get_tpps_start_angle()        
        s = self.store.training.prep.params.sim.start_angle;
    end
    self.get_tpps_start_angle = @get_tpps_start_angle;
    self.set_tpps_start_angle = @set_tpps_start_angle;
    
% 2_end_angle
    function set_tpps_end_angle(s)
        self.store.training.prep.params.sim.end_angle = s;
        evt.action=ToolBoxActions.TPPS_EDIT_END_ANGLE;
        evt.value = s;
        notify(evt);
    end
    function s = get_tpps_end_angle()        
        s = self.store.training.prep.params.sim.end_angle;
    end
    self.set_tpps_end_angle = @set_tpps_end_angle;
    self.get_tpps_end_angle = @get_tpps_end_angle;
    
% 3_radius
    function set_tpps_radius(s)
        self.store.training.prep.params.sim.radius = s;
        evt.action=ToolBoxActions.TPPS_EDIT_RADIUS;
        evt.value = s;
        notify(evt);
    end
    function s = get_tpps_radius()        
        s = self.store.training.prep.params.sim.radius;
    end
    self.get_tpps_radius = @get_tpps_radius;
    self.set_tpps_radius = @set_tpps_radius;
    
% 4_height
    function set_tpps_height(s)
        self.store.training.prep.params.sim.height = s;
        evt.action=ToolBoxActions.TPPS_EDIT_HEIGHT;
        evt.value = s;
        notify(evt);
    end
    function s = get_tpps_height()        
        s = self.store.training.prep.params.sim.height;
    end
%     function s = get_tpps_height2()        
%         s = self.store.training.prep.params.sim.height * self.store.training.prep.params.sim.simulation_count;
%     end
    self.get_tpps_height = @get_tpps_height;
%     self.get_tpps_height2 = @get_tpps_height2;
    self.set_tpps_height = @set_tpps_height;
%     self.set_tpps_height = @set_tpps_height2;
    
 % 5_plot_graphs
    function set_tpps_plot_graphs(s)
        self.store.training.prep.params.sim.plot_graphs = s;
        evt.action=ToolBoxActions.TPPS_EDIT_PLOT_GRAPHS;
        evt.value = s;
        notify(evt);
    end
    function s = get_tpps_plot_graphs()        
        s = self.store.training.prep.params.sim.plot_graphs;
    end
    self.get_tpps_plot_graphs = @get_tpps_plot_graphs;
    self.set_tpps_plot_graphs = @set_tpps_plot_graphs;
    
% 6_simulation_count
    function set_tpps_simulation_count(s)
        self.store.training.prep.params.sim.simulation_count = s;
        evt.action=ToolBoxActions.TPPS_EDIT_SIMULATION_COUNT;
        evt.value = s;
        notify(evt);
    end
    function s = get_tpps_simulation_count()        
        s = self.store.training.prep.params.sim.simulation_count;
    end
    self.get_tpps_simulation_count = @get_tpps_simulation_count;
    self.set_tpps_simulation_count = @set_tpps_simulation_count;

% 7_resolution
    function set_tpps_resolution(s)
        self.store.training.prep.params.sim.resolution = s;
        evt.action=ToolBoxActions.TPPS_EDIT_RESOLUTION;
        evt.value = s;
        notify(evt);
    end
    function s = get_tpps_resolution()        
        s = self.store.training.prep.params.sim.resolution;
    end
    self.get_tpps_resolution = @get_tpps_resolution;
    self.set_tpps_resolution = @set_tpps_resolution;
    
% 8_epochs
    function set_tpps_epochs(s)
        s = round(s);
        self.store.training.prep.params.sim.epochs = s;
        evt.action=ToolBoxActions.TPPS_EDIT_EPOCHS;
        evt.value = s;
        notify(evt);
    end
    function s = get_tpps_epochs()        
        s = self.store.training.prep.params.sim.epochs;
    end
    self.get_tpps_epochs = @get_tpps_epochs;
    self.set_tpps_epochs = @set_tpps_epochs;
    

% 9_topview_dmg_loc
    function set_tpps_topview_dmg_loc(s)
        s = round(s);
        self.store.training.prep.params.sim.topview_dmg_loc = s;
        evt.action=ToolBoxActions.TPPS_EDIT_TOPVIEW_DMG_LOC;
        evt.value = s;
        notify(evt);
    end
    function s = get_tpps_topview_dmg_loc()        
        s = self.store.training.prep.params.sim.topview_dmg_loc;
    end
    self.get_tpps_topview_dmg_loc = @get_tpps_topview_dmg_loc;
    self.set_tpps_topview_dmg_loc = @set_tpps_topview_dmg_loc;
    
    
% 10_sideview_dmg_loc
    function set_tpps_sideview_dmg_loc(s)
        s = round(s);
        self.store.training.prep.params.sim.sideview_dmg_loc = s;
        evt.action=ToolBoxActions.TPPS_EDIT_SIDEVIEW_DMG_LOC;
        evt.value = s;
        notify(evt);
    end
    function s = get_tpps_sideview_dmg_loc()        
        s = self.store.training.prep.params.sim.sideview_dmg_loc;
    end
    self.get_tpps_sideview_dmg_loc = @get_tpps_sideview_dmg_loc;
    self.set_tpps_sideview_dmg_loc = @set_tpps_sideview_dmg_loc;
    
    %% Display function
   
    function print()
        display(self);
    end
    self.print = @print;
    

    %% Training Data
    % 1_radius_data

    self.store.training.prep.set.rdata = [];
    self.store.training.prep.set.rclasses = [];
    self.store.training.prep.set.point_cloud = [];

    function set_tps_rdata(s)
        self.store.training.prep.set.rdata = s;
        evt.action=ToolBoxActions.TPS_RDATA_READY;
        evt.value = s;
        notify(evt);
    end
    function s = get_tps_rdata()        
        s = self.store.training.prep.set.rdata;
    end
    function s = get_tps_rndata()        
        s = self.store.training.prep.set.rdata;
        s = normalize(s);
    end
    self.get_tps_rdata = @get_tps_rdata;
    self.get_tps_rndata = @get_tps_rndata;
    self.set_tps_rdata = @set_tps_rdata;
    
    
    % 2_radius_classes

    function set_tps_rclasses(s)
        self.store.training.prep.set.rclasses = s;
        evt.action=ToolBoxActions.TPS_RCLASSES_READY;
        evt.value = s;
        notify(evt);
    end
    function s = get_tps_rclasses()        
        s = self.store.training.prep.set.rclasses;
    end
    self.get_tps_rclasses = @get_tps_rclasses;
    self.set_tps_rclasses = @set_tps_rclasses;
    
    
    % 3_point_cloud

    function set_tps_point_cloud(s)
        self.store.training.prep.set.point_cloud = s;
        evt.action=ToolBoxActions.TPS_POINT_CLOUD_READY;
        evt.value = s;
        notify(evt);
    end
    function s = get_tps_point_cloud()        
        s = self.store.training.prep.set.point_cloud;
    end
    self.get_tps_point_cloud = @get_tps_point_cloud;
    self.set_tps_point_cloud = @set_tps_point_cloud;
    
    
    % 4_training_started

    self.store.training.started = false;

    function set_t_started(s)
        self.store.training.started = s;
        evt.action=ToolBoxActions.T_STARTED;
        evt.value = s;
        notify(evt);
    end
    function s = get_t_started()        
        s = self.store.training.started;
    end
    self.get_t_started = @get_t_started;
    self.set_t_started = @set_t_started;
    
   
    %% Result/model
    % 1_accuracy

    self.store.model.basic.accuracy = 0.0;

    function set_mb_accuracy(s)
        self.store.model.basic.accuracy = s;
        evt.action=ToolBoxActions.MB_ACCURACY_SET;
        evt.value = s;
        notify(evt);
    end
    function s = get_mb_accuracy()        
        s = self.store.model.basic.accuracy;
    end
    self.get_mb_accuracy = @get_mb_accuracy;
    self.set_mb_accuracy = @set_mb_accuracy;
    
    % 2_Network
    
    self.store.model.network = [];

    function set_m_network(s)
        self.store.model.network = s;
        evt.action=ToolBoxActions.M_NETWORK_SET;
        evt.value = s;
        notify(evt);
    end
    function s = get_m_network()        
        s = self.store.model.network;
    end
    self.get_m_network = @get_m_network;
    self.set_m_network = @set_m_network;
    
    % 3_radius_test_data
    
      self.store.model.testdata.rdatatest = [];

    function set_mt_rdatatest(s)
        self.store.model.testdata.rdatatest = s;
        evt.action=ToolBoxActions.MT_DATA_TEST_SPLIT;
        evt.value = s;
        notify(evt);
    end
    function s = get_mt_rdatatest()        
        s = self.store.model.testdata.rdatatest;
    end
    self.get_mt_rdatatest = @get_mt_rdatatest;
    self.set_mt_rdatatest = @set_mt_rdatatest;
    
    % 4_radius_test_classes

    self.store.model.testdata.rclassestest = [];

    function set_mt_rclassestest(s)
        self.store.model.testdata.rclassestest = s;
        evt.action=ToolBoxActions.MT_CLASSES_TEST_SPLIT;
        evt.value = s;
        notify(evt);
    end
    function s = get_mt_rclassestest()        
        s = self.store.model.testdata.rclassestest;
    end
    self.get_mt_rclassestest = @get_mt_rclassestest;
    self.set_mt_rclassestest = @set_mt_rclassestest;
    
    % 5_radius_classes_pred
    
    self.store.model.testdata.rclassespred = [];

    function set_mt_rclassespred(s)
        self.store.model.testdata.rclassespred = s;
        evt.action=ToolBoxActions.MT_CLASSES_PRED_READY;
        evt.value = s;
        notify(evt);
    end
    function s = get_mt_rclassespred()        
        s = self.store.model.testdata.rclassespred;
    end
    self.get_mt_rclassespred = @get_mt_rclassespred;
    self.set_mt_rclassespred = @set_mt_rclassespred;
    
    
     % 6_confmatrix
    
    self.store.model.basic.confmatrix = [];

    function set_mb_confmatrix(s)
        self.store.model.basic.confmatrix = s;
        evt.action=ToolBoxActions.MB_CONF_MATRIX_READY;
        evt.value = s;
        notify(evt);
    end
    function s = get_mb_confmatrix()        
        s = self.store.model.basic.confmatrix;
    end
    self.get_mb_confmatrix = @get_mb_confmatrix;
    self.set_mb_confmatrix = @set_mb_confmatrix;
    
    
    %% General
    % 1_uid

    self.store.general.uid = '';

    function set_g_uid(s)
        self.store.general.uid = s;
        evt.action=ToolBoxActions.G_UID_SET;
        evt.value = s;
        notify(evt);
    end
    function s = get_g_uid()        
        s = self.store.general.uid;
    end
    self.get_g_uid = @get_g_uid;
    self.set_g_uid = @set_g_uid;
    
    % 2_description

    self.store.general.description =DescriptionManager();

    function set_g_description(app,event)
        self.store.general.description=self.store.general.description.set_value(app,event);
        evt.action=ToolBoxActions.G_DESCRIPTION_CHANGE;
        evt.value = self.store.general.description.value;
        notify(evt);
    end
    function s = get_g_description()        
        s = self.store.general.description.value;
    end
    function s = get_g_description_fmt()        
        s = self.store.general.description.format();
    end
    self.get_g_description_fmt = @get_g_description_fmt;
    self.get_g_description = @get_g_description;
    self.set_g_description = @set_g_description;
    
end