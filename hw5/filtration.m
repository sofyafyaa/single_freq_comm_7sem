% ����������
%> @file filtration.m
% =========================================================================
%> @brief ����������
%> @param sign ������� ������ ������
%> @param coeff ����������� �������
%> @param nsamp ����� ������� �� ������
%> @param UpSempFlag [1] -  ������ � ������������������,[0] - ������ ��� ����������������� 
%> @return filtsign ��������������� ������ 
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