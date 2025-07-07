function [R, T] = transfer_matrix_method_inputs(n1, n2, d1, d2, n0, ns, wavelengths, theta0, polarization, N, add_extra_layer)
    % Number of wavelengths to process
    num_wavelengths = length(wavelengths);
    
    % Preallocate arrays for reflection and transmission coefficients
    R = zeros(1, num_wavelengths);
    T = zeros(1, num_wavelengths);
    
    % Loop over each wavelength
    for idx = 1:num_wavelengths
        lambda = wavelengths(idx);
        
        % Get refractive indices for the current wavelength
        n1_idx = n1(idx);
        n2_idx = n2(idx);
        ns_idx = ns(idx);
        
        % Calculate the angle of refraction in each medium using Snell's law
        theta1 = asin(n0 * sin(theta0) / n1_idx);
        theta2 = asin(n0 * sin(theta0) / n2_idx);
        theta_s = asin(n0 * sin(theta0) / ns_idx);
        
        % Calculate wave numbers and z-components
        k0 = 2 * pi / lambda;
        k1z = n1_idx * k0 * cos(theta1);
        k2z = n2_idx * k0 * cos(theta2);
        %ksz = ns_idx * k0 * cos(theta_s);
        
        % Select the correct characteristic matrix elements based on polarization
        if strcmpi(polarization, 's')
            % s-polarization (TE mode)
            M1 = [cos(k1z * d1), 1i * sin(k1z * d1) / (n1_idx * cos(theta1));
                  1i * n1_idx * cos(theta1) * sin(k1z * d1), cos(k1z * d1)];
              
            M2 = [cos(k2z * d2), 1i * sin(k2z * d2) / (n2_idx * cos(theta2));
                  1i * n2_idx * cos(theta2) * sin(k2z * d2), cos(k2z * d2)];
            
        elseif strcmpi(polarization, 'p')
            % p-polarization (TM mode)
            M1 = [cos(k1z * d1), 1i * sin(k1z * d1) / (n1_idx / cos(theta1));
                  1i * (n1_idx / cos(theta1)) * sin(k1z * d1), cos(k1z * d1)];
              
            M2 = [cos(k2z * d2), 1i * sin(k2z * d2) / (n2_idx / cos(theta2));
                  1i * (n2_idx / cos(theta2)) * sin(k2z * d2), cos(k2z * d2)];
        else
            error('Invalid polarization. Use "s" for s-polarization or "p" for p-polarization.');
        end
        
        % Calculate the total transfer matrix for one period
        M_period = M2 * M1;
        
        % Repeat the period for a stack of N layers
        M_total = eye(2);  % Start with the identity matrix
        for n = 1:N
            M_total = M_period * M_total;  % Multiply N times
        end
        
        % Add the final layer if an odd number of layer pairs
        if add_extra_layer
            M_total = M1 * M_total;
        end

        % Include air and substrate
        if strcmpi(polarization, 's')
            % s-polarization (TE mode)
            I0 = [1, 1; n0 * cos(theta0), -n0 * cos(theta0)];
            Is = [1, 1; ns_idx * cos(theta_s), -ns_idx * cos(theta_s)];
        elseif strcmpi(polarization, 'p')
            % p-polarization (TM mode)
            I0 = [1, 1; n0 / cos(theta0), n0 / -cos(theta0)];
            Is = [1, 1; ns_idx / cos(theta_s), -ns_idx / cos(theta_s)];
        end
        
        % Total system matrix
        S = inv(I0) * M_total * inv(Is);
        
        % Extract reflection and transmission coefficients
        if strcmpi(polarization, 's')
            r = S(2, 1) / S(1, 1);
            t = 1 / S(1, 1);
        elseif strcmpi(polarization, 'p')
            r = S(2, 1) / S(1, 1);
            t = 1 / S(1, 1);
        end

        % Calculate reflectance and transmittance
        R(idx) = abs(r)^2;
        T(idx) = abs(t)^2 * (real(ns_idx * cos(theta_s)) / real(n0 * cos(theta0)));
    end
end
