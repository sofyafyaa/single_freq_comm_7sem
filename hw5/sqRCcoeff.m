% Генерация коэффицентов (импульсной характеристики)для фильтра корень 
% из приподнятого косинуса
%> @file sqRCcoeff.m
% =========================================================================
%> @brief Генерация коэффицентов (импульсной характеристики)для фильтра корень 
%> из приподнятого косинуса
%> @param span Длина фильтра в символах (количество боковых лепестков sinc, 
%> сумма с двух сторон)
%> @param nsamp Число выборок на символ
%> @param rolloff Коэффицент сглаживания (alfa)
%> @return coeff коэффиценты для фильтра корень из приподнятого косинуса
% =========================================================================
function coeff = sqRCcoeff (span, nsamp, rolloff)
    duration = nsamp*span;
    t = -duration/2 : duration/2;
    t(t == 0) = 1e-12;
    Ts = nsamp; 

    h = (1 / sqrt(Ts)) .* ...
        ((sin(pi * (1 - rolloff) .* t / Ts) ...
        + (4*rolloff .* t / Ts) .* cos(pi * (1 + rolloff) .* t / Ts))) ...
        ./ ((pi .* t / Ts) .* (1 - (4*rolloff .* t / Ts).^2));

    h(t == 0) = (1 / sqrt(Ts)) * (1 + rolloff*(4/pi - 1));

    h(abs(t) == int8(Ts / (4*rolloff))) = (rolloff / sqrt(Ts) / sqrt(2)) * ...
                ((1 + 2 / pi) * sin(pi / (4*rolloff)) ...
                + (1 - 2 / pi) * cos(pi / (4*rolloff)));

    coeff = h;
end