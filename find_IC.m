function [myIC, mycycle] = find_IC(myODE, x0, pars, sec_loc)
% With section location, find initial condtion on the forced limit cycle.
% sec_loc: pre-defined Poincare section location. index of variable and
% value of variable.
    eps = 1e-5;
    Tmax = 24;
    dt = 1e-3;
    tspan = 0:dt:Tmax;
%     tspan = [0, Tmax];
    xn = x0 + 10;
    iter = 0;
    options= odeset('AbsTol',1e-8,'RelTol',1e-8);
    while (norm(xn-x0)>eps) && (iter < 100)
        [~,Y] = ode15s(@(t,x) myODE(t,x,pars),tspan, [x0;0], options);
        xn = x0;
        x0 = Y(end,1:end-1)';
        iter = iter + 1;
    end
    mycycle = @(x) interpn(tspan,Y, x) ;
    
    y_t = @(x) interpn(tspan,Y(:,sec_loc(1)),x) - sec_loc(2);
%     y_t = @(x) mycycle(sec_loc(1)) - sec_loc(2);
    
    for y0 = 1:4:24
        t_fix = fzero(y_t,y0);
        if y_t(t_fix-0.1) > 0
            break
        end 
    end
    
%     loc = find(abs(Y(:,sec_loc(1))-sec_loc(2))<eps);
%     myIC stores the values on the P'section
    myIC = mycycle(t_fix);
end
% call:  
% [myIC, mycycle] = find_IC(@Goodwin_forced, [1;0;0], pars, [3;80]);
% Don't include initial LD phase.