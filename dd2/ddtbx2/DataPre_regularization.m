function varargout = DataPre_regularization(varargin)
    % Input 1: original data, assembly matrix of all sequence
    % Input 2: defined length
    %           Case 1 - "max": if over the definition, the sequence
    %               will use 0 for filling
    %           Case 2 - "min": if less than original length, the
    %               sequence will be downsample to the defined
    %               length
    %           Case 3: if this input is NULL, the sequence
    %               length will use "min" case
    
    % Output:
    % Will be the assembly matrix of regularised slice sequence
    OriginalData = varargin{1};
    Sequence_Length = varargin{2};
    
    if length(varargin) == 2
        if varargin{2} == "min"
            
        elseif varargin{1} == "max"
        else
        end
    else
        disp('Invalid Inputs');
    end
end