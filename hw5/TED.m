function [sign_sinc, TED_arr] = TED(sign_channel, nsamp)

sign_sinc = [];

CNT = 0; % mod caounter
mu = 0;  % start time delay
SempFlag = 0; % if sample
integr = 0; % integrationa part of LP init

% Interpolation coefficients
alpha = 0.5;
interp_coeff = [     0,       0,         1,       0;
                 -alpha, 1+alpha, -(1-alpha), -alpha;
                  alpha,  -alpha,    -alpha,   alpha];

TED_arr(1:4, 1) = 0;

zeta = sqrt(2);
BnTs = 0.05;
Kp = 2.7;
K0 = -1; 

Kd = 2*pi;
wp = BnTs / (zeta + 1/(4*zeta));

g1 = 2 - 2 * exp(-wp*zeta/nsamp) * cos(wp/nsamp*sqrt(1-zeta^2));
K1 = g1/Kd/K0;
g2 = exp(-2*wp*zeta/nsamp)-1+g1;
K2 = g2/Kd/K0;

mu_arr = [];
for itter_time = 4 : length(sign_channel) - nsamp
    time_grid     = [1, mu, mu^2];
    interp_values = [sign_channel(itter_time+2); sign_channel(itter_time+1); ...
                     sign_channel(itter_time); sign_channel(itter_time-1)];
    sign_interp = time_grid * interp_coeff * interp_values;

    if SempFlag == 1
        Re = real(TED_arr(2)) * (real(TED_arr(4)) - real(sign_interp));
        Im = imag(TED_arr(2)) * (imag(TED_arr(4)) - imag(sign_interp));
        e = Re + Im; % interpolation error
        sign_sinc = [sign_sinc; sign_interp];
    else
        e = 0;
    end

    % Loop Filter
    prop = K1*e;
    integr = integr + K2*e;
    sign_lp = prop + integr;
    % Modulo counter
    cnt_it = sign_lp + 1/nsamp;
    CNT = CNT - cnt_it;

    if CNT<0
        mu = CNT/cnt_it + 1;
        mu_arr = [mu_arr, mu];
        CNT = CNT + 1;
        SempFlag = 1;
    else
        SempFlag = 0;
    end
    TED_arr = [sign_interp; TED_arr(1:end-1)];
end

TED_arr = mu_arr;
end

