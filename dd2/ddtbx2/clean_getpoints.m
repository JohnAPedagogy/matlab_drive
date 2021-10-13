function [classes,class] = clean_getpoints(wdatay)

    % ck0 = [zeros(11,1); wdatay];
    % ck1 = movmean(ck0,35);
    ck1=round(wdatay);
    class  = class_value(ck1);
    classes=ck1;

end

% TO CLEAN THE DATA - remove zero rows and columns
% temp_data( any(temp_data==0,2), : ) = [];  %rows
% temp_data( :, ~any(temp_data,1) ) = [];  %columns

% Classification
% temp_class = zeros(1,200);
% temp_class(86:135)=1;
% categ = num2cell(temp_class,1);
% categ(temp_class==0 ) ={"good"}; 
% categ(temp_class==1) = {"damaged"}; 
