% Фильтрация.
% =========================================================================
%> Подготовка рабочего места
% =========================================================================
    %> Отчистка workspace
    clear all;
    %> Закрытие рисунков
    close all;
    %> Отчистка Command Window
    clc;
% =========================================================================
%> Функция sinc. Пример из лекции.
% =========================================================================
    %> Генерим массив
%     x = -10:0.1:10;
    %> Функция sinc
%     y = sinc(x);
    % =====================================================================
    %> График импульсной характеристики
    % =====================================================================
%     figure 
%     plot(x,y)
%     title('sinc(x)')
    % =====================================================================
    %> График спектра
    % =====================================================================
    %> Фурье + спектр в дБ
%     spectum = 10*log10(abs(fft(y)));
    %> Полоса по центру
%     spectum = [spectum(102:201), spectum(1:101)];
    %> график с учетом T = 2 (см. свойства sinc)
%     figure 
%     plot(x/2, spectum)
%     title('spectum sinc(x)')
%% ========================================================================
%> Задача 1: Написать функцию, которая генерирует коэффиценты (импульсную 
%> характеристику)для фильтра корень из приподнятого косинуса.
%> Построить импульсную и частотную характеристику фильтра.
% =========================================================================
    %> Длина фильтра в символах (число боковых лепестков sinc, сумма с двух сторон)
    span = 20;
    %> Число выборок на символ
    nsamp  = 4;
    %> Коэффицент сглаживания (alfa)
    rolloff = 0.2;
    % =====================================================================
    %> @todo прописать функцию
    sqimpuls = sqRCcoeff (span, nsamp, rolloff);

    %> @todo построить импульсную и частотную характеристику фильтра
    n = -span*nsamp / 2 : span*nsamp / 2;
    f = -nsamp / 2 : 1 / span :nsamp/2;
    figure 
    plot(n,sqimpuls)
    title('Root raise cosine')

    spectum = 10*log10(abs(fftshift(fft(sqimpuls))));
    figure 
    plot(f, spectum)
    title('spectum RRC')
% =========================================================================
%> Проверка 1.
%> Сравнение со стандартной функцией
% =========================================================================
txfilter1 = comm.RaisedCosineTransmitFilter('RolloffFactor', rolloff, ...
                                           'FilterSpanInSymbols',span,...
                                           'OutputSamplesPerSymbol', nsamp);
check1 = coeffs(txfilter1);
if sum(abs(check1.Numerator-sqimpuls))< 0.001 % Проверка совпадения форм 
                                              % Импульсных характеристик 
                                              % с заданной точностью
    ans = 'Проверка задачи 1 пройдена успешно'
else 
    err = 'Ошибка в задаче 1. Проверьте коэффиценты'
    ans = sum(abs(check1.Numerator-sqimpuls))
end


%% ========================================================================
%> Задача 2: Написать функцию, которая генерирует коэффиценты (импульсную 
%> характеристику) для фильтра приподнятого косинуса.
%> Построить импульсную и частотную характеристику фильтра.
%> Построить импульсную характеристику для корня, без корня и соответсвующий sinc 
%> на одном графике
% =========================================================================
    %> Длина фильтра в символах (число боковых лепестков sinc, сумма с двух сторон)
    span = 20;
    %> Число выборок на символ
    nsamp  = 4;
    %> Коэффицент сглаживания (alfa)
    rolloff = 0.2;
    % =====================================================================
    %> @todo прописать функцию
    impuls = RCcoeff(span, nsamp, rolloff);
    %> @todo построить импульсную и частотную характеристику фильтра

    n = -span*nsamp / 2 : span*nsamp / 2;
    f = -nsamp / 2 : 1 / span :nsamp/2;
    figure 
    plot(n,impuls)
    title('Raise cosine(x)')

    spectum = 10*log10(abs(fftshift(fft(impuls))));
    figure 
    plot(f, spectum)
    title('spectum RC')
    
% =========================================================================
%> Проверка 2.
%> Сравнение со стандартной функцией
% =========================================================================
txfilter2 = comm.RaisedCosineTransmitFilter('RolloffFactor', rolloff, ...
                                            'FilterSpanInSymbols',span,...
                                            'OutputSamplesPerSymbol', nsamp,...
                                            'Shape', 'Normal');
check2 = coeffs(txfilter2);
if sum(abs(check2.Numerator-impuls))< 0.1 % Проверка совпадения форм 
                                          % Импульсных характеристик 
                                          % с заданной точностью
    ans = 'Проверка задачи 2 пройдена успешно'
else 
    err = 'Ошибка в задаче 2. Проверьте коэффиценты'
    ans = sum(abs(check2.Numerator-impuls))
end


