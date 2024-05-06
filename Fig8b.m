% close all;
dt= .05;
days= 20;
tf= 10*days;
Tspan= 0:dt:tf;

phi1= 2.1; phi2= 2.1;
eps1= 0.05; eps2= 0.05;
kD= .05; kf= 1;
%--------------------------------------
kL1= 0.05; kL2= 0.05;    % control light
alpha1= .9; alpha2= .9;    % control coupling.

% To control light phase, change the inits. of x(end).
%-----------------------------------------
p0= [phi1;phi2;eps1;eps2;kD;kf;kL1;kL2;alpha1;alpha2];
x0= [4.37;0.6685;1.705;0.1548; 0];
%% Solve
% tstart = now;
tic;
[myIC, mycycle] = find_IC(@CNT_model, [4.37;0.6685;1.705;0.1548], p0, [1; 1.7199]);
toc;

%% entrained solutions.
Ophase = 12;
y0 = mycycle(Ophase);
% y0 = myIC;
opt = odeset('AbsTol',1e-8,'RelTol',1e-8);

[T0,Y0] = ode15s(@(t,x) CNT_model(t,x,p0),Tspan,y0,opt);
%% Produce fig 8b
% x=12, y=12
f= @(t) heaviside(sin((t)*pi/12));
LDphase_shift = 12;
O1phase_shift = myIC(end);
O2phase_shift = 12;

y1 = mycycle(O1phase_shift);   
y2 = mycycle(O2phase_shift); 
yLD = mycycle(LDphase_shift);

y0_bar = [y1(1:2); y2(3:4); yLD(end)];
[T1,Y1] = ode15s(@(t,x) CNT_model(t,x,p0),Tspan,y0_bar,opt);

% x=12, y=5
LDphase_shift = 12;
O1phase_shift = myIC(end);
O2phase_shift = 5;

y1 = mycycle(O1phase_shift);
y2 = mycycle(O2phase_shift); 
yLD = mycycle(LDphase_shift);

y0_bar = [y1(1:2); y2(3:4); yLD(end)];
[T2,Y2] = ode15s(@(t,x) CNT_model(t,x,p0),Tspan,y0_bar,opt);

% x=12, y=2
LDphase_shift = 12;
O1phase_shift = myIC(end);
O2phase_shift = 2;

y1 = mycycle(O1phase_shift);
y2 = mycycle(O2phase_shift); 
yLD = mycycle(LDphase_shift);

y0_bar = [y1(1:2); y2(3:4); yLD(end)];
[T3,Y3] = ode15s(@(t,x) CNT_model(t,x,p0),Tspan,y0_bar,opt);

figure
fig = tiledlayout(3,1);
title_name = ["x=12, y=12", "x=12, y=5", "x=12, y=2"];

YLD = f(Y0(:,end));

nexttile()
% Y2(:,end) = f(Y2(:,end));
plot(T2,Y2(:,[1 3]));
hold on
plot(T0, Y0(:,1), 'k');
plot(T0, YLD);
% legend('P1','M1','P2','M2','LD');
title(title_name(2), 'FontSize', 16);
xlim([0 72]);
xticks(0:24:72);
ylim([0 5]);
ylabel('P');
legend(["P_1","P_2","Entrained reference"],'Orientation', 'horizontal')

nexttile()
% Y1(:,end) = f(Y1(:,end));
plot(T1,Y1(:,[1 3]));
hold on
plot(T0, Y0(:,1), 'k');
plot(T0, YLD);
% legend('P1','M1','P2','M2','LD');
% legend('P1','P2','Entrained P','LD', 'Orientation','horizontal');
title(title_name(1), 'FontSize', 16);
xlim([0 72]);
xticks(0:24:72);
ylim([0 5]);
ylabel('P');

nexttile()
% Y3(:,end) = f(Y3(:,end));
plot(T3,Y3(:,[1 3]));
hold on
plot(T0, Y0(:,1), 'k');
plot(T0, YLD);
% legend('P1','M1','P2','M2','LD');
title(title_name(3), 'FontSize', 16);
xlim([0 72]);
xticks(0:24:72);
ylim([0 5]);
ylabel('P');

xlabel(fig, "t (hrs)", 'FontSize', 16);
% ylabel(fig, "O_2", 'FontSize', 16)
% title(fig2, "O_1 only re-entrainment time", 'FontSize', 16);