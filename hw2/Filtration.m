% ����������
%> @file Filtration.m
% =========================================================================
%> @brief ����������
%> @param sign ������� ������ ������
%> @param coeff ����������� �������
%> @param nsamp ����� ������� �� ������
%> @param UpSampFlag [1] -  ������ � ������������������,[0] - ������ ��� ����������������� 
%> @return filtsign ��������������� ������  
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