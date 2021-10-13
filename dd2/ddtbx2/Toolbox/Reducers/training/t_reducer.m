function t_reducer(app,event)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 switch(event.action)
    case ToolBoxActions.T_STARTED
    if event.value==true
        app.log.info(mfilename, 'Training Started!')
        app.StartTrainingButton.Enable = false;
        app.StartTrainingButton.Text='In Progress...';
        app.StartTrainingButton.BackgroundColor = [0 1.0 1.0];
    else
        app.log.info(mfilename, 'Training stopped, finished or not started')
        app.StartTrainingButton.Enable = true;
        app.StartTrainingButton.Text='Start Training';
        app.StartTrainingButton.BackgroundColor = [0 1.0 0];
    end
    otherwise 
      app.log.warn(mfilename,join([string(event.action),'not implemented']));
      msgbox(join([string(event.action) ' not implemented']),mfilename);
 end
end

