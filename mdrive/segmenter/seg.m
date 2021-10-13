
zes = find([1,2,3,5,0,0,0,3,5,3,0,0,0,]==0);
c = 0;
a = [];
for i=1:length(zes)
    if i>1 && zes(i) - zes(i-1) > 1
        c = c + 1;
        a(c) = i;
    end
end
%% 

[pos,neg] = align('egobeta.wav');
b = neg(20000:40000);
%% 

z = xcorr(neg,b);
% figure
%% 

subplot(3,1,1); plot(neg);title('Smoothed signal');
subplot(3,1,2); plot(b);title('plot of first peak-to-trough');
subplot(3,1,3); plot(z);title('Correlation plot');

