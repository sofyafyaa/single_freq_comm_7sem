function [RX_IQ_DM, DM_estimate] = DM(Channel_IQ, D, Kp, Ki)

% Reshaping & pilot detecting
frame_sz = size(Channel_IQ);
Channel_IQ = reshape(Channel_IQ.', 1, []);

SOF = [1 0 0 1 1 1 0 1 0 1 0 1 0 1 1 0 0 1 0 0]; 
SOF_IQ = mapping(SOF, 'BPSK');
data_len = frame_sz(2) - length(SOF_IQ);
Pilots = repmat([SOF_IQ, zeros(1, data_len)], 1, frame_sz(1));
% Pilots = repmat(SOF_IQ, 1, length(Channel_IQ)/length(SOF_IQ));

% Initialization
DM_NCO = 0;              % phase

RX_IQ_DM = zeros(1, length(Channel_IQ));
RX_IQ_DM(1:D) = Channel_IQ(1:D);

z = zeros(1, length(Channel_IQ));
z(1:D) = RX_IQ_DM(1:D).*conj(Pilots(1:D));

DM_estimate_prev = 0;    % loop filter
DM_Filtred_prev  = 0;    % previous

dfT = 0;
dfT_arr = zeros(1, length(Channel_IQ));


itter_time = D + 1;
while itter_time <= length(Channel_IQ)
    
    z_conj = 0;
    while Pilots(itter_time) ~= 0
        % Compensation
        RX_IQ_DM(itter_time) = Channel_IQ(itter_time) * exp(1j*2*pi*DM_NCO);

        % DM detector
        z(itter_time) = RX_IQ_DM(itter_time)*conj(Pilots(itter_time));

        z_conj = z_conj + z(itter_time) * conj(z(itter_time - D));

        DM_estimate = angle(z_conj) /D/2/pi;

        % Loop filter
        DM_Filtred = Kp*DM_estimate + (Ki-Kp)*DM_estimate_prev + DM_Filtred_prev;
        DM_estimate_prev = DM_estimate;
        DM_Filtred_prev = DM_Filtred;
    
        % NCO | Phase Accumulation
        dfT = dfT - DM_Filtred;
        dfT_arr(itter_time) = dfT;
        DM_NCO = mod(DM_NCO + dfT, 1);

        itter_time = itter_time + 1;
    end

%     RX_IQ_DM(itter_time) = Channel_IQ(itter_time) * exp(1i*2*pi*DM_NCO);
    itter_time = itter_time + 1;
end
% =========================================================================
% TASK
% For different Damping Factor and BnTs calculate coefficients of loop filter
% What changes in synchronisation when the loop filter coefficients are recalculated?
% Illustrate these changes on the graphs
% How did the constellation change?
% -------------------------------------------------------------------------

RX_IQ_DM = Channel_IQ.*exp(1j.*2.*pi.*dfT.*(1:length(Channel_IQ)));
DM_estimate = dfT_arr(dfT_arr~=0);
end

