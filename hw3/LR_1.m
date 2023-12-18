function [RX_IQ_LR, LR_estimate] = LR_1(Channel_IQ, N, Amount_of_Frame)

% Reshaping & pilot detecting
frame_sz = size(Channel_IQ);
Channel_IQ = reshape(Channel_IQ.', 1, []);

SOF = [1 0 0 1 1 1 0 1 0 1 0 1 0 1 1 0 0 1 0 0]; 
SOF_IQ = mapping(SOF, 'BPSK');
data_len = frame_sz(2) - length(SOF_IQ);
Pilots = repmat([SOF_IQ, zeros(1, data_len)], 1, frame_sz(1));

% Initialization
dfT_arr = zeros(1, Amount_of_Frame);
RX_IQ_LR = zeros(1, length(Channel_IQ));
RX_IQ_LR(1:N) = Channel_IQ(1:N);

LR_NCO = 0;
dfT = 0;

while itter_time <= length(Channel_IQ)
    
    % Phase detector
    
    R_m_sum = 
    f_d = R_m_sum /pi/(N+1);
    


end



end

