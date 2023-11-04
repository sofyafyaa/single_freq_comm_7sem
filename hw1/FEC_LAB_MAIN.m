%============================= Part 1  Warmup =====================================
% configuring LDPC encoder and decoder
clear; clc; close;
% prototype matrix as defnied in Wi-Fi (IEEE® 802.11)
P = [
    16 17 22 24  9  3 14 -1  4  2  7 -1 26 -1  2 -1 21 -1  1  0 -1 -1 -1 -1
    25 12 12  3  3 26  6 21 -1 15 22 -1 15 -1  4 -1 -1 16 -1  0  0 -1 -1 -1
    25 18 26 16 22 23  9 -1  0 -1  4 -1  4 -1  8 23 11 -1 -1 -1  0  0 -1 -1
     9  7  0  1 17 -1 -1  7  3 -1  3 23 -1 16 -1 -1 21 -1  0 -1 -1  0  0 -1
    24  5 26  7  1 -1 -1 15 24 15 -1  8 -1 13 -1 13 -1 11 -1 -1 -1 -1  0  0
     2  2 19 14 24  1 15 19 -1 21 -1  2 -1 24 -1  3 -1  2  1 -1 -1 -1 -1  0
    ];
blockSize = 27; % N.B. this blocksize is connected with optimized pairty check matrix generation method 
                % it is NOT the blocksize of the ldpc
                % https://prezi.com/aqckvai6jux-/ldpc/?utm_campaign=share&utm_medium=copy

H = ldpcQuasiCyclicMatrix(blockSize,P); % getting parity-check matrix

cfgLDPCEnc = ldpcEncoderConfig(H); % configuring encoder
cfgLDPCDec = ldpcDecoderConfig(H); % configuring decoder

% using cfgLDPCEnc variable, print our the number of inofrmation, parity
% check bits and the coderate
fprintf('Number of information bits in a block: %d\n', cfgLDPCEnc.NumInformationBits);
fprintf('Number of parity check bits in a block: %d\n', cfgLDPCEnc.NumParityCheckBits);
coderate = cfgLDPCEnc.NumInformationBits / cfgLDPCEnc.BlockLength;
fprintf('Coderate: %f\n', coderate);

%% simple test to check that encoder and decoder configured correctly

test_message = boolean(randi([0 1],cfgLDPCEnc.NumInformationBits,1,'int8'));
encodedData = ldpcEncode(test_message,cfgLDPCEnc);

% calculate the syndrome
s = full(H) * encodedData; % YOUR CODE HERE
s=mod(s, 2); % we need xor instead of multiplication
if(~any(s))
    fprintf('No errors!\n');
else
    fprintf('Errors detected during syndrome check!\n');
end

% deliberately distorting one bit of the message
encodedData(randi(numel(encodedData))) = ~(encodedData(randi(numel(encodedData))));

% checking the syndrome once again
s = full(H) * encodedData; %YOUR CODE HERE
s=mod(s, 2); % we need xor instead of multiplication
if(~any(s))
    fprintf('No errors!\n');
else
    fprintf('Errors detected during syndrome check!\n');
end

%% ============= Part 2 comparing coded and uncoded system =================

maxnumiter = 10;
snr = -5:8;
numframes = 10000;

% check manual on the build-in ber counter
% it outputs three variables
ber = comm.ErrorRate; %build-in BER counter
ber2 = comm.ErrorRate; %build-in BER counter

% arrays to store error statistic
errStats = zeros(length(snr), numframes, 3); 
errStatsNoCoding = zeros(length(snr), numframes, 3);

Constellation = "QPSK";

