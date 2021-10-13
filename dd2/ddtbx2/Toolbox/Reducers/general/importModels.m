function table = importModels() 

    Files=tabledataread();
    k=1;
    for j=1:length(Files)
        try
            mapp.toolbox = load(Files{k}).lstmddtbx;
    %         s(k).damage_cylinder_pc=mapp.toolbox.get_tps_point_cloud();
    %         s(k).sim_date = Files{k}; ToDo include this later removing the file location
            v =split(Files{k},"\");
            v = v(end);
            v = split(v,".");
            s(k).model_name = v(1);
            s(k).model_height=mapp.toolbox.get_tpps_height() * mapp.toolbox.get_tpps_simulation_count();
            s(k).model_radius=mapp.toolbox.get_tpps_radius();
            s(k).acc=mapp.toolbox.get_mb_accuracy();
            s(k).slice_reso=mapp.toolbox.get_tpps_resolution();
            s(k).epochs=mapp.toolbox.get_tpps_epochs();
    %         s(k).topview_dmg_loc=mapp.toolbox.get_tpps_topview_dmg_loc();
    %         s(k).sideview_dmg_loc=mapp.toolbox.get_tpps_sideview_dmg_loc();
            s(k).start_angle=mapp.toolbox.get_tpps_start_angle();
            s(k).end_angle=mapp.toolbox.get_tpps_end_angle();
            s(k).sim_count=mapp.toolbox.get_tpps_simulation_count(); 
            s(k).YPred=mapp.toolbox.get_mt_rclassespred();
            s(k).ConfMat=mapp.toolbox.get_mb_confmatrix();
        catch e
            disp(join(["Error in: " Files{k}]));
            disp(e.message);
            k=k-1;
        end
%         data = allx(1:end,:); %for subtracting sequence   
%     data(1:end+1,:) = data(1) ; % For adding to sequence
        k=k+1;
    end
    table = struct2table(s);
end