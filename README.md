# DBR-reflectivity-spectrum
MATLAB code to quickly model the reflectivity of a DBR using layer thicknesses and refractive index data
These are MATLAB codes to model the reflectivity spectrum of Distributed Bragg Reflectors. DBR_code and DBR_user_inputs both use the same transfer matrix method based on fresnel coefficients, however to accommodate the user inputs there are two versions. DBR_code should be used to quickly model multiple spectrums when changing only some parameters, like the number of layer pairs. DBR_user_inputs asks the user to specify the following parameters:
- does the user want to input layer thicknesses or a central wavelength
- layer order
- number of layer pairs
- angles of incidence
- polarization

It is important to note that the DBR_code uses the transfer_matrix_method_f.m function, where the option to add an extra layer is controlled within the function script.
