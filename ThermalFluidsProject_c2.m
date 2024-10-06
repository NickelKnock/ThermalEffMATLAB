%% Given
% Pressures
P_boiler = 55; % bar
P_fwh_1 = 39; % 40bar
P_rht_1 = 38; % 30bar (1st reheat pressure)
p_fwh_2 = 20; % 23bar
P_rht_2 = 19; % 10bar (2nd reheat pressure)
P_condenser = XSteam('psat_T', 14); % bar

% Temperatures
T_boiler = 300; % deg C

% Other
TTD = 0; % Terminal Temperature Difference

%% Example 8.4 Assume Each turbine has an isentropic efficiency of 80%
eta_turb = .9 ;% Example 8.4 Each turbine has an isentropic efficiency of 80%

%%
% State 1
h1 = XSteam('h_pT', P_boiler, T_boiler); % kJ/kg
s1 = XSteam('s_pT', P_boiler, T_boiler); % kJ/(kg*K)

% State 2
h2s = XSteam('h_ps', P_fwh_1, s1); % kJ/kg
h2 = h1 - eta_turb * (h1 - h2s); % kJ/kg example 8.4 from textbook

% State 3
h3s = XSteam('h_ps', P_rht_1, s1); % kJ/kg
h3 = h2 - eta_turb * (h2 - h3s); % kJ/kg example 8.4 from textbook

% State 4
h4 = XSteam('h_pT', P_rht_1, T_boiler); % kJ/kg
s4 = XSteam('s_pT', P_rht_1, T_boiler); % kJ/(kg*K)

% State 5
h5s = XSteam('h_ps', p_fwh_2, s4); % kJ/kg
h5 = h4 - eta_turb * (h4 - h5s); % kJ/kg example 8.4 from textbook

% State 6
h6s = XSteam('h_ps', P_rht_2, s4); % kJ/kg
h6 = h5 - eta_turb * (h5 - h6s); % kJ/kg example 8.4 from textbook

% State 7
h7 = XSteam('h_pT', P_rht_2, T_boiler); % kJ/kg
s7 = XSteam('s_pT', P_rht_2, T_boiler); % kJ/(kg*K) 

% State 8
h8s = XSteam('h_ps', P_condenser, s7); % kJ/kg
h8 = h7 - eta_turb * (h7 - h8s); % kJ/kg example 8.4 from textbook

% State 9
h9 = XSteam('hL_p', P_condenser); % kJ/kg
s9 = XSteam('sL_p', P_condenser); % kJ/(kg*K) 

% State 10
v9 = XSteam('vL_p', P_condenser); % m³/kg
h10 = h9 + v9 * (P_boiler - P_condenser) * 100; % kJ/k

% State 11
T15 = round(XSteam('Tsat_p', p_fwh_2),2); % deg C
T11 = T15 - TTD; % deg C
h11 = XSteam('h_pT', P_boiler, T11); % kJ/kg

% State 12
T13 = round(XSteam('Tsat_p', P_fwh_1),2); % deg C
T12 = T13 - TTD; % deg C
h12 = XSteam('h_pT', P_boiler, T12); % kJ/kg

% State 13
h13 = XSteam('hL_p', P_fwh_1); % kJ/kg 

% State 14
h14 = h13; % kJ/kg 

% State 15
h15 = XSteam('hL_p', p_fwh_2); % kJ/kg

% State 16
h16 = h15; % kJ/kg

% Mass Flow Rate Ratios
m2_m1 = (h12 - h11) / (h2 - h13)
m5_m1 = ((h11 - h10) - m2_m1 * (h14 - h15)) / (h5 - h15)

% Work Calculations
W_hp_turb = h1 - h2 - m2_m1 * (h2 - h3);
W_ip_turb = (1 - m2_m1) * (h4 - h5) - m5_m1 * (h5 - h6);
W_lp_turb = (1 - m2_m1 - m5_m1) * (h7 - h8);
W_pump = h10 - h9;
W_net = W_hp_turb + W_ip_turb + W_lp_turb - W_pump

% Heat Added
Q_boiler = h1 - h12;
Q_rht_1 = (1 - m2_m1) * (h4 - h3);
Q_rht_2 = (1 - m2_m1 - m5_m1) * (h7 - h6);
Q_in = Q_boiler + Q_rht_1 + Q_rht_2

% Thermal Efficiency
eta = W_net / Q_in