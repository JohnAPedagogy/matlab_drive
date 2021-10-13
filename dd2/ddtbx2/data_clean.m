function [x,y]=data_clean(a,w)
    a(a==-999)=0;
    a( any(a==0,2), : ) = [];  %rows
    a( any(isnan(a),2), : ) = [];  %rows
    a( :, any(isnan(a),1) ) = [];  %columns
    a( :, ~any(a,1) ) = [];  %columns

    [classes, class]=clean_getpoints(w);
    
    categ = num2cell(classes,1);
    categ(classes<=class+1 ) ={"good"}; 
    categ(classes>class+1) = {"damaged"};
    
    x=a;
    y=categ;

end