%% ========================================================================
%> Задание 3. 
%> Напишите функцию фильтрации, которая работает в двух режимах: с
%> увеличением колличества выборок на символ и без (повторная фильтрация)
%> @warning используется функция mapping из прошлых работ
% =========================================================================
    UpSempFlag = true(1);
    bits = randi([0 1], 1, 1000); % генерация бит
    sign = mapping(bits, 'QPSK'); % QPSK 500 символов 
    
    filtsign = Filtration(sign, sqimpuls, nsamp, UpSempFlag);
    
    %% =====================================================================
    %> Проверка 3.1
    %> Проверяем корректность работы ф-ии с передескретизацией со станднартной функцией.
    % =====================================================================
    check3 = txfilter1(sign.').';

    if sum(abs(check3-filtsign))< 0.1 % Проверка совпадения форм 
                                      % Импульсных характеристик 
                                      % с заданной точностью
        ans = 'Проверка задачи 3.1 пройдена успешно'
    else 
        err = 'Ошибка в задаче 3.1. Проверьте фильтр'
        ans = sum(abs(check3-filtsign))
    end

    figure
    plot(filtsign)
    title('Сигнальное созвездие после RRC фильтра TX');

    % =====================================================================
    %> Проверка 3.2
    %> Проверяем корректность работы ф-ии без передескретизации со станднартной функцией.
    % =====================================================================
    UpSempFlag = false(1); 
    filtsign2 = Filtration(filtsign, sqimpuls, nsamp, UpSempFlag);
    rxfilter = comm.RaisedCosineReceiveFilter('RolloffFactor', rolloff, ...
                                              'FilterSpanInSymbols',span,...
                                              'InputSamplesPerSymbol', nsamp,...
                                              'DecimationFactor', 1);
    check4 = rxfilter(filtsign.').';
    if sum(abs(check4-filtsign2))< 0.1 % Проверка совпадения форм 
                                       % Импульсных характеристик 
                                       % с заданной точностью
        ans = 'Проверка задачи 3.2 пройдена успешно'
    else 
        err = 'Ошибка в задаче 3.2. Проверьте фильтр'
        ans = sum(abs(check4-filtsign2))
    end

    figure
    plot(filtsign2)
    title('Сигнальное созвездие после RRC фильтра RX');

    %% ====================================================================
    %> Задание 4
    %> Система с шумом
    % =====================================================================
    
    UpSempFlag = true(1);
    bits = randi([0 1], 1, 1000); % генерация бит
    sign = mapping(bits, 'QPSK'); % QPSK 500 символов 
    
    filtsign_tx = Filtration(sign, sqimpuls, nsamp, 1);
    
    [filtsign_noise, noise] = NoiseGenerator(filtsign_tx, 10); 

    filtsign_rx = Filtration(filtsign_noise, sqimpuls, nsamp, 0);

    figure
    plot(filtsign_rx)
    title('Сигнальное созвездие после RRC фильтра TX');
    
    n = 1:2000;
    figure
    plot(n, filtsign_tx, n, filtsign_rx)
    title('Сигнальное созвездие после RRC фильтра RX');

    signal_downsample = filtsign_rx(1:4:end);

    n = 1:500;
    figure
    plot(n, sign, n, signal_downsample)
    title('Сигнальное созвездие после RRC фильтра RX');

    % Появилась задержка в 20 отсчетов
    
    n = 1 : 500 - 20;
    figure
    plot(n, sign(1:end-20), n, signal_downsample(21:end))
    title('Сигнальное созвездие после RRC фильтра RX');

    % При 30 db сигналы на rx и tx полностью совпали

    %% Freq offset

    bits = randi([0 1], 1, 1000); % генерация бит
    sign = mapping(bits, 'QPSK'); % QPSK 500 символов 

    samplerate = 4;
    offset = 100e10;

    filtsign_tx = Filtration(sign, sqimpuls, nsamp, 1);
    
    t = 1:2000;
    delta_f = 1e-6;
    offset = exp(2*pi*1i*delta_f.*t);
    filtsign_offset = filtsign_tx .* offset;
    
    [filtsign_noise, noise] = NoiseGenerator(filtsign_offset, 30);

    filtsign_rx = Filtration(filtsign_noise, sqimpuls, nsamp, 0);

    signal_downsample = filtsign_rx(1:4:end);

%     n = 1:500;
%     figure
%     plot(n, sign, n, signal_downsample)
%     title('Сравнение сигналов (после downsampling)');
% 
%     n = 1 : 500 - 20;
%     figure
%     plot(n, sign(1:end-20), n, signal_downsample(21:end))
%     title('Сравнение сигналов (после downsampling & задержкой фильтра)');


    %% calculate MER
freq_offset_percent = 0.0001: 1 :1000;

MER = zeros(length(freq_offset_percent));

for ii = 1 : length(freq_offset_percent)
    bits = randi([0 1], 1, 1000); % генерация бит
    sign = mapping(bits, 'QPSK'); % QPSK 500 символов 

    filtsign_tx = Filtration(sign, sqimpuls, nsamp, 1);
    
    t = 1:2000;
    delta_f = freq_offset_percent(ii) / 1000;
    offset = exp(2*pi*1i*delta_f.*t);
    filtsign_offset = filtsign_tx .* offset;
    
    [filtsign_noise, noise] = NoiseGenerator(filtsign_offset, 30);

    filtsign_rx = Filtration(filtsign_noise, sqimpuls, nsamp, 0);

    signal_downsample = filtsign_rx(1:4:end);

    MER(ii) = MER_my_func(signal_downsample, 'QPSK');
end

plot(freq_offset_percent / 10, MER)











    











