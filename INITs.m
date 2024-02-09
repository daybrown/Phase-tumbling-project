dt= .05;
days= 20;
tf= 10*days;
Tspan= 0:dt:tf;

phi1= 2.1; phi2= 2.1;
eps1= 0.05; eps2= 0.05;
kD= .05; kf= 1;
%--------------------------------------
kL1= 0.05; kL2= 0.05;    % control light
alpha1= 0.9; alpha2=  0.9;    % control coupling.

% To control light phase, change the inits. of x(end).
%-----------------------------------------
p0= [phi1;phi2;eps1;eps2;kD;kf;kL1;kL2;alpha1;alpha2];
x0= [4.37;0.6685;1.705;0.1548; 0];