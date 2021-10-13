function value = class_value(array)
    disp(['**Data Preparation: Deriving value from array']);
    
    % Input 1: Matrix
prev =0;
count=0;
for i = 1 : length(array)
     if prev==array(i)
         count=count+1;
     else
         count=0;
     end
     if count == 29
         value = array(i);
         return
     end
     prev=array(i);
end
    value = -1;
end