tStart = tic;
for ii = 1:length(snr)
    for counter = 1:numframes
        data = randi([0 1],cfgLDPCEnc.NumInformationBits,1,'int8');
        % Transmit and receive with LDPC coding
        encodedData = ldpcEncode(data,cfgLDPCEnc);
        
        % YOUR MAPPER HERE choose any constellation type you like
        modSignal = mapping(encodedData.', Constellation);

        [rxsig, noisevar] = NoiseGenerator(modSignal,snr(ii));

        % YOUR DEMAPPER HERE N.B. Perform Soft Demapping, output llr!
        llr = demapping(rxsig, Constellation, 1, snr(ii));

        rxbits = ldpcDecode(llr,cfgLDPCDec,maxnumiter);

        errStats(ii, counter, :) = ber(data,rxbits);

        %========================================
        
        % no coding system
        noCoding = mapping(data.', Constellation);
        rxNoCoding =NoiseGenerator(noCoding,snr(ii));

        % YOUR DEMAPPER HERE N.B. Perform Hard Demapping, output bits!
        rxBitsNoCoding = demapping(rxNoCoding, Constellation, 0, noisevar);

        errStatsNoCoding(ii, counter, :) = ber2(data,int8(rxBitsNoCoding.'));
    end

    fprintf(['SNR = %2d\n   Coded: Error rate = %1.2f, ' ...
        'Number of errors = %d\n'], ...
        snr(ii),mean(errStats(ii, :, 1), 2), mean(errStats(ii, :, 2), 2))
    fprintf(['Noncoded: Error rate = %1.2f, ' ...
        'Number of errors = %d\n'], ...
        mean(errStatsNoCoding(ii, :, 1), 2), mean(errStatsNoCoding(ii, :, 2), 2))
    reset(ber);
    reset(ber2);
end

%%
h(1) = figure;
semilogy(snr, mean(errStatsNoCoding(:, :, 1), 2), 'LineWidth', 2)
hold on
semilogy(snr, mean(errStats(:, :, 1), 2), 'LineWidth', 2)
hold off
xlabel('SNR, dB');
ylabel('BER')
grid on
set(gca, 'Fontsize', 20)
savefig(h(1), 'BER_SNR_results.fig')

% Replot the results in BER vs Eb/N0 scale +
h(2) = figure;
EbN0_dB = Eb_N0_convert(snr, Constellation);
semilogy(EbN0_dB, mean(errStatsNoCoding(:, :, 1), 2), 'LineWidth', 2)
hold on
semilogy(EbN0_dB, mean(errStats(:, :, 1), 2), 'LineWidth', 2)
hold off
xlabel('Eb/N0, dB');
ylabel('BER')
grid on
set(gca, 'Fontsize', 20)
savefig(h(2), 'BER_EbN0_results.fig')

% how the shape of curves has changed?
% shape of curves has not changed

% what is the gain in dB?
% 0.1   level of BER -- gain 0 dB
% 0.01  level of BER -- gain 3.2 dB
% 0.001 level of BER -- gain 5.1 dB

%% ================ Part 3: default LDPC with different numbers of iterations =========================

% change the snr range to capture behaviour of coded curves only
snr2 = 3:0.2:5;

maxnumiters = [5, 20]; % we will plot curves for two values of decoding iterations
numframes = 5000;
errStats_it_num = zeros(length(snr2), numframes, 3, numel(maxnumiters));

tStart = tic;

% +10 points for using parfor here and calculating speedup
for ii = 1:length(snr2)
    for m = 1:numel(maxnumiters)
        maxnumiter = maxnumiters(m);
        for counter = 1:numframes
            data = randi([0 1],cfgLDPCEnc.NumInformationBits,1,'int8');
            % Transmit and receive with LDPC coding
            encodedData = ldpcEncode(data,cfgLDPCEnc);

            % YOUR MAPPER HERE choose any constellation type you like
            modSignal = mapping(encodedData.', Constellation);

            [rxsig, noisevar] = NoiseGenerator(modSignal,snr2(ii));

            % YOUR DEMAPPER HERE N.B. Perform Soft Demapping, output llr!
            llr = demapping(rxsig, Constellation, 1, snr2(ii));

            rxbits = ldpcDecode(llr,cfgLDPCDec,maxnumiter);
            br = ber(data,rxbits);
            errStats_it_num(ii, counter, :, m) = br;
        end
        fprintf(['SNR = %2d\n   Coded with %d iterations: Error rate = %1.5f, ' ...
            'Number of errors = %d\n'], ...
            snr2(ii), maxnumiter, mean(errStats_it_num(ii, :, 1, m), 2), mean(errStats_it_num(ii, :, 2, m), 2))
        reset(ber);
    end
end
ber.release();
tend = toc(tStart);
fprintf('Simulation finished in %.2f s\n', tend);

% TOTAL TIME: 263.76 s
%% With parfor
tStart_parfor = tic;

for ii = 1:length(snr2)
    for m = 1:numel(maxnumiters)
        maxnumiter = maxnumiters(m);
        parfor counter = 1:numframes
            data = randi([0 1],cfgLDPCEnc.NumInformationBits,1,'int8');
            % Transmit and receive with LDPC coding
            encodedData = ldpcEncode(data,cfgLDPCEnc);

            % YOUR MAPPER HERE choose any constellation type you like
            modSignal = mapping(encodedData.', Constellation);

            [rxsig, noisevar] = NoiseGenerator(modSignal,snr2(ii));

            % YOUR DEMAPPER HERE N.B. Perform Soft Demapping, output llr!
            llr = demapping(rxsig, Constellation, 1, snr2(ii));

            rxbits = ldpcDecode(llr,cfgLDPCDec,maxnumiter);
            br = ber(data,rxbits);
            errStats_it_num(ii, counter, :, m) = br;
        end
        fprintf(['SNR = %2d\n   Coded with %d iterations: Error rate = %1.5f, ' ...
            'Number of errors = %d\n'], ...
            snr2(ii), maxnumiter, mean(errStats_it_num(ii, :, 1, m), 2), mean(errStats_it_num(ii, :, 2, m), 2))
        reset(ber);
    end
end
ber.release();
tend_parfor = toc(tStart_parfor);
fprintf('Simulation finished in %.2f s\n', tend_parfor);

% TOTAL TIME: 256.98 s
% 7.2 sec faster 

%%
h(1) = figure;
semilogy(snr, mean(errStatsNoCoding(:, :, 1), 2), 'LineWidth', 2)
hold on
for m = 1:numel(maxnumiters)
    semilogy(snr2, mean(errStats_it_num(:, :, 1, m), 2), 'LineWidth', 2)
    hold on
end
hold off
grid on
xlabel('SNR, dB')
ylabel('BER')
set(gca, 'FontSize', 20)
legend('No coding', strcat('LDPC 3/4 ', 32, num2str(maxnumiters(1)), 32,'iterations'), strcat('LDPC 3/4 ', 32, num2str(maxnumiters(2)), 32, 'iterations'));

savefig(h(1), 'BER2_SNR_results.fig')

% change the plot to Eb/N0 scale!
h(2) = figure;
EbN0_dB1 = Eb_N0_convert(snr, Constellation);
EbN0_dB2 = Eb_N0_convert(snr2, Constellation);

semilogy(EbN0_dB1, mean(errStatsNoCoding(:, :, 1), 2), 'LineWidth', 2)
hold on
for m = 1:numel(maxnumiters)
    semilogy(EbN0_dB2, mean(errStats_it_num(:, :, 1, m), 2), 'LineWidth', 2)
    hold on
end
hold off
grid on
xlabel('Eb/N0, dB')
ylabel('BER')
set(gca, 'FontSize', 20)
legend('No coding', strcat('LDPC 3/4 ', 32, num2str(maxnumiters(1)), 32,'iterations'), strcat('LDPC 3/4 ', 32, num2str(maxnumiters(2)), 32, 'iterations'));

savefig(h(2), 'BER2_EBN0_results.fig')

%% ========================= Part 4: diffrent decoding methods with the same max number of iterations

% https://www.mathworks.com/help/comm/ref/ldpcdecode.html
cfgLDPCDec2 = ldpcDecoderConfig(H, 'norm-min-sum'); % configuring second decoder
maxnumiter = 10;
snr2 = 3:0.2:5;
numframes = 10000;

errStats_minsum = zeros(length(snr2), numframes, 3);
errStats_bp = zeros(length(snr2), numframes, 3);

ber = comm.ErrorRate;
ber2 = comm.ErrorRate;

MinSumScalingFactor = 0.9; % task: find the best parameter 

tStart_4 = tic;


for ii = 1:length(snr2)
    t_min_sum_i = 0;
    t_bp_i = 0;
    for counter = 1:numframes
        data = randi([0 1],cfgLDPCEnc.NumInformationBits,1,'int8');
        % Decode with belief propagation
        encodedData = ldpcEncode(data,cfgLDPCEnc);

        % YOUR MAPPER HERE choose any constellation type you like
        modSignal = mapping(encodedData.', Constellation);

        [rxsig, noisevar] = NoiseGenerator(modSignal, snr2(ii));

        llr = demapping(rxsig, Constellation, 1, snr2(ii));
        
        % decode with MinSum
        rxbits = ldpcDecode(llr,cfgLDPCDec2,maxnumiter, 'MinSumScalingFactor', MinSumScalingFactor);

        errStats_minsum(ii, counter, :) = ber(data,rxbits);

        % ================================
        % Decode with layered belief propagation

        rxbits = ldpcDecode(llr,cfgLDPCDec,maxnumiter);
        errStats_bp(ii, counter, :) = ber2(data,rxbits);
    end

    fprintf(['SNR = %2d\n   Min Sum decoding: Error rate = %e, ' ...
        'Number of errors = %d'], ...
        snr2(ii),mean(errStats_minsum(ii, :, 1), 2), mean(errStats_minsum(ii, :, 2), 2))
    fprintf(['BP decoding: Error rate = %e, ' ...
        'Number of errors = %d'], ...
        mean(errStats_bp(ii, :, 1), 2), mean(errStats_bp(ii, :, 2), 2))
    reset(ber);
    reset(ber2);
end
t_4 = toc(tStart_4);
%%
fprintf('Simulation finished after %.2f s\n', t_4);

%%

semilogy(snr2, mean(errStats_minsum(:, :, 1), 2))
hold on
semilogy(snr2, mean(errStats_bp(:, :, 1), 2), '--')
hold off

legend('MinSum', 'Belief Propagation')
xlabel('SNR, dB')
ylabel('BER')
grid on
set(gca, 'FontSize', 20)

save('BER_SNR_results.mat', 'errStats_minsum', 'errStats_bp', '-append')

%% Part four: compare the speed of the algorithms

% Minsum faster than Belief Propagation on 10 sec