clc; 
clearvars;

% Ask user for minimum and maximum wavelength values
% suggested minimum is 300nm because under that tantalum starts absorbing
min_wavelength_nm = input('Enter the minimum of desired wavelength range (in nanometers): ');
max_wavelength_nm = input('Enter the maximum of desired wavelength range (in nanometers): ');

% Define the wavelengths array with 1 nm resolution
wavelengths = linspace(min_wavelength_nm, max_wavelength_nm, (max_wavelength_nm - min_wavelength_nm) + 1) * 1e-9;

% Ask user if the first layer should be silicon or tantalum
first_layer_material = input('What is the first layer: Enter "Si" for silicon or "Ta" for tantalum: ', 's');
if strcmpi(first_layer_material, 'Si')
    n1_file = 'Processed_SiO2_GenOsc_nvalues.txt'; 
    n2_file = 'Processed_Ta2O5_GenOsc_nvalues.txt';
else
    n1_file = 'Processed_Ta2O5_GenOsc_nvalues.txt';
    n2_file = 'Processed_SiO2_GenOsc_nvalues.txt';
end

% Define substrate file
ns_file = 'fused_silica_n&k.txt';  % substrate refractive indices file

% Load and interpolate refractive index data for the full wavelength range
data_n1 = readmatrix(n1_file);
data_n2 = readmatrix(n2_file);
data_ns = readmatrix(ns_file);
data_ns(:, 1) = data_ns(:, 1) * 1e-9;  % Convert nanometers to meters

n1 = interp1(data_n1(:, 1), data_n1(:, 2), wavelengths, 'linear', 'extrap');
n2 = interp1(data_n2(:, 1), data_n2(:, 2), wavelengths, 'linear', 'extrap');
ns = interp1(data_ns(:, 1), data_ns(:, 2), wavelengths, 'linear', 'extrap');

% Ask if user wants to input thicknesses or calculate from central wavelength
thickness_option = input('Would you like to input layer thicknesses directly or specify a central wavelength for the stopband? Enter "t" or "w": ', 's');
if strcmpi(thickness_option, 'w')
    lambda_central_nm = input('Enter the central wavelength (in nanometers): ');
    lambda_central = lambda_central_nm * 1e-9;  % Convert from nanometers to meters
    
    % Find the index of lambda_central in the wavelengths array
    [~, idx_central] = min(abs(wavelengths - lambda_central));
    
    % Use the index to get refractive indices at the central wavelength
    n1_central = n1(idx_central);
    n2_central = n2(idx_central);
    
    % Calculate thicknesses
    d1 = lambda_central / (4 * n1_central);
    d2 = lambda_central / (4 * n2_central);
    % Print the thicknesses
    fprintf('Thickness of layer 1 (material 1): %.3f nm\n', d1 * 1e9);  % Convert from meters to nanometers
    fprintf('Thickness of layer 2 (material 2): %.3f nm\n', d2 * 1e9);  % Convert from meters to nanometers
elseif strcmpi(thickness_option, 't')
    d1_nm = input('Enter the thickness of material 1 (in nanometers): ');
    d2_nm = input('Enter the thickness of material 2 (in nanometers): ');
    % Convert thicknesses from nanometers to meters
    d1 = d1_nm * 1e-9;
    d2 = d2_nm * 1e-9;
else
    error('Invalid option');
end

% Define other parameters
n0 = 1.0;  % refractive index of incident medium (air)

% Ask for polarization
polarization = input('Enter polarization type ("s" for s-polarization or "p" for p-polarization): ', 's');

% Ask for angles of incidence
angles_deg = input('Enter the angles of incidence (in degrees) as an array, e.g., [0 30 60]: ');

% Number of layer pairs
N = input('Enter the number of full layer pairs (N): ');

% Ask if the user wants to add an extra layer
add_extra_layer = input('Do you want to add an extra layer at the end? Enter "yes" or "no": ', 's');
add_extra_layer = strcmpi(add_extra_layer, 'yes');  % Convert response to a logical

% Convert angles from degrees to radians
angles_rad = deg2rad(angles_deg);

% Initialize reflectance data storage
reflectance_data = zeros(length(wavelengths), length(angles_deg));

% Loop over each angle and plot reflectance
for i = 1:length(angles_rad)
    theta0 = angles_rad(i);
    [R, ~] = transfer_matrix_method_inputs(n1, n2, d1, d2, n0, ns, wavelengths, theta0, polarization, N, add_extra_layer);
    
    % Store reflectance data for each angle
    reflectance_data(:, i) = R;
end

% Ask if the user wants to export the reflectance data
export_choice = input('Do you want to export the reflectance data to a .txt file? Enter "yes" or "no": ', 's');
if strcmpi(export_choice, 'yes')
    % Prepare data for export
    export_data = [wavelengths' * 1e9, reflectance_data];  % Wavelengths in nm, reflectance data in each column
    
    % Create a header row with angle labels
    header = 'Wavelength (nm)';
    for i = 1:length(angles_deg)
        header = [header, sprintf('\tAngle_%d', angles_deg(i))];
    end
    
    % Export reflectance data to a text file
    export_filename = 'reflectance_data.txt';
    fid = fopen(export_filename, 'w');
    fprintf(fid, '%s\n', header);  % Write header row
    fclose(fid);
    writematrix(export_data, export_filename, 'Delimiter', '\t', 'WriteMode', 'append');
    
    fprintf('Reflectance data has been saved to %s\n', export_filename);
end

figure;
hold on;

% Loop over each angle and plot reflectance
for i = 1:length(angles_rad)
    plot(wavelengths * 1e9, reflectance_data(:, i), 'DisplayName', sprintf('Angle = %d°', angles_deg(i)));
end

% Customize plot
xlabel('Wavelength (nm)');
ylabel('Reflectance R');
title('Reflectance Spectrum for Different Angles');
legend('show');
grid on;
hold off;