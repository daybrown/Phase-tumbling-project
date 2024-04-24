%% Inits.
INITs;
% clearvars;
% close all;
dt= .05;
days= 10;
tf= 24*days;
Tspan= 0:dt:tf;

% Tspan= 0:-dt:-tf;    % try backward integration

phi1= 2.1; phi2= 2.1;
eps1= 0.05; eps2= 0.05;
kD= .05; kf= 1;
%--------------------------------------
kL1= 0.05; kL2= 0.05;    % control light
alpha1= 0.9; alpha2= 0.9;    % control coupling.

tic;
% sec_loc1 = [2; 0.45];
% sec_loc2 = [4; 0.44];
sec_loc1 = [1; 1.72];
% sec_loc2 = [3; 1.72];
[myIC, mycycle] = find_IC(@CNT_model, [4.37;0.6685;1.705;0.1548], p0, sec_loc1);
toc;
% To control light phase, change the inits. of x(end).
%-----------------------------------------
p0= [phi1;phi2;eps1;eps2;kD;kf;kL1;kL2;alpha1;alpha2];
% x0= [4.37;0.6685;1.705;0.1548; 0];
y1 = myIC(1:2);
y2 = mycycle(3.5);  y2 = y2(3:4);
yLD = mycycle(12); yLD = yLD(end); x0 = [y1; y2; yLD];  %19.8 or 21.8
%% Solve
% options= odeset('AbsTol',1e-8,'RelTol',1e-8,'Events',@Event_section);
% options= odeset('AbsTol',1e-8,'RelTol',1e-8,'Events',@Event_Tperiod);
% [t,y,TE,YE]= ode15s(@(t,x) model_CNT(t,x,p0),Tspan,x0,options);
% [t,y]= ode15s(@(t,x) model_CNT(t,x,p0,'LD'),Tspan,x0);
% returntime = TE(2:end) - TE(1:end-1);

%% default solver
% tstart = now;
sec_loc = [1; 1.72];
opt = odeset('AbsTol',1e-10,'RelTol',1e-10,'Events',@(t,y) section(t,y,sec_loc));
opt1 = odeset('AbsTol',1e-10,'RelTol',1e-10,'Events',@(t,y) section1(t,y,sec_loc));
tic;
% opt = odeset('AbsTol',1e-8,'RelTol',1e-8);
% [T,Y] = ode15s(@(t,x) CNT_model(t,x,p0),Tspan,x0);
x0(1) = x0(1) - 1e-3;
[T,Y,te,ye] = ode15s(@(t,x) CNT_model(t,x,p0),Tspan,x0, opt1);
% try RK4 solver
%  [ T, Y ] = RK4( @(t,x) Goodwin(t,x,pars),0,Tmax,1001,x0 );
%  Y = Y';
 toc;
 
 f= @(t) heaviside(sin((t)*pi/12));
Y(:,end) = f(Y(:,end));
%% limit cycles
figure;
plot(Y(end-480:end,1), Y(end-480:end,2))
hold on;
plot(Y(end-480:end,3), Y(end-480:end,4))

% scatter(ye([2 5 7],1),ye([2 5 7],2), 14, 'filled')
% scatter(ye([1 3 4 6],3),ye([1 3 4 6],4), 14, '*')

% Plot the nullclines
h= @(x) x./(0.1+x+2*x.^2);
g= @(x) 1./(1+x.^4);
Prange= -0.0:0.01:8;
plot(Prange,(kD+kL1)*Prange + kf*h(Prange), '--','LineWidth', 2);  % P-nullcline in light of OSC2
plot(Prange,(kD+0)*Prange + kf*h(Prange), '--','LineWidth', 2);  % P-nullcline in darkness of OSC2
plot(Prange,(1+0.)./(1+Prange.^4), '--','LineWidth', 2);  % M-nullcline of OSC2 for min of M_1
plot(Prange,(1+.7*alpha2)*g(Prange), '--','LineWidth', 2);  % M-nullcline of OSC2 for max of M_1

legend('O_1', 'O_2', 'P-nullcline light', 'P-nullcline dark', 'M-nullcline1', ...
            'M-nullcline2');
    
hold off;

ylim([0 1]); ylabel('M');
xlim([0 5]); xlabel('P');
title('Forced limit cycles')

%% schematic poincare sections. figure 3
figure;
tiledlayout(1,2);

nexttile()
Tend = 433;
plot(Y(1:Tend+10,1), Y(1:Tend+10,2))
hold on;
plot(Y(1:Tend+45,3), Y(1:Tend+45,4))

% scatter(ye([2 5 7],1),ye([2 5 7],2), 48, 'filled')
% scatter(ye([1 3 4 6],3),ye([1 3 4 6],4), 48, 'd', 'filled')
scatter(Y(1,3), Y(1,4), 'filled')
scatter([ye(2,1) Y(1,1)], [ye(2,2) Y(1,2)], 100, 'd', 'filled', 'b')
scatter(ye([1 3],3),ye([1 3],4), 48, 'd', 'filled', 'r')

% Plot the nullclines
% h= @(x) x./(0.1+x+2*x.^2);
% g= @(x) 1./(1+x.^4);
% Prange= -0.0:0.01:8;
% plot(Prange,(kD+kL1)*Prange + kf*h(Prange), '--','LineWidth', 2);  % P-nullcline in light of OSC2
% plot(Prange,(kD+0)*Prange + kf*h(Prange), '--','LineWidth', 2);  % P-nullcline in darkness of OSC2
% plot(Prange,(1+0.)./(1+Prange.^4), '--','LineWidth', 2);  % M-nullcline of OSC2 for min of M_1
% plot(Prange,(1+.7*alpha2)*g(Prange), '--','LineWidth', 2);  % M-nullcline of OSC2 for max of M_1

plot(linspace(1.72,1.72,10), linspace(0.1,0.3,10), 'k')

% legend('O_1', 'O_2', 'O_1 return', 'O_2 return', 'P-nullcline light', 'P-nullcline dark', 'M-nullcline1', ...
%             'M-nullcline2', 'Poincare section');
lg=get (gca,'Children'); 
legend (lg([6 5 3 2 1]),'O_1', 'O_2', 'O_1 return', 'O_2 return', 'Poincare section')
% legend('O_1', 'O_2', 'O_1 return', 'O_2 return', 'Poincare section');

hold off;

ylim([0 1]); ylabel('M');
xlim([0 5]); xlabel('P');
% title('return')

nexttile()
te1 = te([2 5 7 9 11 13 15]);
te2 = te([1 3 4 6 8 10 12]);
dte1 = diff(te1);
dte2 = diff(te2);
scatter(1:length(dte1)+1, [te1(1); dte1], 'LineWidth', 2)
hold on;
scatter(1:length(dte2)+1, [te2(1); dte2], 'LineWidth', 2)
hold off;
xlabel('# of return');
xticks(0:7);
ylabel('return time');
%%
function [value,isterminal,direction] = section(t,y, sec_loc)
    value = y(sec_loc(1)) - sec_loc(2);
    direction = -1;
    isterminal = 0;
end

function [value,isterminal,direction] = section1(t,y, sec_loc)
    value = [y(sec_loc(1)) - sec_loc(2); y(3) - 1.72];
    direction = [-1; -1];
    isterminal = [0; 0];
end
