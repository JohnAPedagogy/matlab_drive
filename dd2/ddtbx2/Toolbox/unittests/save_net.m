function save_net(app)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
lstmddtbx = app.toolbox;
save(join(['LSTMTraining/' app.toolbox.get_g_uid() '.mat'],''),'lstmddtbx');
end

