clear all; close all

load("fig9.mat");

% Pi_entrain=data.Pi_entrain;

c_Pi_b = zeros(size(Pi_entrain));
c_Pi_s = zeros(size(Pi_entrain));
c_Pi = zeros(size(Pi_entrain));
for i = 1:length(Pi_entrain)
    c_Pi(round(Pi_entrain(:,i),1)>round(Pi_entrain(12,i),1),i) = -1;
    c_Pi(round(Pi_entrain(:,i),1)<round(Pi_entrain(12,i),1),i) = 1;
end

c_b = sum(c_Pi == -1);
c_s = sum(c_Pi == 1); 


%% added by COD 11-29-23

c_n = sum(c_Pi == 0);

c_hurts = 100*(c_b/49);
c_helps = 100*(c_s/49);
c_neutral = 100*(c_n/49);

y = [c_helps; c_neutral; c_hurts];

sub_y = [c_helps; c_neutral];

figure;
tiledlayout(2,2)

dt = .5;
xspan = 0:dt:24;
yspan = 0:dt:24;
[xx, yy] = meshgrid(xspan,yspan);
Pi_entrain_rep = repmat(Pi_entrain(12,:), length(Pi_entrain),1);
Pi_entrain_diff = Pi_entrain - Pi_entrain_rep;

ax1 = nexttile;
surf(xx,yy,-Pi_entrain_diff); %shading flat;
colormap(ax1,parula);
view(0, 90);
colorbar;
xlim([0 24]);   ylim([0 24]);
xticks(0:4:24);    yticks(0:4:24);
xlabel(['LD',newline,'(a)']);    ylabel("O_2");

ax2 = nexttile();
pcolor(xx,yy,c_Pi);
colormap(ax2,gray); 
% colorbar;
xlim([0 24]);   ylim([0 24]);
xticks(0:4:24);    yticks(0:4:24);
xlabel(['LD',newline,'(b)']);    ylabel("O_2");


nexttile([1 2])
b=bar(sub_y','stacked','FaceColor','flat');
b(1).CData = [62 150 81]/255;
b(2).CData = [.8 .8 .8];
set(gca, 'XTick', [0:8:49],'YTick',0:25:100)
set(gca, 'XTickLabel', [0:8:49]/2)
ylabel('% of initial O_2 phases')
xlabel('LD phase')
legend('beneficial','neutral','location','northwest')
legend('boxoff')
