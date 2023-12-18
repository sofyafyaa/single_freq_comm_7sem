%%
close; clear; clc;

%% config

Freq_Offset = 0.01; % normalised frequency
SNR = 20; % dB

%% Transmitter
% config
Amount_of_Frame = 300;
Length_Data_IQ = 1440;

% Start of frame
SOF = [1 0 0 1 1 1 0 1 0 1 0 1 0 1 1 0 0 1 0 0]; 
IQ_SOF = mapping(SOF, "BPSK"); % Use this sequence on the Rx as a Pilot-Signal

% QAM | mapper
Tx_Bits = randi([0 1], 1, Amount_of_Frame*Length_Data_IQ*2);
TX_IQ_Data = mapping(Tx_Bits, "QPSK");

% Frame structure 
% |20 IQ BPSK Start-of-Frame| 1440 IQ QPSK| 36 IQ BPSK pilot| ... 
IQ_TX_Frame = FrameStruct(TX_IQ_Data, IQ_SOF, Amount_of_Frame);

%% Channel
% Add white Gaussian noise to signal
Channel_IQ = awgn(IQ_TX_Frame, SNR, 'measured');

% Add frequency offset
Channel_IQ = Channel_IQ.*exp(-1j.*2.*(1:Length_Data_IQ+length(IQ_SOF)).*pi*Freq_Offset);

%% Receiver with frequency estimator based on Delay and Multiply with D=2
% Configurate the Loop Filter
% =========================================================================
% Loop filter preset
% -------------------------------------------------------------------------
Xi = 2;           % detector gainDampingFactor
BnTs = 0.1;        % Normalized loop bandwidth (Ts = 1 for this problem)
Kd = 2*pi;          % Phase (not change)
K0 = 1;             % not change
% =========================================================================
%> Loop filter coefficient calculation
% -------------------------------------------------------------------------
wp = BnTs / (Xi+1/(4*Xi));
%> Proportional coefficient
Kp = 2*Xi*wp / (Kd*K0);
%> Integrator coefficient
Ki = wp^2 / (Kd*K0);

D = 2;
[RX_IQ_DM, DM_estimate] = DM(Channel_IQ, D, Kp, Ki);

freq_offset_est = mean(DM_estimate);

RX_IQ_DM = Channel_IQ.*exp(1j.*2.*(1:length(Channel_IQ)).*pi*freq_offset_est);

setup_time = 0;
for itter_time = 20:length(DM_estimate)
    rmse_itt = rmse(DM_estimate(itter_time-19:itter_time), Freq_Offset);
    if rmse_itt < 0.0001
        setup_time = itter_time;
        break;
    end
end
        
figure;
hold on;
title('D&M Phase detector, BnTs = 0.01')
plot(DM_estimate, 'LineWidth', 1);
xline(setup_time, '--k', 'Setup Time', 'LineWidth', 1 )
yline(Freq_Offset, '--k', 'Real Freq offset')
xlabel('number of symb')
ylabel('Result of DM Phase detector')
hold off

%% Receiver with frequency estimator based on Luise and Reggiannini for N = 20 
% in feedforward scheme

% TASK
% pay attation to frame structure

N = 19;
[RX_IQ_LR, LR_estimate] = LR(Channel_IQ, N, Amount_of_Frame);

figure;
hold on
title('L&R Phase detector')
plot(LR_estimate, 'LineWidth', 1);
yline(Freq_Offset, '--k', 'Real Freq offset')
xlabel('number of symb')
ylabel('Result of DM Phase detector')
hold off


%% Analysis
% =========================================================================
% TASK
% Compare results and make a conclusion
% Compare the RMSE for different frequency offsets for both synchronisation schemes
% Compare the time of synchronisation
% -------------------------------------------------------------------------

rmse_dm_arr = [];

for Freq_Offset_it = -0.5 : 0.01 : 0.5
    Tx_Bits = randi([0 1], 1, Amount_of_Frame*Length_Data_IQ*2);
    TX_IQ_Data = mapping(Tx_Bits, "QPSK");
    IQ_TX_Frame = FrameStruct(TX_IQ_Data, IQ_SOF, Amount_of_Frame);

    Channel_IQ = awgn(IQ_TX_Frame, SNR, 'measured');
    Channel_IQ = Channel_IQ.*...
        exp(-1j.*2.*(1:Length_Data_IQ+length(IQ_SOF)).*pi*Freq_Offset_it);

    [RX_IQ_DM, DM_estimate] = DM(Channel_IQ, D, Kp, Ki);
    
    rmse_it = rmse(DM_estimate, Freq_Offset_it);
    rmse_dm_arr = [rmse_dm_arr, rmse_it];
end

figure;
hold on
title('RMSE(freq offset), D&M, D=2')
xlabel('freq offset, \delta f')
ylabel('Root Mean Square Estimation')
plot(-0.5 : 0.01 : 0.5, rmse_dm_arr)
hold off

rmse_lr_arr = [];
for Freq_Offset_it = -0.06 : 0.001 : 0.06
    Tx_Bits = randi([0 1], 1, Amount_of_Frame*Length_Data_IQ*2);
    TX_IQ_Data = mapping(Tx_Bits, "QPSK");
    IQ_TX_Frame = FrameStruct(TX_IQ_Data, IQ_SOF, Amount_of_Frame);

    Channel_IQ = awgn(IQ_TX_Frame, SNR, 'measured');
    Channel_IQ = Channel_IQ.*...
        exp(-1j.*2.*(1:Length_Data_IQ+length(IQ_SOF)).*pi*Freq_Offset_it);

    [RX_IQ_LR, LR_estimate] = LR(Channel_IQ, N, Amount_of_Frame);
    
    rmse_it = rmse(LR_estimate, Freq_Offset_it);
    rmse_lr_arr = [rmse_lr_arr, rmse_it];
end

figure;
hold on
title('RMSE(freq offset), L&R, N=19')
xlabel('freq offset, \delta f')
ylabel('Root Mean Square Estimation')
plot(-0.06 : 0.001 : 0.06, rmse_lr_arr(1:end))
hold off

%% Only pilots
Freq_Offset = 0.01; % normalised frequency
SNR = 30; % dB

Amount_of_Pilot_blocks = 50;

SOF = [1 0 0 1 1 1 0 1 0 1 0 1 0 1 1 0 0 1 0 0]; 
IQ_SOF = mapping(SOF, "BPSK");

Pilots_TX = repmat(IQ_SOF, 1, Amount_of_Pilot_blocks);

% Add white Gaussian noise to signal
Channel_IQ = awgn(Pilots_TX, SNR, 'measured');

% Add frequency offset
Channel_IQ = Channel_IQ.*exp(-1j.*2.*(1:length(Channel_IQ)).*pi*Freq_Offset);

Xi = 2;
BnTs = 0.1;
Kd = 2*pi;
K0 = 1;
wp = BnTs / (Xi+1/(4*Xi));
%> Proportional coefficient
Kp = 2*Xi*wp / (Kd*K0);
%> Integrator coefficient
Ki = wp^2 / (Kd*K0);

D = 2;
[RX_IQ_DM, DM_estimate] = DM(Channel_IQ, D, Kp, Ki);

N = 19;
[RX_IQ_LR, LR_estimate] = LR(Channel_IQ, N, Amount_of_Pilot_blocks);



