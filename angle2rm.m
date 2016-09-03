function R = angle2rm(phi,omega,kappa)
R = zeros(3,3);
R(1,1) = cos(phi)*cos(kappa)-sin(phi)*sin(omega)*sin(kappa);
R(1,2) = cos(omega)*sin(kappa);
R(1,3) = sin(phi)*cos(kappa)+cos(phi)*sin(omega)*sin(kappa);
R(2,1) = -cos(phi)*sin(kappa)-sin(phi)*sin(omega)*cos(kappa);
R(2,2) = cos(omega)*cos(kappa);
R(2,3) = -sin(phi)*sin(kappa)+cos(phi)*sin(omega)*cos(kappa);
R(3,1) = -sin(phi)*cos(omega);
R(3,2) = -sin(omega);
R(3,3) = cos(phi)*cos(omega);
end
