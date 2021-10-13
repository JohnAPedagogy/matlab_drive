function [svp]= segnview(s, sv, d)
  if(sv>s)
      t=s;
      s=sv;
      sv=t;
  end
  if(s<1 || sv < 1)
      print "Invalid Number of segments or view segment";
      return
  end
  dl=length (d);
  segs=zeros(1,s);
  segsize=floor(dl/s);
  plotterx=[];
  p2x=[];
  for(i=1:s)
     segs(i)=(i-1)*segsize+1; 
  end
  segsize
  j=1;
  for(i=segs(sv):segs(sv)+segsize)
     plotterx(j)=d(i);
     j=j+1;
  end
  for(i=1:dl)
    if i>=segs(sv) && i<segs(sv)+segsize
      p2x(i)=d(i);
    else
      p2x(i)=0;
    end
  end
  subplot(2,1,1); plot(plotterx);title(sprintf('plot of section %d of %d',sv,s));
  subplot(2,1,2); plot(d);title(strcat('plot of ','overlap'));
  hold on
  subplot(2,1,2);plot(p2x,'r');
  hold off
  svp=0; %segs;
end
