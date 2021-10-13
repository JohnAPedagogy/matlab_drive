function varargout = DataPre_normalize_image(varargin)
    disp(['**Data Preparation: Create a matrix suitable for show as',...
        'image.']);
    
    % Input 1: Matrix
    % Input 2: Color max coefficient: e.g. 250 or 1
    InputData = varargin{1};
    OutputData = zeros(1,1);
    max_value = max(max(InputData));
    min_value = min(min(InputData));
    [m,n] = size(InputData);
    if length(varargin) == 2
        for i = 1 : m
            for j = 1 : n
                OutputData(i,j) = ((InputData(i,j)-min_value)/...
                                    (max_value-min_value))*varargin{2};
            end
        end
    elseif length(varargin) == 1
        for i = 1 : m
            for j = 1 : n
                OutputData(i,j) = ((InputData(i,j)-min_value)/...
                                    (max_value-min_value));
            end
        end
    else
        disp("DataPre_normalize_image function got an invalid input!");
    end
    varargout{1} = OutputData;
end