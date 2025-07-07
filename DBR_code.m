clc,clearvars;
% Define the input parameters
n1_file = 'Processed_Ta2O5_GenOsc_nvalues.txt';  % file containing refractive indices for high index material as a function of wavelength
n2_file = 'Processed_SiO2_GenOsc_nvalues.txt';  % file containing refractive indices for low index material as a function of wavelength
%n1_file = 'Processed_SiO2_GenOsc_nvalues.txt';  % file containing refractive indices for high index material as a function of wavelength
%n2_file = 'Processed_Ta2O5_GenOsc_nvalues.txt';  % file containing refractive indices for low index material as a function of wavelength
ns_file = 'fused_silica_n&k.txt';  % file containing refractive indices for substrate as a function of wavelength
d1 = 63.4e-9;    % thickness of material 1 (in meters)
d2 = 93.35e-9;     % thickness of material 2 (in meters)
n0 = 1.0;       % refractive index of the incident medium (air)
wavelengths = linspace(300e-9, 850e-9, 551);  % array of wavelengths (in meters)
angles_deg = [0 20 40 60];  % array of angles of incidence in degrees
polarization = 's';  % polarization type: 's' for s-polarization, 'p' for p-polarization

% Insert the Number of full layer pairs here, in case there is a odd number
% of layer pairs ie the stack ends in the same material as it starts with,
% then the last layer is inserted in the transfer matrix function
N = 6;

% Convert angle of incidence from degrees to radians
angles_rad = deg2rad(angles_deg);

% Read refractive index data from files
data_n1 = readmatrix(n1_file);
data_n2 = readmatrix(n2_file);
data_ns = readmatrix(ns_file);
data_ns(:, 1) = data_ns(:, 1) * 1e-9;  % Convert nanometers to meters
% Interpolate refractive indices for the given wavelengths
n1 = interp1(data_n1(:, 1), data_n1(:, 2), wavelengths, 'linear', 'extrap');
n2 = interp1(data_n2(:, 1), data_n2(:, 2), wavelengths, 'linear', 'extrap');
ns = interp1(data_ns(:, 1), data_ns(:, 2), wavelengths, 'linear', 'extrap');

% Initialize figure
figure;
hold on;  % To plot multiple lines on the same figure

% Loop over each angle
for i = 1:length(angles_rad)
    theta0 = angles_rad(i);

    % Call the function to compute reflectance and transmittance
    [R, ~] = transfer_matrix_method_f(n1, n2, d1, d2, n0, ns, wavelengths, theta0, polarization, N);

    % Plot reflectance data
    plot(wavelengths * 1e9, R, 'DisplayName', sprintf('Angle = %d°', angles_deg(i)));
end


% Export reflectance data to a text file
export_filename = 'reflectance_data.txt';
export_data = [wavelengths' * 1e9, R'];
writematrix(export_data, export_filename, 'Delimiter', '\t', 'WriteMode', 'overwrite');


% Customize plot
xlabel('Wavelength (nm)');
ylabel('Reflectance R');
title('Reflectance Spectrum for Different Angles');
legend('show');
grid on;
hold off;
