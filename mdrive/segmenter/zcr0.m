
function [zcr0]=zcr0(segment)
    zc=0;
    for m=1:length(segment)-1
        if segment(m)*segment(m+1) > 0
            zc=zc+0;
        else
            zc=zc+1;
        end
        zcr=zc/length(segment);
    end
end


%% wassap boss
y=wavread('egobeta.wav');
plot(y);

