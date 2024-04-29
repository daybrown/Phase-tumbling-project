%% Inits.
clearvars;
% close all;
INITs
%% Solve
% tstart = now;
tic;
% sec_loc1 = [2; 0.45];
% sec_loc2 = [4; 0.44];
sec_loc1 = [1; 1.7199];
sec_loc2 = [3; 1.72];
sec_loc3 = [1; 1.72; 3; 1.72];
[myIC, mycycle] = find_IC(@CNT_model, [4.37;0.6685;1.705;0.1548], p0, sec_loc1);
toc;

%% 2D entrain time only
dt = .5;
xspan = 0:dt:24;
yspan = 0:dt:24;
[xx, yy] = meshgrid(xspan,yspan);
% xx: phase of LD;  yy: phase of O2
zz = [xx(:) yy(:)];

%
kL_range = [0.05];
% kL_range = [0.03 0.05 0.06 0.07 0.08];
% alpha_range = [0.0 0.05 0.1 0.2 0.4 0.7 0.9];
alpha1_range = [0 0.9];
alpha2_range = [0 0.9];
[par_kL, par_alpha1, par_alpha2] = meshgrid(kL_range, alpha1_range, alpha2_range);
par_unroll = [par_kL(:) par_alpha1(:) par_alpha2(:)];
T_all = {};
tic;
for i = 1:size(par_unroll,1)
    
Pi = zeros(size(zz));
Pi_entrain = Pi(:,1);

Pi_entrain_O1 = Pi(:,1);
Pi_entrain_O2 = Pi(:,1);

kL1= par_unroll(i,1); 
kL2= kL1;    % control light
alpha1= par_unroll(i,2); 
alpha2= par_unroll(i,3);    % control coupling.
p0= [phi1;phi2;eps1;eps2;kD;kf;kL1;kL2;alpha1;alpha2];
[myIC, mycycle] = find_IC(@CNT_model, [4.37;0.6685;1.705;0.1548], p0, sec_loc1);

    parfor j = 1:length(zz)
        y1 = myIC(1:2);
        y2 = mycycle(zz(j,2));  y2 = y2(3:4);
        yLD = mycycle(zz(j,1)); yLD = yLD(end);
        x0 = [y1; y2; yLD];
        
        [t_entrain, t_entrain_O1, t_entrain_O2] = map_checktime_C(@CNT_model, x0, p0, sec_loc3);
        
%         t_entrain = map_checktimeN(@CNT_model, x0, p0, sec_loc1, myIC);
        Pi_entrain(j) = t_entrain;
        
        Pi_entrain_O1(j) = t_entrain_O1;
        Pi_entrain_O2(j) = t_entrain_O2;
    %     [y, t_return] = map_general(@CNT_model, x0, p0, sec_loc);
    %     Pi_return(i) = t_return(end);
    end

T_all(end+1) = {[Pi_entrain Pi_entrain_O1 Pi_entrain_O2]};
end
toc;
% For data saving-------------------------------
Etime_cd = struct();
Etime_cd.data = T_all;
Etime_cd.pars = par_unroll;
Etime_cd.mesh = {xx,yy};
% state about coupling style.
% Etime_cd.coupling = 'bidirectional';\

%% Plot three types of entrain time, figure 4 of the paper.-----------------------

% to see result directly, uncomment the next line.
% load('Etime_20230805.mat');

figure;
fig = tiledlayout(4,3);
xx = Etime_cd.mesh{1};
yy = Etime_cd.mesh{2};
orderfig = 'a':'l';
ordercount = 0;
fignow = 0;
for j = 1:4
    T_e = Etime_cd.data{j};
%     figure;
%     fig = tiledlayout(1,3);
    big_title = ["uncoupled", "O_1 \leftarrow O_2", "O_1 \rightarrow O_2", "O_1 \leftrightarrow O_2"];
    title_name = ["Total", "O_1", "O_2"];
    for i = 1:size(T_e,2)
        Pi_entrain = reshape(T_e(:,i),size(xx));
    %     Pi_entrain = reshape(T_diff(:,1),size(xx));   
        nexttile()
        pcolor(xx,yy,Pi_entrain); shading interp; hold on;
