clear;clc;

load('lstm_data3_unclassified.mat');
data = downsample(a, 10);
zran = 0.1;
ran = 15;
height = -30;

pcshow(data)
subplot(211)
p1 = plot3(0, 0, 0, '.', 'Color', 'g');
view(90,90);
axis equal;
xlim([-1 * ran ran]);
ylim([-1 * ran ran]);
subplot(212)
p2 = plot3(data(:,1), data(:,2), data(:,3), '.', 'Color', 'b');hold on;
p3 = plot3(0, 0, 0, 'o', 'Color', 'g');hold off;
axis equal;
xlim([-1 * ran ran]);
ylim([-1 * ran ran]);


while height < 0.5
    height = height + 0.1;
%     tmp_pc = data(data(:,3)>height-0.3 & data(:,3)<height+0.3, :);
    try
        tmp_pc = data(data(:,3)>height-zran & data(:,3)<height+zran, :);
        tmp_pc = downsample(tmp_pc, 5);
        set(p1, 'xdata', tmp_pc(:,1), 'ydata', tmp_pc(:,2), 'zdata', tmp_pc(:,3));
        set(p3, 'xdata', tmp_pc(:,1), 'ydata', tmp_pc(:,2), 'zdata', tmp_pc(:,3));
    catch e
        disp(e);
    end
    drawnow;
    pause(0.5)
end