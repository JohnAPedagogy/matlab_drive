function  dloc(app, x,y)
    % cd('C:\Users\Ebube\MATLAB Drive\Model_process\LSTM')

    % YPred = classify(net,datasize');

%     a = importdata('simulated_cylinder7.txt');
    % data = upsample(a, 10);
    data=x;
    categ = y;
    zran = app.toolbox.get_tpps_resolution(); % size of the each slice - resolution   
    ran = app.toolbox.get_tpps_radius(); % range of x and y axis (radius)
    height_of_model = max(data(:,3));
    app.log.debug(mfilename,join(['resolution of model =' string(zran)]));
    app.log.debug(mfilename,join(['radius of model =' string(ran)]));
    app.log.debug(mfilename,join(['height of model =' string(height_of_model)]));
    down_by = 1;
    % pcshow(data)
    % TO CLEAN THE DATA
    % temp_data( any(temp_data==0,2), : ) = [];  %rows
    % temp_data( :, ~any(temp_data,1) ) = [];  %columns

    % Classification
    % temp_class = zeros(1,200);
    % temp_class(86:135)=1;
    % categ = num2cell(temp_class,1);
    % categ(temp_class==0 ) ={"good"}; 
    % categ(temp_class==1) = {"damaged"}; 
    %% 
%     figure('visible','off');
    figure
%     close all;
    starting_point=0; % specifying the start point from the bottom
    height = starting_point;

%     p2 = plot3(app.PreTrainAxes, data(:,1), data(:,2), data(:,3), '.', 'Color', 'b');hold on;
%     p3 = plot3(app.PreTrainAxes, 0, 0, 0, 'o', 'Color', 'g');
    p2 = plot3( data(:,1), data(:,2), data(:,3), '.', 'Color', 'b');hold on;
    p3 = plot3( 0, 0, 0, 'o', 'Color', 'g');

    axis equal;
    xlim([-1 * ran ran]);
    ylim([-1 * ran ran]);
    app.log.debug(mfilename, 'plotting...');
    j=0; % This is a counter
    prev=categ{1}; % 'categ' is from the auto_classification
    while height < height_of_model
        height = height + zran;
        j=j+1;
        try
%             app.log.debug(mfilename,join(['plotting slice' string(j)]));
            tmp_pc = data(data(:,3)>height-zran & data(:,3)<height+zran, :);
            tmp_pc = downsample(tmp_pc, down_by);
            set(p3, 'xdata', tmp_pc(:,1), 'ydata', tmp_pc(:,2), 'zdata', tmp_pc(:,3));
            if mod(j,250)== 0 ; app.log.debug(mfilename,join(['trace:j, data size:' string(j) string(size(tmp_pc))])); end
        catch e
            if mod(j,150)== 0
                app.log.debug(mfilename,join(['error slice' string(j) 'data size:' join(string(size(tmp_pc))) e.identifier '->' e.message]));
            end
        end
    %      drawnow;
        if j==length(categ)
            break;
        end
        curr=categ{j}; 
        if mod(j,50)== 0 ; app.log.debug(mfilename,join(['trace:j,curr,prev' string(j) length(curr) length(prev)])); end
        if length(curr) ~= length(prev)
           plot3(tmp_pc(:,1), tmp_pc(:,2), tmp_pc(:,3), '.-', 'Color', 'r');
           fprintf('%s starts here: %3.2f ',curr,starting_point+j*zran);
%            app.log.info(mfilename, join([curr ' starts here:'  starting_point+j*zran]));
        end
        prev=categ{j};
    end
        title('Model');
        xlabel('X(mm)');
        ylabel('Y(mm)');
        zlabel('Z(mm)');
    hold off;
end