%         surf(xx,yy,Pi_entrain); shading interp;
%         view(0, 90);
        set(gca,'FontSize',8, 'FontWeight','bold');
        colormap(jet(17))
        caxis([0 408]);
        xticks([0:4:24]);
        yticks([0:4:24]);
        xlim([0 24]);   ylim([0 24]);
        if j == 1
            title(title_name(i))
        end
        ordercount = ordercount+1;
        xlabel("("+orderfig(ordercount)+")");
        fignow = fignow + 1;
        if mod(fignow,3) == 1
            ylabel(big_title(j));
            plot(14.5, 9.5, 'k.', 'MarkerSize',16);
        end
        hold off;
    end
%     hold off;
end
% xlabel(fig, "LD", 'FontSize', 16)
% ylabel(fig, "O_2", 'FontSize', 16)
title(fig, "Re-entrainment time", 'FontSize', 12, 'FontWeight','bold');
cbh = colorbar ; %Create Colorbar
cbh.Ticks = linspace(0, 408, 18);
cbh.TickLabels = num2cell(0:1:17);
cbh.Layout.Tile = 'east';

fig.TileSpacing = 'compact';
fig.Padding = 'compact';

%% map and heat map for last figure;

T_all = Etime_cd.data;
par_unroll = Etime_cd.pars;
xx = Etime_cd.mesh{1};
yy = Etime_cd.mesh{2};
figure;
i = 4;
Pi_entrain = reshape(T_all{i}(:,1),size(xx));
surf(xx,yy,Pi_entrain); shading interp;
view(0, 90);
colormap(jet(17))
caxis([0 408]);
xlim([0 24]);   ylim([0 24]);
xticks(0:4:24);    yticks(0:4:24);
% view(0, 90);
cbh = colorbar ; %Create Colorbar
cbh.Ticks = linspace(0, 408, 18);
cbh.TickLabels = num2cell(0:1:17);
% hold on


%% The figure 9.----------------------------------------------------------------

c_Pi_b = zeros(size(Pi_entrain));
c_Pi_s = zeros(size(Pi_entrain));
c_Pi = zeros(size(Pi_entrain));
for i = 1:length(Pi_entrain)
    c_Pi(round(Pi_entrain(:,i),1)>round(Pi_entrain(12,i),1),i) = -1;
    c_Pi(round(Pi_entrain(:,i),1)<round(Pi_entrain(12,i),1),i) = 1;
end

c_b = sum(c_Pi == -1);
c_s = sum(c_Pi == 1); 

figure;
fig = tiledlayout(2,2);
Pi_entrain_rep = repmat(Pi_entrain(12,:), length(Pi_entrain),1);
Pi_entrain_diff = Pi_entrain - Pi_entrain_rep;
nexttile()
surf(xx,yy,-Pi_entrain_diff); %shading flat;
colormap(gray); 
view(0, 90);
colorbar;
xlim([0 24]);   ylim([0 24]);
xticks(0:4:24);    yticks(0:4:24);
xlabel("LD");    ylabel("O_2");

nexttile();
pcolor(xx,yy,c_Pi);
colormap(gray); 
colorbar;
xlim([0 24]);   ylim([0 24]);
xticks(0:4:24);    yticks(0:4:24);
xlabel("LD");    ylabel("O_2");

c_n = sum(c_Pi == 0);

c_hurts = 100*(c_b/49);
c_helps = 100*(c_s/49);
c_neutral = 100*(c_n/49);

y = [c_helps; c_neutral; c_hurts];

sub_y = [c_helps; c_neutral];

