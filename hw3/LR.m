function [RX_IQ_LR, LR_estimate] = LR(Channel_IQ, N, Amount_of_Frame)

% Reshaping & pilot detecting
% Channel_IQ = reshape(Channel_IQ.', 1, []);

% Initialization

frame_sz = size(Channel_IQ);

dfT_arr = zeros(1, Amount_of_Frame);
RX_IQ_LR = zeros(1, length(Channel_IQ));
RX_IQ_LR(1:N) = Channel_IQ(1:N);

LR_NCO = 0;
dfT = 0;

R_n_arr = zeros(1, 20);
RX_IQ_LR = Channel_IQ;

% for itter_time = 1 : Amount_of_Frame
% 
%     Frame_it = RX_IQ_LR(itter_time, :);
%     pilots_rx_it = Frame_it(1 : 20);
%     z = pilots_rx_it .* conj(SOF_IQ);
%     R_sum = 0;
% 
%     % LR detector
%     for itter_n = 1 : N - 1
%         z_sum = z(itter_n:end).*conj(z(1 : end-itter_n+1));
%         R_n = sum(z_sum) / (N - itter_n + 1);
% %         R_n = pilots_rx_it(end) .* conj(pilots_rx_it(end - itter_n)) / itter_n;
%         R_n_arr(itter_n) = R_n;
%         R_sum = R_sum + R_n;
%     end
%     LR_estimate = (angle(R_sum)) / (N + 1);
%     
%     % NCO | Phase Accumulation
%     dfT = dfT - LR_estimate;
%     dfT_arr(itter_time) = dfT;
%     LR_NCO = mod(LR_NCO + dfT, 1);
% 
%     % Compensation
%     if itter_time ~= Amount_of_Frame
% %      RX_IQ_LR = Channel_IQ * exp(1j*2*pi*LR_NCO);
% %      Channel_IQ = Channel_IQ * exp(1j*2*pi*LR_NCO);
%     end
%     RX_IQ_LR = Channel_IQ * exp(1j*2*pi*LR_NCO);
% %     RX_IQ_LR(itter_time + 1, :) = Channel_IQ .* exp(1j*2*pi*LR_NCO);
% 
% end


frame_sz = size(Channel_IQ);
Channel_IQ = reshape(Channel_IQ.', 1, []);

SOF = [1 0 0 1 1 1 0 1 0 1 0 1 0 1 1 0 0 1 0 0]; 
SOF_IQ = mapping(SOF, 'BPSK');
data_len = frame_sz(2) - length(SOF_IQ);
Pilots = repmat([SOF_IQ, zeros(1, data_len)], 1, frame_sz(1));

L = 20;
RX_IQ_LR = zeros(1, length(Channel_IQ));
RX_IQ_LR(1:L) = Channel_IQ(1:L);

z = zeros(1, length(Channel_IQ));

LR_NCO = 0;

itter_time = 1;

LR_est_arr = [];

while itter_time <= length(Channel_IQ)

    RX_IQ_LR(itter_time) = Channel_IQ(itter_time) * exp(1i*2*pi*LR_NCO);
    
    if Pilots(itter_time) ~= 0
%     if itter_time <= length(Channel_IQ) - 21
        pilot_idx_it = itter_time:N+itter_time;
        
        RX_IQ_LR(pilot_idx_it(2:end-1)) = ...
            Channel_IQ(pilot_idx_it(2:end-1)) * exp(1i*2*pi*LR_NCO);

        RX_IQ_LR(pilot_idx_it(end)) = Channel_IQ(pilot_idx_it(end));

        z_it = RX_IQ_LR(pilot_idx_it) .* conj(SOF_IQ);
        
        R_sum = 0;
        for itter_n = 1 : N
            z_conj = z_it(itter_n+1:end) .* conj(z_it(1:end-itter_n));
            R_n = sum(z_conj)/(L-itter_n);
            R_sum = R_sum + R_n;
        end

        LR_estimate = angle(R_sum)/pi/(N+1);
        LR_est_arr = [LR_est_arr, LR_estimate];

        % NCO | Phase Accumulation
        dfT = 0 - LR_estimate;
        dfT_arr(itter_time) = dfT;
        LR_NCO = mod(LR_NCO + dfT, 1);

        RX_IQ_LR(pilot_idx_it) = Channel_IQ(pilot_idx_it) .* exp(1j*2*pi*LR_NCO);

        itter_time = itter_time + 20;
    end

%     RX_IQ_LR = Channel_IQ .* exp(1j*2*pi*LR_NCO);
    itter_time = itter_time + 1;
end

% =========================================================================
% How does the estimate behave? Show on the plot
% How did the constellation change?
% -------------------------------------------------------------------------
LR_estimate = dfT_arr(dfT_arr~= 0);

end

