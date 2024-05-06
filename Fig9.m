clear all; close all

load("datas/fig9.mat");

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


%%

c_n = sum(c_Pi == 0);

c_hurts = 100*(c_b/49);
c_helps = 100*(c_s/49);
c_neutral = 100*(c_n/49);

y = [c_helps; c_neutral; c_hurts];

sub_y = [c_helps; c_neutral];


figure(12)
b=bar(y','stacked','FaceColor','flat');
b(1).CData = [62 150 81]/255;
b(2).CData = [.7 .7 .7];
b(3).CData = [204 37 41]/255;
set(gca, 'XTick', [0:8:49])
set(gca, 'XTickLabel', [0:8:49]/2)



figure(13)
b=bar(sub_y','stacked','FaceColor','flat');
b(1).CData = [62 150 81]/255;
b(2).CData = [.8 .8 .8];
set(gca, 'XTick', [0:8:49],'YTick',0:25:100)
set(gca, 'XTickLabel', [0:8:49]/2)
ylabel('% of initial O_2 phases')
xlabel('LD phase')
legend('beneficial','neutral','location','northwest')
legend('boxoff')

