% MATLAB script for Rankine cycle with perfect isentropic efficiency, reheating, and dynamically calculated feedwater mass extraction

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

% Reheat after HPT (state 3)
h3 = XSteam('h_pT', P_intermediate, T_reheat); % Reheat to original temperature
s3 = XSteam('s_pT', P_intermediate, T_reheat); % Entropy after reheating

% Intermediate-Pressure Turbine (IPT) output (state 4)
h4s = XSteam('h_ps', P_low, s3); % Isentropic expansion to low-pressure turbine
h4 = h4s; % Perfect isentropic efficiency

% Reheat after IPT (state 5)
h5 = XSteam('h_pT', P_low, T_reheat); % Reheat to the original temperature
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

% Feedwater heater energy balance (mass flow extraction)
h_fw_out = XSteam('hL_p', P_boiler); % Enthalpy of feedwater after heating
h_fw_in = h8; % Enthalpy of feedwater before entering the heater
m_ratio = (h_fw_out - h8) / (h1 - h_fw_in); % Calculate the mass flow extraction for feedwater heater

% Calculate boiler heat addition and net specific work
Q_in = (1 - m_ratio) * (h1 - h8) + (h3 - h2) + (h5 - h4); % Heat added in the boiler and reheaters
W_turbine_total = (h1 - h2) + (h3 - h4) + (h5 - h6); % Total work done by all three turbine stages
W_pump = h8 - h7; % Work required by the pump
W_net = W_turbine_total - W_pump; % Net work

% Cycle efficiency
efficiency = W_net / Q_in;

% Display results
fprintf('Cycle efficiency (with reheat and low-pressure turbine): %.2f%%\n', efficiency * 100);
fprintf('Mass flow extraction to feedwater heater: %.2f kg/s\n', m_ratio);
fprintf('Total turbine work: %.2f kJ/kg\n', W_turbine_total);
fprintf('Pump work: %.2f kJ/kg\n', W_pump);
fprintf('Net work: %.2f kJ/kg\n', W_net);
fprintf('Boiler and reheat heat addition: %.2f kJ/kg\n', Q_in);
fprintf('Condenser pressure: %.4f bar\n', P_cond);
fprintf('Condenser temperature: %.2f °C\n', T_cond);
