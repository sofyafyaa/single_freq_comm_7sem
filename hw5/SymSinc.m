function [sincsign, TEDBuff] = SymSinc(sign)
        sincsign = [];
        nsamp = 4;
        CNT = 0;
        mu = 0; 
        alpha = 0.5;
        InterpCoeff = ...                          % c
            [     0,       0,         1,       0;  % Constant
             -alpha, 1+alpha, -(1-alpha), -alpha;  % Linear
              alpha,  -alpha,    -alpha,   alpha]; % Quadratic
         SempFlag = 0;
         TEDBuff(1:4,1) = 0;
         part_i = 0;
        zeta = sqrt(2);
        BnTs = 0.005;
        Kp = 2.7;
        K0 = -1; 
        
        Kd = 2*pi;
        wp = BnTs / (zeta + 1/(4*zeta));

        % todo K1 = 
        g1 = 2 - 2 * exp(-wp*zeta/nsamp) * cos(wp/nsamp*sqrt(1-zeta^2));
        K1 = g1/Kd/K0;
        % todo K2 =
        g2 = exp(-2*wp*zeta/nsamp)-1+g1;
        K2 = g2/Kd/K0;
       
   % ======================================================================
   %> Основной цикл
   %=======================================================================

   for i = 4:length(sign)-nsamp
        %> Интерполяция (делаем интерполяцию по 4 точкам, полиномом 2ой степени)
        % todo IntepolOut = 
        time_grid     = [1, mu, mu^2];
        interp_values = [sign(i+2); sign(i+1); sign(i); sign(i-1)];
        IntepolOut = time_grid * InterpCoeff * interp_values;
        
        %> Расчитываем ошибку (расчитывается только перед выборкой)
        if SempFlag == 1
            e_I = real(TEDBuff(2)) * (real(TEDBuff(4)) - real(IntepolOut));
            e_Q = imag(TEDBuff(2)) * (imag(TEDBuff(4)) - imag(IntepolOut));
            e = e_I + e_Q;
            % Выборка 
            sincsign = [sincsign; IntepolOut];
        else
            e = 0;
        end
        % Петлевой фильтр part_p пропорциональная часть
        % part_p пропорцилнальная часть
        % part_i интегральная часть
        % todo part_p =,  part_i =
        part_p = K1*e;
        part_i = part_i + K2*e;
        
        % Выход фильтра
        out = part_p+part_i;
        % Счетчик по модулю 2
        step = out + 1/nsamp;
        % todo шаг счетчика
        CNT = CNT-step;
        if CNT<0
            mu = CNT/step + 1;
            CNT = CNT+1;
            SempFlag = 1;
        else
            SempFlag = 0;
        end
        TEDBuff = [IntepolOut; TEDBuff(1:end-1)];
    end
end 