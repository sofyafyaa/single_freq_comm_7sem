function [rmse] = rmse(x, y)
%RMSE Summary of this function goes here
%   Detailed explanation goes here
rmse = sqrt(mean((x-y).*conj(x-y)));
end

