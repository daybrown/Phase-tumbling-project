function Y= CNT_model(t,x,p)
% fully coupled CNT model.
    phi1= p(1); 
    phi2= p(2);
    eps1= p(3); 
    eps2= p(4);
    kD= p(5); 
    kf= p(6);
    kL1= p(7);
    kL2= p(8);    % control light
    alpha1= p(9);
    alpha2= p(10);    % control coupling.
    
    P1= x(1);
    M1= x(2);
    P2= x(3);
    M2= x(4);
    
    h= @(x) x./(0.1+x+2*x.^2);
    g= @(x) 1./(1+x.^4);
    LD= @(t) heaviside(sin((t)*pi/12));

% treat light dark as a state variable.
%     if (P1<0);    P1 = 0;    end
%     if (P2<0);    P2 = 0;    end
    
    Y = zeros(size(x));
    Y(1) = phi1*(M1 - kD*P1 - kf*h(P1) - kL1*LD(x(end))*P1);
    Y(2) = phi1*eps1*(g(P1)-M1 + alpha1*M2.*g(P1));
    Y(3) = phi2*(M2 - kD*P2 - kf*h(P2) - kL2*LD(x(end))*P2);
    Y(4) = phi2*eps2*(g(P2)-M2 + alpha2*M1.*g(P2));
    Y(end) = 1;
    
%     function y = h(x)
%         if (x>=0)
%             y = x./(0.1+x+2*x.^2);
%         else
%             y = -100;
%         end
%     end
 
end