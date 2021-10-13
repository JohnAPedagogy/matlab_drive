% Example:
%   data = damaged_cylinder_pc([3,5],0.1,0.00002,1,[0,90, 1.5],0.5);
%   pcshow(data);view(0,90)

function varargout = damaged_cylinder_pc_v2(varargin)
    % Para1: dimension <height, radius>
    % Para2: chaos level
    % Para3: point density float value (0 - 1)
    % Para4: bool - random sampling or even
    % Para5: damaged_location [theta1, theta2] (specified in 0 - 360 degs)
    obj_dimension = varargin{1};
    obj_chaos_level = varargin{2};
    obj_density = varargin{3};
    obj_dloc = varargin{5};
    obj_dlevel = varargin{6};
    obj_scanner_noise = varargin{7};
    
    if varargin{4}
        disp('Gaussian Distribution');
        
        % Bottom and Top
        pc_size = floor(1/obj_density);   
        
        % Side Wall Unwrapped PC
        pc_side_rz = [rand(pc_size,1)*2*pi*obj_dimension(2),...
            rand(pc_size, 1)*obj_dimension(1)];
        pc_degs = (pc_side_rz(:,1)/(2*pi*obj_dimension(2)))*360;
        
        [r,~] = size(pc_side_rz);
        d1 = reset_value(obj_dloc(1), obj_dloc(2));
        d2 = obj_dimension(2)/10; %extent of damage on z axis. The 10 is the radius value
        d3 = reset_value(obj_dloc(3)-d2, obj_dloc(3)+d2);
        pc_side1 = zeros(r,3);
        for i = 1 : r
            if pc_degs(i,1)>=obj_dloc(1) && pc_degs(i,1)<=obj_dloc(2)...
                    && pc_side_rz(i,2)>=obj_dloc(3)-d2...
                    && pc_side_rz(i,2)<=obj_dloc(3)+d2
                n1=(obj_dimension(2)+obj_dlevel*...
                    (cosd(pc_degs(i,1)*d1(1)+d1(2))+...
                    rand*cosd(pc_side_rz(i,2)*d3(1)+d3(2))))...
                    *cosd(pc_degs(i,1));
                n2=(obj_dimension(2)+obj_dlevel*...
                    (cosd(pc_degs(i,1)*d1(1)+d1(2))+...
                    rand*cosd(pc_side_rz(i,2)*d3(1)+d3(2))))...
                    *sind(pc_degs(i,1));
                
                or1=obj_dimension(2)*cosd(pc_degs(i,1));
                or2=obj_dimension(2)*sind(pc_degs(i,1));
                
                if sqrt((n1)^2+(n2)^2) >= sqrt(or1^2+or2^2)
                    pc_side1(i,1) = or1+rand()*obj_scanner_noise;
                    pc_side1(i,2) = or2+rand()*obj_scanner_noise;
                else
                    pc_side1(i,1) = n1+rand()*obj_scanner_noise;
                    pc_side1(i,2) = n2+rand()*obj_scanner_noise;
                end
            else
                pc_side1(i,1)=obj_dimension(2)*cosd(pc_degs(i,1))+...
                    rand()*obj_scanner_noise;
                pc_side1(i,2)=obj_dimension(2)*sind(pc_degs(i,1))+...
                    rand()*obj_scanner_noise;
            end
            pc_side1(i,3)=pc_side_rz(i,2);
        end
        
        % Point Cloud Output
        varargout{1} = pc_side1;
        
        % Precise Damage Z Height Location
        varargout{2} = [-d2, d2];
        
        % Horizontal Location
        varargout{3} = d1;
        
    else
        disp('Even distribution');
    end
end