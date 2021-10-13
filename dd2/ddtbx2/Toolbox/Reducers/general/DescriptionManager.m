classdef DescriptionManager
    
    %UNTITLED Summary of this class goes here
    %   Manages the dsc
    properties
        value
    end

    methods
        function obj = DescriptionManager()
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.value = '';
        end
        
        function formatted = format(obj)
            arr = split(obj.value,'_');
            text=strings(1,floor(length(arr)));
            j=0;
            for i = 1:length(arr)-1
                if mod(i,2)==1
                    j=j+1;
                    text(j) = sprintf('%s: %s\n',arr(i),arr(i+1)); 
                end
            end
            formatted=join(text,'');
        end
        
        function outputArg = set_value(obj,app, event)
             switch(event.action)
                case ToolBoxActions.TPPS_EDIT_START_ANGLE
                   for_value="start-angle";
                case ToolBoxActions.TPPS_EDIT_END_ANGLE
                  for_value="end-angle";
                case ToolBoxActions.TPPS_EDIT_RADIUS
                  for_value="radius";
                case ToolBoxActions.TPPS_EDIT_HEIGHT
                  event.value = event.value * app.toolbox.get_tpps_simulation_count();
                  for_value="height";
                case ToolBoxActions.TPPS_EDIT_PLOT_GRAPHS
                  for_value="plot-graphs";
                case ToolBoxActions.TPPS_EDIT_RESOLUTION
                  for_value="resolution";
                case ToolBoxActions.TPPS_EDIT_SIMULATION_COUNT
                   for_value="sim-count";
                case ToolBoxActions.TPPS_EDIT_TOPVIEW_DMG_LOC
                   for_value="topview_dmg_loc";
                case ToolBoxActions.TPPS_EDIT_SIDEVIEW_DMG_LOC
                   for_value="sideview_dmg_loc";                  
                case ToolBoxActions.G_UID_SET
                   for_value="exp";
                case ToolBoxActions.MB_ACCURACY_SET
                   for_value="accuracy";
                case ToolBoxActions.TPPS_EDIT_EPOCHS
                   for_value="epochs";
                otherwise 
                  msgbox('invalid description parameter')
                  for_value = '';
             end
             x=obj.value;
            arr = split(obj.value,"_");
            if(contains(obj.value,for_value))
                idx = find(contains(arr,for_value));
                arr(idx+1)=string(event.value);
                x=join(arr,'_');
            else
                x = join([for_value string(event.value) obj.value],"_");
            end
            obj.value=x;
            outputArg = obj;
        end
    end
end