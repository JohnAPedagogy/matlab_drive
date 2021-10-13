function [pos, neg]= align(f)
  masize=5000;
  pval=[];          % array for positive values (averaged over absolut value of negative counterparts
  nval=[];
  uval=[];          % array for no of up counts
  dval=[];
  ma=[];
  upc=0;
  dnc=0;
  uparr=[];
  dnarr=[];
  thresh=7;
  % d=wavread (f);
  d=audioread(f);
  dl=length (d);
  for(i=1:dl)
     if d(i)<=0 
       nval(i)=d(i);
       if i>1 
         pval(i)=pval(i-1);
       end
     else
       pval(i)=d(i);
       if i>1
         nval(i)=nval(i-1);
       end
     end
  end
  fprintf('Doing averaging\n');
  if length(pval)<length(nval)
      dl=length(pval);
  else
      dl=length(nval);
  end
  for i=1:dl
      pval(i)=(pval(i)+ abs(nval(i)))/2;
  end
  
  fprintf('doing avg filter\n');
  for i=1:dl
    uval(i)=0;
    dval(i)=0;
    if(i<dl-masize)
        if pval(i)<mean(pval(i:i+masize))
            uparr(i)=1;
            if i>1 % first ensure that you on the second index so that d(i)==d(i-1) will work
                t=true;
                if uparr(i)==uparr(i-1)
                    upc=upc+1;
                else
                    uval(i)=upc;
                    upc=0;
                    t=false;
                end
                if t
                    uval(i)=uval(i-1);
                end
            end
        else
            uparr(i)=0;
            if i>1 % first ensure that you on the second index so that d(i)==d(i-1) will work
                t=true;
                if uparr(i)==uparr(i-1)
                    dnc=dnc+1;
                else
                    dval(i)=dnc;
                    dnc=0;
                    t=false;
                end
                if t
                    dval(i)=dval(i-1);
                end
            end
        end
        ma(i)=mean(pval(i:i+masize));
    end
  end
  thresh=thresh/10^floor(log(thresh));    
  subplot(4,1,1); plot(pval);title('positive values');
  subplot(4,1,2); plot(ma);title('averaged values');
  subplot(4,1,3); plot(uval);title('up counter');
  subplot(4,1,4); plot(dval);title('down counter');
  pos=uval;
  neg=ma;
end
