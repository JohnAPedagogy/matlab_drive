function z=xcor(x,y)
    i=0;j=0;
    n=length(y);
    for i=1:n
        sum=0;
        for k=1:n
           sum=sum+x(k)*y(k+j);
        end
        z(i)=sum/length(y);
        n=n-1;
        j=j+1;
        if n==0
            break;
        end
    end
    z
end