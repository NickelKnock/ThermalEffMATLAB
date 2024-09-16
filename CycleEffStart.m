% MATLAB script for Rankine cycle with 2 closed FWHs, perfect isentropic efficiency, reheating, and dynamically calculated feedwater mass extraction

% Define known conditions
P_boiler = 85; % Boiler pressure in bar
T_boiler = 300; % Boiler temperature in Celsius
P_intermediate = 55; % Intermediate pressure in bar (after first turbine)
P_low = 30; % Low-pressure turbine inlet pressure in bar (after intermediate-pressure turbine)
T_reheat = 300; % Reheat temperature in Celsius

% Variable Condenser Temperature (T_cond) and corresponding pressure
T_cond = 14; % Condenser temperature in Celsius (Deep River water temp avg in Tulsa Area)
P_cond = XSteam('psat_T', T_cond); % Calculate saturation pressure based on T_cond (in bar)

% Boiler output (state 1)
h1 = XSteam('h_pT', P_boiler, T_boiler); % Enthalpy at boiler output (high-pressure steam)
s1 = XSteam('s_pT', P_boiler, T_boiler); % Entropy at boiler output

% High-Pressure Turbine (HPT) output (state 2)
h2s = XSteam('h_ps', P_intermediate, s1); % Isentropic expansion to intermediate pressure
h2 = h2s; % Perfect isentropic efficiency, so actual enthalpy = isentropic enthalpy

% First closed feedwater heater (FWH1) energy balance
P_fwh1 = P_intermediate; % Pressure of FWH1
h_fw1_in = XSteam('hL_p', P_cond); % Enthalpy of feedwater entering FWH1 from condenser
h_fw1_out = XSteam('hL_p', P_fwh1); % Enthalpy of feedwater leaving FWH1 at P_fwh1

% Mass flow extraction for FWH1
m_extracted_1 = (h_fw1_out - h_fw1_in) / (h2 - h_fw1_in); % Extraction mass flow ratio for FWH1

% Reheat after HPT (state 3)
h3 = XSteam('h_pT', P_intermediate, T_reheat); % Reheat to original temperature
s3 = XSteam('s_pT', P_intermediate, T_reheat); % Entropy after reheating

% Intermediate-Pressure Turbine (IPT) output (state 4)
h4s = XSteam('h_ps', P_low, s3); % Isentropic expansion to low-pressure turbine
h4 = h4s; % Perfect isentropic efficiency

% Second closed feedwater heater (FWH2) energy balance
P_fwh2 = P_low; % Pressure of FWH2
h_fw2_in = h_fw1_out; % Feedwater entering FWH2 comes from FWH1
h_fw2_out = XSteam('hL_p', P_fwh2); % Enthalpy of feedwater leaving FWH2 at P_fwh2

% Mass flow extraction for FWH2
m_extracted_2 = (h_fw2_out - h_fw2_in) / (h4 - h_fw2_in); % Extraction mass flow ratio for FWH2

% Reheat after IPT (state 5)
h5 = XSteam('h_pT', P_low, T_reheat); % Reheat to original temperature
s5 = XSteam('s_pT', P_low, T_reheat); % Entropy after reheating

% Low-Pressure Turbine (LPT) output (state 6)
h6s = XSteam('h_ps', P_cond, s5); % Isentropic expansion to condenser pressure
h6 = h6s; % Perfect isentropic efficiency

% Condenser outlet (state 7)
h7 = XSteam('hL_p', P_cond); % Enthalpy at saturated liquid state (condenser outlet)
s7 = XSteam('sL_p', P_cond); % Entropy at saturated liquid state

% Isentropic pump work (state 8)
h8s = XSteam('h_ps', P_boiler, s7); % Isentropic pump compression
h8 = h8s; % Perfect isentropic efficiency

% Heat addition after the feedwater heaters (boiler heat)
% Adjust boiler heat addition based on mass flow after FWHs
Q_in = (1 - m_extracted_1 - m_extracted_2) * (h1 - h_fw2_out) + (h3 - h2) + (h5 - h4); % Boiler heat with 2 FWHs

% Turbine work calculation
W_turbine_total = (h1 - h2) + (h3 - h4) + (h5 - h6); % Total work done by turbines

% Pump work
W_pump = h8 - h7; % Work required by the pump
W_net = W_turbine_total - W_pump; % Net work output

% Cycle efficiency calculation
efficiency = W_net / Q_in;

% Display results
fprintf('Cycle efficiency with 2 closed FWHs: %.2f%%\n', efficiency * 100);
fprintf('Mass flow extraction to FWH1: %.2f kg/s\n', m_extracted_1);
fprintf('Mass flow extraction to FWH2: %.2f kg/s\n', m_extracted_2);
fprintf('Total turbine work: %.2f kJ/kg\n', W_turbine_total);
fprintf('Pump work: %.2f kJ/kg\n', W_pump);
fprintf('Net work: %.2f kJ/kg\n', W_net);
fprintf('Boiler and reheat heat addition: %.2f kJ/kg\n', Q_in);
fprintf('Condenser pressure: %.4f bar\n', P_cond);
fprintf('Condenser temperature: %.2f °C\n', T_cond);
