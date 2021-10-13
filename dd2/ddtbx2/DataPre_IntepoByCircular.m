function varargout = DataPre_IntepoByCircular(varargin)
    % Input 1: 2D Slice Matrix
    % Input Matrix: each column is a slice
    % Input 2: Slice Array Order Format in Matrix
    
    InputData_angles = varargin{1};
    InputData_radius = varargin{2};
    SliceMat_Format = varargin{3};
    DefinedResolution = varargin{4};
    
    if sum(size(InputData_angles)==size(InputData_radius))==2
        % Remove NaN
        InputData_angles(InputData_angles==-999)=nan;
        InputData_radius(InputData_radius==-999)=nan;
        
        if SliceMat_Format == 1
            InputData_angles = InputData_angles';
            InputData_radius = InputData_radius';
        end

        % Initialization of Output Matrix
        [r,c] = size(InputData_angles);
        formatted_angles = 0:DefinedResolution:360;
        Output_Data = zeros(length(formatted_angles),c);   
        % This output data is radius calculated with interporation method from original data.
        
        
        for ColNO = 1 : c
            nan_no=sum(isnan(InputData_angles(:,ColNO)));
            tempArr = interp1(InputData_angles(1:r-nan_no,ColNO),...
                                InputData_radius(1:r-nan_no,ColNO),...
                                formatted_angles);
            %   Vq  = INTERP1(X,V,Xq) interpolates to find Vq, the values of the
            %   underlying function V=F(X) at the query points Xq.
            %   Vq = tempArr; X = InputData_angles; V= InputData_radius; Xq = formatted_angles 
              
%             tempArr  = unique(InputData_radius);
%             tempArr = linspace(min(tempArr), max(tempArr), max(tempArr) - min(tempArr) + 1);
%             tempArr2  = unique(tempArr1);
            Output_Data(:,ColNO) = tempArr;
        end
        varargout{1} = Output_Data;
    else
        disp('Invalid Inputs Detected!');z
    end
end