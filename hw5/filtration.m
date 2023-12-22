% Фильтрация
%> @file filtration.m
% =========================================================================
%> @brief Фильтрация
%> @param sign входной сигнал сигнал
%> @param coeff коэффиценты фильтра
%> @param nsamp число выборок на символ
%> @param UpSempFlag [1] -  фильтр с передескретезацией,[0] - фильтр без передескретизации 
%> @return filtsign отфильтрованный сигнал 
% =========================================================================
function filtsign = filtration(sign, coeff, nsamp, UpSempFlag)
    if UpSempFlag
        new_sign = zeros( 1, nsamp*numel(sign));
        for i = 1:numel(sign)
            new_sign(nsamp*(i-1) +1) = sign(i);
        end
        sign = new_sign;
    end
    
    buf = zeros(1, numel(coeff));
    for i = 1:numel(sign)
        buf = circshift(buf, -1);
        buf(end) = sign(i);
        filtsign(i) = sum(buf .* coeff);
    end
end 