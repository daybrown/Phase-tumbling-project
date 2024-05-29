function [t_entrain, t_entrain_O1, t_entrain_O2] = map_checktime_C(myODE, x, p, sec_loc)
tf = 24*20;
tspan = [0, tf];
%     eps = 0.001; 
x0 = x;

opt1 = odeset('AbsTol',1e-10,'RelTol',1e-10,'Events',@(t,y) section(t,y,sec_loc));

%     x0(sec_loc1(1)) = modi(x0(sec_loc1(1)),dir);  

tol1 = 0.2;  
% tol2 = 0.05;
% Imax = 50;
t_entrain = 0;

[~,~,te,ye] = ode15s(@(t,x) myODE(t,x,p),tspan,x0,opt1);
%         [~,~,te2,ye2] = ode15s(@(t,x) myODE(t,x,p),tspan,x0,opt2);
te_O1 = te(abs(ye(:,1)-sec_loc(2))<1e-5);
te_O2 = te(abs(ye(:,3)-sec_loc(4))<1e-5);

dte_O1 = diff(te_O1);
dte_O2 = diff(te_O2);

dte_O1(abs(dte_O1)<1e-3) = [];
dte_O2(abs(dte_O2)<1e-3) = [];

% add the first return to the array
dte_O1 = [te_O1(1); dte_O1];
dte_O2 = [te_O2(1); dte_O2];
% ------------------------------------

idx_O1 = find(abs(dte_O1 - 24) < tol1);
idx_O2 = find(abs(dte_O2 - 24) < tol1);

for i = 1:length(idx_O1)
    if all(abs(dte_O1(idx_O1(i):end) - 24) < tol1)
%       t_entrain_O1 = te_O1(idx_O1(i)+1);
      t_entrain_O1 = te_O1(idx_O1(i));
      break;
    end
end

for i = 1:length(idx_O2)
    if all(abs(dte_O2(idx_O2(i):end) - 24) < tol1)
%       t_entrain_O2 = te_O2(idx_O2(i)+1);
      t_entrain_O2 = te_O2(idx_O2(i));
      break;
    end
end

t_entrain = max(t_entrain_O1, t_entrain_O2);


function [value,isterminal,direction] = section(t,y, sec_loc)
    value = [y(sec_loc(1)) - sec_loc(2); y(sec_loc(3)) - sec_loc(4)];
    direction = [-1; -1];
    isterminal = [0; 0];
end


end
% Call
%  [y, t_return] = map_general(@CNT_model, [12 1 1], pars, [3;80]);
