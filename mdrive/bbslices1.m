function [datasize,raw,categ] = bbslices1(range)


%% Importing and processing of the raw data 
% range = 0.1;
a = importdata('Damaged_Cylinder_threadbase2.txt');
a1 = downsample(a,5);
a0 = a(a(:,3)>-29 & a(:,3)<-7,:);
a2 = a1(a1(:,3)>-29 & a1(:,3)<-7,:);

%% Specifying the parameters for performing slicing
min_ = min(a2(:,3));    % the minimum range in z-axis
max_ = max(a2(:,3));    % the maximum range in z-axis
length = floor((max_ - min_)/range);    % splitting the model with equal sizes specified by the range 
% p = [];   
prep = {};
categ={};
close all;

%%
    for i = 1:length-1
        
        %%
       po = a0(a0(:,3)>=(min_ + ((i)*range)) & a0(:,3)<=(min_ + ((i+1)*range)),:);
       
        p = a2(a2(:,3)>=(min_ + ((i)*range)) & a2(:,3)<=(min_ + ((i+1)*range)),:);
        x1 = p(:,1);
        x2 = p(:,2);
        x1o = po(:,1);
        x2o = po(:,2);
        x3 = i*range;
        ps = [x1 x2];   % the x and y cordinates
        t = 0:360;
        bb = minBoundingBox(transpose(ps)); % using a 2D bounding box to remove outliers
        bbt = transpose(bb); % this gives the transpose of the bounding box
        bb = [bb [bb(1,1); bb(2,1)]];
        raw(i).height = x3;
        raw(i).sampled = p;
        raw(i).slice = po;
        raw(i).bb=bb;
        plot(bb(1,:),bb(2,:));
        dists = [pdist([bbt(1,:);bbt(2,:)],'euclidean') pdist([bbt(1,:);bbt(3,:)],'euclidean') pdist([bbt(1,:);bbt(4,:)],'euclidean')];
        dmax = max(dists);
        dave = (dists(1)+dists(3))/2;
        imax = 1+find(dists==dmax);
        if i==1
            x = (bbt(1,:) + bbt(imax,:))/2;  %formular for midpoint bw bb(1) and bb(imax)
        end
        xe = dave/2*sind(t)+x(1);
        ye = dave/2*cosd(t)+x(2);
        plot(xe,ye);hold on;
        plot(x(1),x(2),'o');hold off;
        
            
        % converting the slice into a straight line graph
        prep{i} = sqrt((x2-x(2)).^2 + (x1-x(1)).^2);        
        raw(i).frad=sqrt((x2o-x(2)).^2 + (x1o-x(1)).^2);
        raw(i).srad=prep{i};
        
        grid off
        set(gca,'XTick',[], 'YTick',[]);
        axis equal
        
        
        
%  %% classification the slices into categories
% 
%         answer = questdlg('Select Category', ...
%         'Slice Classification', ...
%         'good','damaged','cancel');
%         %  Handle response
%         switch answer
%             case 'good'
% %                 disp([answer 'we got a good one'])
%                 folder = "/good/profile";
%                 categ{i}="good";
%             case 'damaged'
% %                 disp([answer 'this is a damaged slice'])
%                 folder = "/damaged/profile";
%                 categ{i}="damaged";
%         end
%  % Saving the plots
%         v = pad(num2str(i),3,'left','0');
% %         fig=sprintf('C:/Users/Ebube/MATLAB Drive/Model_process/LSTM/exp%s%s.png',folder, v);
%         fig=sprintf('exp%s%s.png',folder, v);
%         saveCurrentFigure(fig,600);
    end
    %% straight line plot obtained from individual slices
    radii = 1440;
    slices = numel(prep);
    datasize = zeros(slices,radii);
    for i = 1:slices
        idata = floor(numel(prep{i})/(radii-1));
        arr = prep{i};
        rem = mod(numel(prep{i}),radii-1);
        for j = 1:radii
            if rem==0 && j==radii
                datasize(i,j) = datasize(i,j-1);
            end
            idx = idata*(j-1)+1;
            if j==radii
                datasize(i,j) = mean(arr(idx:idx+rem-1));
            else
                datasize(i,j) = mean(arr(idx:idx+idata-1));
            end
        end
    end
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% To do list %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create more intensive damage on the surface, project in X and Y directions, 
% see what  the difference is in comparison to the previous one, if points distribution 
% is more in areas of damage, perform edge detection on the image and see if the edge 
% operator can create a boundary on the region with more points distribution

% Will this work because edge detection uses colour varaition in establishing boundaries

%     if(i>0) 
%         co=xcorr2([po(:,1);po(:,2)],[p(:,1);p(:,2)]); 
%         co(1)
%     end