nexttile([1 2])
b=bar(sub_y','stacked','FaceColor','flat');
b(1).CData = [62 150 81]/255;
b(2).CData = [.7 .7 .7];
% b(3).CData = [204 37 41]/255;
ylabel('% of initial O_2 phases')
xlabel('LD phase')
set(gca, 'XTick', [0:8:49])
set(gca, 'XTickLabel', [0:8:49]/2)
legend('beneficial','neutral','location','northwest')
legend('boxoff')
%% plots total etime
T_all = Etime_cd.data;
par_unroll = Etime_cd.pars;
xx = Etime_cd.mesh{1};
yy = Etime_cd.mesh{2};


% Plot both entrain time, use column 1 of T_all-----------------

figure;
fig1 = tiledlayout(2,2);
title_name = ["No coupling", "O_1 <= O_2", "O_1 => O_2", 'O_1 <=> O_2'];
for i = 1:length(T_all)
    Pi_entrain = reshape(T_all{i}(:,1),size(xx));
%     Pi_entrain = reshape(T_diff(:,1),size(xx));   
    nexttile()
%     pcolor(xx,yy,Pi_entrain); shading interp;
    surf(xx,yy,Pi_entrain); shading interp;
    colormap(jet(17))
    title(title_name(i), 'FontSize', 16)
    caxis([0 408]);
    xlim([0 24]);   ylim([0 24]);
    view(0, 90);
end
xlabel(fig1, "LD", 'FontSize', 16)
ylabel(fig1, "O_2", 'FontSize', 16)
title(fig1, "Total re-entrainment time", 'FontSize', 16);
cbh = colorbar ; %Create Colorbar
cbh.Ticks = linspace(0, 408, 18);
cbh.TickLabels = num2cell(0:1:17);
cbh.Layout.Tile = 'east';
% figure;
% plot(xspan,Pi_entrain(7,:)/24); % at O2 phase = 10.5

%% Plot O1 entrain time, use column 2 of T_all---------------------------
figure
fig2 = tiledlayout(2,2);
title_name = ["No coupling", "O_1 <= O_2", "O_1 => O_2", 'O_1 <=> O_2'];
for i = 1:length(T_all)
    Pi_entrain = reshape(T_all{i}(:,2),size(xx));
    nexttile()
    surf(xx,yy,Pi_entrain); shading interp;
    colormap(jet(17))
    title(title_name(i), 'FontSize', 16)
    caxis([0 408]);
    xlim([0 24]);   ylim([0 24]);
    view(0, 90);
end
xlabel(fig2, "LD", 'FontSize', 16)
ylabel(fig2, "O_2", 'FontSize', 16)
title(fig2, "O_1 only re-entrainment time", 'FontSize', 16);
cbh = colorbar ; %Create Colorbar
cbh.Ticks = linspace(0, 408, 18);
cbh.TickLabels = num2cell(0:1:17);
cbh.Layout.Tile = 'east';

%% Plot O2 entrain time, use column 3 of T_all---------------------------
figure;
fig3 = tiledlayout(2,2);
title_name = ["No coupling", "O_1 <= O_2", "O_1 => O_2", 'O_1 <=> O_2'];
for i = 1:length(T_all)
    Pi_entrain = reshape(T_all{i}(:,3),size(xx));
    nexttile()
    surf(xx,yy,Pi_entrain); shading interp;
    colormap(jet(17))
    title(title_name(i), 'FontSize', 16)
    caxis([0 408]);
    xlim([0 24]);   ylim([0 24]);
    view(0, 90);
end
xlabel(fig3, "LD", 'FontSize', 16)
ylabel(fig3, "O_2", 'FontSize', 16)
title(fig3, "O_2 only re-entrainment time", 'FontSize', 16);
cbh = colorbar ; %Create Colorbar
cbh.Ticks = linspace(0, 408, 18);
cbh.TickLabels = num2cell(0:1:17);
cbh.Layout.Tile = 'east';

%% Box chart plot, alternative figure for figure 5.--------------------------------
T_all = Etime_cd.data;
Etime_all = [];
Etime_O1 = [];
Etime_O2 = [];
for i = 1:length(T_all)
    Etime_all = [Etime_all T_all{i}(:,1)];
    Etime_O1 = [Etime_O1 T_all{i}(:,2)];
    Etime_O2 = [Etime_O2 T_all{i}(:,3)];
end
% for daily marks
Etime_all = Etime_all / 24;
Etime_O1= Etime_O1 / 24;
Etime_O2 = Etime_O2 / 24;
%--------------------------------

figure;
fig = tiledlayout(1,3);
xname = {'uncoupled', 'O_1 \leftarrow O_2', 'O_1 \rightarrow O_2', 'O_1 \leftrightarrow O_2'};

nexttile;
boxchart(Etime_all);
hold on
mean1 = mean(Etime_all);
plot(mean1, '-o');
hold off
title('Total Re-entrainment time', 'FontSize', 14);
xticklabels(xname);

nexttile
boxchart(Etime_O1);
hold on
mean2 = mean(Etime_O1);
plot(mean2, '-o');
hold off
title('O_1 Re-entrainment time', 'FontSize', 14);
% ylabel('Re-entrainment time');
% xlabel('Coupling style');
xticklabels(xname);


nexttile;
boxchart(Etime_O2);
hold on
mean3 = mean(Etime_O2);
plot(mean3, '-o');
hold off
title('O_2 Re-entrainment time', 'FontSize', 14);
% ylabel('Re-entrainment time');
% xlabel('Coupling style');
xticklabels(xname)

ylabel(fig, 'Re-entrainment time (days)', 'FontSize', 14);
xlabel(fig, 'Coupling style', 'FontSize', 14);
fig.TileSpacing = 'compact';
fig.Padding = 'compact';
