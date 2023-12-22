%% Лабораторная работа # 5 Символьная синхронизация

clear all; close all; clc;

%% Transmitter

bits_tx = scrambler().';

sign_tx = mapping(bits_tx, 'QPSK');

% scatterplot(sign_tx)
% title('Before RRC')

% Согл фильтрация
span = 20;
nsamp = 4;
rolloff = 0.2;
UpSempFlag = true(1);
sqimpuls = sqRCcoeff(span, nsamp, rolloff);

filtsign_tx = filtration(sign_tx, sqimpuls, nsamp, UpSempFlag);

scatterplot(filtsign_tx, nsamp)
title('After RRC')

%% Channel

% STO
time_delay = 0.1;
TimeDelayObj = dsp.VariableFractionalDelay('InterpolationMethod', 'Farrow',...
                                                      'MaximumDelay', nsamp);
sign_channel = step(TimeDelayObj, filtsign_tx.', time_delay);

scatterplot(sign_channel, nsamp)
title('After STO = 0.1')

% SCO
% ppm = 10;
% sco = 0 : 0.00001 : 1;
% sign_channel = resample(filtsign_tx, 3, 2);

% AWGN
% sign_channel = NoiseGenerator(sign_channel.', 20);

%% Receiver

% Cогласованная фильтрация
UpSempFlag = false(1);
sign_rx_filter = filtration(sign_channel, sqimpuls, nsamp, UpSempFlag);

sign_rx_resample = sign_rx_filter(1:nsamp:end);

scatterplot(sign_rx_resample)
title('After RX RRC')

[sign_sinc_rx, TED_arr] = TED(sign_rx_filter, nsamp);

scatterplot(sign_sinc_rx(10000:end), nsamp)
title('After TED, STO=0.1')

figure;
plot(TED_arr)
title('сходимость')

