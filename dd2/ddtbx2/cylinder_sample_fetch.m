function varargout = cylinder_sample_fetch(varargin)
    pc_data = varargin{1};
    fetch_method = varargin{2};
    reso = varargin{3};
    counter = varargin{4};
    
    % Applied Constants
    d_range_x = 1;
    d_range_y = 50;
    
    % Define Temp Variables
    if fetch_method == 1
        % Bottom-to-Top %
        if counter*reso <= max(pc_data(:,3))
            temp_data = pc_data(pc_data(:,3)>=counter*reso...
                &pc_data(:,3)<=(counter+1)*reso,:);
            [r,~] = size(temp_data);
            for i = 1 : r
                try
                    if temp_data(i,2)>=0 && temp_data(i,1)>=0 
                        temp_data(i,4) = atand(temp_data(i,2) /...
                            temp_data(i,1));
                    elseif temp_data(i,2)>=0 && temp_data(i,1)<0
                        temp_data(i,4) = atand(temp_data(i,2) /...
                            temp_data(i,1))+180;
                    elseif temp_data(i,2)<0 && temp_data(i,1)<0
                        temp_data(i,4) = atand(temp_data(i,2) /...
                            temp_data(i,1))+180;
                    elseif temp_data(i,2)<0 && temp_data(i,1)>=0
                        temp_data(i,4) =  atand(temp_data(i,2) /...
                            temp_data(i,1))+360;
                    end
                catch
                    disp(num2str(i))
                end
                temp_data(i,5) = sqrt((temp_data(i,1))^2 + ...
                    (temp_data(i,2))^2);
            end
            temp_data = sortrows(temp_data,[4,5]);
            varargout{1} = temp_data;
            varargout{3} = true;
        else
            varargout{3} = false;
        end
    elseif fetch_method == 2
        % Circle %
        temp_data1 = transform_pc(pc_data, 1, [0,0,1]);
        t1 = temp_data1(temp_data1(:,1)>temp_1-temp_1/d_range_x...
                & temp_data1(:,2)>-temp_1/d_range_y...
                & temp_data1(:,2)<temp_1/d_range_y,:);
        out1 = sortrows(t1,3);
        varargout{1} = out1;
        varargout{3} = true;
    else
        varargout{3} = false;
    end
    varargout{2} = [counter*reso (counter+1)*reso];
end