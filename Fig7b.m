%%  Map iters
% initial parameters
% close all;
INITs

% section location
sec_loc = [1; 1.72];
% sec_loc = [3; 1.72];

% Find IC on P'section.
[myIC, mycycle] = find_IC(@CNT_model, x0(1:end-1), p0, sec_loc);
%% 
dt = 1;
xspan = 0:dt:24;
yspan = 0:dt:24;
xx = meshgrid(xspan,yspan);
yy = xx';
icp = [xx(:) yy(:)];

%  icp = [12 5; 12 12; 12 2];
 Iter_all = {};
 Max = 3;
 figure;
 for i = 1:length(icp)
     Iter = []; N = 1;
     x0 = icp(i,:);
     Iter = [Iter; x0];
     while (N<Max)
        [y1, y2, ~, ~] = map2D_general_phase(x0(1), x0(2), @CNT_model, mycycle, myIC, p0, sec_loc);
        Iter = [Iter; [y1 y2]];
        x0 = [y1 y2];
        N = N+1;
     end
     Iter_all(end+1) = {Iter};
     
     dxy= Iter(2:end,:) - Iter(1:end-1,:);
     dxy= cat(1,dxy,[0 0]);
     dx= dxy(:,1);  dy= dxy(:,2);
     L= sqrt(dx.^2+dy.^2);
     for s= 1:length(L)
         if L(s)>15
             L(s)=-L(s);
         end
     end
     quiver(Iter(:,1),Iter(:,2),dx./L/1,dy./L/1,0,'k','LineWidth',1.5);
%      labels=  cellstr(num2str([1:Max]'));
%      text(Iter(:,1),Iter(:,2),labels,'FontSize',20);
     hold on
 end
% grid on;
axis([0 24 0 24]);
xticks(0:4:24);    yticks(0:4:24);
xlabel('x'); ylabel('y');