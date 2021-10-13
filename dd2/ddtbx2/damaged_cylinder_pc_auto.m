% Example:
%   data = damaged_cylinder_pc([3,5],0.1,0.00002,1,[0,90, 1.5],0.5);
%   pcshow(data);view(0,90)

function varargout = damaged_cylinder_pc_auto(varargin)
    % Para1: dimension <height, radius>
    % Para2: chaos level
    % Para3: number of points
    % Para4: increase a function consider the scanning direction/behavior - random sampling or even
    % Para5: damaged_location [theta1, theta2, alpha, beta] (specified in 0 - 360 degs)
    % Para6: damaged amplitude level (cosine function)
    obj_dimension = varargin{1};
    obj_chaos_level = varargin{2};
    obj_density = varargin{3};
    obj_dloc = varargin{5};
    obj_dlevel = varargin{6};
    
    if varargin{4}
        disp('Random distribution');
        % Bottom and Top
        pc_size = floor(1/obj_density);
%         pc_top = [rand(pc_size,1)*obj_dimension(2),...
%             rand(pc_size,1)*obj_dimension(2),...
%             ones(pc_size,1)*obj_dimension(1)];
%         pc_bot = [rand(pc_size,1)*obj_dimension(2),...
%             rand(pc_size,1)*obj_dimension(2),...
%             zeros(pc_size,1)];
        
        % Side Wall Unwrapped PC
        % pc_side[radians, z_height]
%         noise_level = 0;% put in a scaling factor 
        pc_side_rz = [rand(pc_size,1)*2*pi*obj_dimension(2),...
            rand(pc_size, 1)*obj_dimension(1)];
%         pc_side_rz = pc_side_rz * noise_level;
        pc_degs = (pc_side_rz(:,1)/(2*pi*obj_dimension(2)))*360;
        
%         pd = 4.5; % Changes the shape and dimension of the damage
        [r,~] = size(pc_side_rz);
        d1 = reset_value(obj_dloc(1), obj_dloc(2));
       d2 = obj_dloc(4); 
%        d2 =  obj_dimension(2)/pd; % ToDo change denominator to a variable
        d3 = reset_value(obj_dloc(3)-d2, obj_dloc(3)+d2);
        pc_side1 = zeros(r,3);
        for i = 1 : r
            if pc_degs(i,1)>=obj_dloc(1) && pc_degs(i,1)<=obj_dloc(2)...
                    && pc_side_rz(i,2)>=obj_dloc(3)-d2... % lowest location in z direction
                    && pc_side_rz(i,2)<=obj_dloc(3)+d2    % highest location in z direction
                n1=(obj_dimension(2)+obj_dlevel*...
                    (cosd(pc_degs(i,1)*d1(1)+d1(2))+...
                    rand*cosd(pc_side_rz(i,2)*d3(1)+d3(2))))... % ToDo make this a variable
                    *cosd(pc_degs(i,1));
                n2=(obj_dimension(2)+obj_dlevel*...
                    (cosd(pc_degs(i,1)*d1(1)+d1(2))+...
                    rand*cosd(pc_side_rz(i,2)*d3(1)+d3(2))))...
                    *sind(pc_degs(i,1));
                
                or1=obj_dimension(2)*cosd(pc_degs(i,1));
                or2=obj_dimension(2)*sind(pc_degs(i,1));
                if sqrt((n1)^2+(n2)^2) >= sqrt(or1^2+or2^2)
                    pc_side1(i,1) = or1;
                    pc_side1(i,2) = or2;
                else
                    pc_side1(i,1) = n1;
                    pc_side1(i,2) = n2;
                end
            else
                pc_side1(i,1)=obj_dimension(2)*cosd(pc_degs(i,1));
                pc_side1(i,2)=obj_dimension(2)*sind(pc_degs(i,1));
             end
            pc_side1(i,3)=pc_side_rz(i,2);
        end
        varargout{1} = pc_side1;
    else
        disp('Even distribution');
    end
end