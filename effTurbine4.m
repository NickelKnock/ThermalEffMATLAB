%% Given
P_boiler = 55; % bar
P_condenser = XSteam('psat_T', 14); % bar

T_boiler = 300; % deg C
TTD = 0; % Terminal Temperature Difference
eta_turb = 0.90; % Turbine efficiency

% Define the range for P_fwh1 as a percentage of the boiler pressure
P_fwh1_factor_range = [0.80, 0.775, 0.75, 0.725, 0.70];  % 80% to 70% of boiler pressure

% Define the ranges for P_fwh2 and P_rht2
P_fwh2_range = linspace(10, 30, 5);     % Second FWH pressures (10-30 bar)
P_rht2_range = linspace(10, 30, 5);     % Second RHT pressures (10-30 bar)

% Initialize a table to store the efficiency, specific work, and specific heat for each iteration
efficiency_table = [];

for k = 1:length(P_fwh1_factor_range)
    % Set the first FWH and RHT pressures based on percentage of boiler pressure
    P_fwh_1 = P_boiler * P_fwh1_factor_range(k);
    P_rht_1 = P_fwh_1;

    % Initialize efficiency matrix for current graph
    efficiency_matrix = zeros(5, 5);
    
    for i = 1:5
        for j = 1:5
            % Set the second FWH and RHT pressures
            P_fwh_2 = P_fwh2_range(i);
            P_rht_2 = P_rht2_range(j);

            %% State Calculations
            h1 = XSteam('h_pT', P_boiler, T_boiler); % kJ/kg
            s1 = XSteam('s_pT', P_boiler, T_boiler); % kJ/(kg*K)
            h2s = XSteam('h_ps', P_fwh_1, s1); % kJ/kg
            h2 = h1 - eta_turb * (h1 - h2s); % kJ/kg
            h3s = XSteam('h_ps', P_rht_1, s1); % kJ/kg
            h3 = h2 - eta_turb * (h2 - h3s); % kJ/kg
            h4 = XSteam('h_pT', P_rht_1, T_boiler); % kJ/kg
            s4 = XSteam('s_pT', P_rht_1, T_boiler); % kJ/(kg*K)
            h5s = XSteam('h_ps', P_fwh_2, s4); % kJ/kg
            h5 = h4 - eta_turb * (h4 - h5s); % kJ/kg
            h6s = XSteam('h_ps', P_rht_2, s4); % kJ/kg
            h6 = h5 - eta_turb * (h5 - h6s); % kJ/kg
            h7 = XSteam('h_pT', P_rht_2, T_boiler); % kJ/kg
            s7 = XSteam('s_pT', P_rht_2, T_boiler); % kJ/(kg*K)
            h8s = XSteam('h_ps', P_condenser, s7); % kJ/kg
            h8 = h7 - eta_turb * (h7 - h8s); % kJ/kg
            h9 = XSteam('hL_p', P_condenser); % kJ/kg
            s9 = XSteam('sL_p', P_condenser); % kJ/(kg*K) 
            v9 = XSteam('vL_p', P_condenser); % m³/kg
            h10 = h9 + v9 * (P_boiler - P_condenser) * 100; % kJ/kg
            T15 = round(XSteam('Tsat_p', P_fwh_2), 2); % deg C
            T11 = T15 - TTD; % deg C
            h11 = XSteam('h_pT', P_boiler, T11); % kJ/kg
            T13 = round(XSteam('Tsat_p', P_fwh_1), 2); % deg C
            T12 = T13 - TTD; % deg C
            h12 = XSteam('h_pT', P_boiler, T12); % kJ/kg
            h13 = XSteam('hL_p', P_fwh_1); % kJ/kg 
            h14 = h13; % kJ/kg 
            h15 = XSteam('hL_p', P_fwh_2); % kJ/kg
            h16 = h15; % kJ/kg

            %% Mass Flow Rate Ratios
            m2_m1 = (h12 - h11) / (h2 - h13);
            m5_m1 = ((h11 - h10) - m2_m1 * (h14 - h15)) / (h5 - h15);

            %% Work and Heat Calculations (as before)
            W_hp_turb = h1 - h2 - m2_m1 * (h2 - h3);
            W_ip_turb = (1 - m2_m1) * (h4 - h5) - m5_m1 * (h5 - h6);
            W_lp_turb = (1 - m2_m1 - m5_m1) * (h7 - h8);
            W_pump = h10 - h9;
            W_net = W_hp_turb + W_ip_turb + W_lp_turb - W_pump;

            % Specific Work
            specific_work = W_net;

            % Specific Heat Input
            Q_boiler = h1 - h12;
            Q_rht_1 = (1 - m2_m1) * (h4 - h3);
            Q_rht_2 = (1 - m2_m1 - m5_m1) * (h7 - h6);
            Q_in = Q_boiler + Q_rht_1 + Q_rht_2;
            specific_heat = Q_in;

            %% Thermal Efficiency
            eta = W_net / Q_in;

            % Store the efficiency in the matrix
            efficiency_matrix(i, j) = eta;

            % Add results to the table, including specific work and specific heat
            efficiency_table = [efficiency_table; P_fwh_1, P_rht_1, P_fwh_2, P_rht_2, eta, specific_work, specific_heat];
        end
    end

    %% Graph the Efficiencies for the current value of P_fwh1
    figure;
    [P_fwh2_grid, P_rht2_grid] = meshgrid(P_fwh2_range, P_rht2_range);
    surf(P_fwh2_grid, P_rht2_grid, efficiency_matrix);
    xlabel('P_{fwh2} (bar)');
    ylabel('P_{rht2} (bar)');
    zlabel('Thermal Efficiency');
    title(sprintf('Efficiency vs FWH2 and RHT2 Pressures (P_{fwh1} = %.3f)', P_fwh1_factor_range(k) * P_boiler));

    %% Filter the specific data for this P_fwh_1 and P_rht_1 set
    filtered_data = efficiency_table(efficiency_table(:,1) == P_fwh_1 & efficiency_table(:,2) == P_rht_1, :);

    %% Plot Specific Work and Specific Heat
    figure;
    subplot(2,1,1);
    surf(P_fwh2_grid, P_rht2_grid, reshape(filtered_data(:, 6), [5,5]));
    xlabel('P_{fwh2} (bar)');
    ylabel('P_{rht2} (bar)');
    zlabel('Specific Work (kJ/kg)');
    title('Specific Work vs FWH2 and RHT2 Pressures');

    subplot(2,1,2);
    surf(P_fwh2_grid, P_rht2_grid, reshape(filtered_data(:, 7), [5,5]));
    xlabel('P_{fwh2} (bar)');
    ylabel('P_{rht2} (bar)');
    zlabel('Specific Heat (kJ/kg)');
    title('Specific Heat vs FWH2 and RHT2 Pressures');
end

%% Create and display the table of results, including Specific Work and Specific Heat
T = array2table(efficiency_table, 'VariableNames', {'P_fwh_1', 'P_rht_1', 'P_fwh_2', 'P_rht_2', 'Efficiency', 'Specific_Work', 'Specific_Heat'});
disp(T);

% Export the table to the specified directory
writetable(T, 'F:\School and Professional\School\Year 4\Fall_2024\Thermal_Fluids_Design\Code\ThermalFluids Project1Tables_Graphs_Code\efficiency_table2.xlsx');
