classdef ToolBoxActions
   enumeration
   %% training
  % Data Preparation Parameters TPPS = training.prep.params.sim
    TPPS_EDIT_RESOLUTION,
    TPPS_EDIT_RADIUS,
    TPPS_EDIT_HEIGHT,
    TPPS_EDIT_SIMULATION_COUNT,
    TPPS_EDIT_START_ANGLE,
    TPPS_EDIT_END_ANGLE,
    TPPS_EDIT_PLOT_GRAPHS,
    TPPS_EDIT_EPOCHS,
    TPPS_EDIT_TOPVIEW_DMG_LOC,
    TPPS_EDIT_SIDEVIEW_DMG_LOC,
    
   % Data Preparation dataset
    TPS_RDATA_READY,
    TPS_RCLASSES_READY
    TPS_ADATA_READY,
    TPS_ACLASSES_READY
    TPS_POINT_CLOUD_READY
    T_STARTED
     
   %% model
     % M_NETWORK_SET = Model_NETWORK_SET
     % MB_ACCURACY_SET = ModelBasic_ACCURACY_SET
    MB_ACCURACY_SET,
    M_NETWORK_SET,
    MT_DATA_TEST_SPLIT,
    MT_CLASSES_TEST_SPLIT,
    MT_CLASSES_PRED_READY,
    MB_CONF_MATRIX_READY,

    
   %% general
    TOOLBOX_OBSERVER_ATTACHED,
    G_DESCRIPTION_CHANGE,  % does nothing at this time; perhaps it should update the logger?
    G_UID_SET,  % after logger has started it should set unique identifier and log it
   
   end
   
end

