 function [y1, y2, t_return, YE] = map2D_general_phase(x1, x2, myODE, myLC, myIC, p, sec_loc)
    dt = .01;
    tf = 24*3;
%     tspan = 0:dt:tf;
    tspan = [0,tf];
    eps = 0.001; 
% dim of each oscillators, N oscillators in total and first 2 oscillators
% received light directly, the rest don't receive light directly.
%     dim = 3;
%     N = 3;
%     xx = myLC(x2);
%     x0 = [x(1:sec_loc(1)-1); sec_loc(2)+eps; x(sec_loc(1)+1:end)];
%     options = odeset('AbsTol',1e-10,'RelTol',1e-10,'Events',@(t,y) section2(t,y,sec_loc));
% It's possible to generalize the construction of x0.
    Ndim = 2;       % the dimension of each oscillator
    switch sec_loc(1)  % when ocsillator is 2d
        case 1
            O1 = [sec_loc(2) - eps; myIC(sec_loc(1)+1)];          % phase of O1: section on P1
            O2 = myLC(x2);  O2 = O2(Ndim+1:Ndim*2);     % phase of O2
            options = odeset('AbsTol',1e-10,'RelTol',1e-10,'Events',@(t,y) section2(t,y,sec_loc));
        case 2
            O1 = [myIC(1:sec_loc(1)-1); sec_loc(2) + eps];          % phase of O1: section on M1
            O2 = myLC(x2);  O2 = O2(Ndim+1:Ndim*2);     % phase of O2
            options = odeset('AbsTol',1e-10,'RelTol',1e-10,'Events',@(t,y) section1(t,y,sec_loc));
        case 3
            O1 = myLC(x2); O1 = O1(1:Ndim);          % phase of O1
            O2 = [sec_loc(2) - eps; myIC(sec_loc(1)+1)];          % phase of O2: section on P2
            options = odeset('AbsTol',1e-10,'RelTol',1e-10,'Events',@(t,y) section2(t,y,sec_loc));
        case 4
            O1 = myLC(x2); O1 = O1(1:Ndim);          % phase of O1
            O2 = [myIC(Ndim+1:sec_loc(1)-1); sec_loc(2) + eps];          % phase of O2: section on M2
            options = odeset('AbsTol',1e-10,'RelTol',1e-10,'Events',@(t,y) section1(t,y,sec_loc));
    end
    
    x0 = [O1; O2; x1];
    [~,~,TE,YE] = ode15s(@(t,x) myODE(t,x,p),tspan,x0,options);
    t_return = TE;

% Transform y into phase
    y1 = mod(YE(end),24);
% project the peripheral osc. into 2d and then take a radio angle.
    y0 = myLC(0);
    if sec_loc(1) <= Ndim
        yproj = y0(Ndim*1+1:Ndim*1+2);     % section on first osc
        ycurrent = YE(Ndim*1+1:Ndim*1+2)';
        whichosc = 1;
    else
        yproj = y0(1:Ndim);      % section on second osc
        ycurrent = YE(1:Ndim)';
        whichosc = 3;
    end
%     yproj = y0(Ndim*1+1:Ndim*1+2);
%     cycle = myLC((0:0.1:24)');
%     p_center = [(max(cycle(:,3)) + min(cycle(:,3)))/2; (max(cycle(:,4)) + min(cycle(:,4)))/2];
%-------------------------------------------------------
    p_center = [1.5; 0.4]; % This is the intersection point of the nullclines.
%-----------------------------------------------------------
%     y2 = get_phase(p_center, yproj, YE(Ndim*1+1:Ndim*1+2)', myLC, whichosc);
    y2 = get_phase(p_center, yproj, ycurrent, myLC, whichosc);
%     y = [mod(x(1)+t_return,24); YE(1); YE(3)];
        
        function [value,isterminal,direction] = section1(t,y, sec_loc)
            value = y(sec_loc(1)) - sec_loc(2);
            direction = 1;  % section不同，方向不同
            isterminal = 1;
        end
        function [value,isterminal,direction] = section2(t,y, sec_loc)
            value = y(sec_loc(1)) - sec_loc(2);
            direction = -1;  % section不同，方向不同
            isterminal = 1;
        end
end
% Call
%  [yLC, yp, t_return] = map2D_general_phase(1, 13, GoodwinN_mixed, myLC, myIC, pars, sec_loc)