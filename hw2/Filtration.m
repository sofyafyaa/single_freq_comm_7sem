% Фильтрация
%> @file Filtration.m
% =========================================================================
%> @brief Фильтрация
%> @param sign входной сигнал сигнал
%> @param coeff коэффиценты фильтра
%> @param nsamp число выборок на символ
%> @param UpSampFlag [1] -  фильтр с передискретизацией,[0] - фильтр без передискретизации 
%> @return filtsign отфильтрованный сигнал  
% =========================================================================
function filtsign = Filtration(sign, coeff, nsamp, UpSampFlag)
    if UpSampFlag == true
       sign_interp = zeros(1, length(sign) * nsamp);
       sign_interp(1:nsamp:end) = sign;

       filtsign = conv(coeff, sign_interp, 'full');
       filtsign = filtsign(1 : length(sign_interp));
    else 
       filtsign = conv(coeff, sign, 'full');
       filtsign = filtsign(1 : length(sign));
    end
    
end 