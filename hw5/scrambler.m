function pilot_block = scrambler()
    
seq_length = 2^17-2;

register = [1  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  1];

pilot_block = zeros(seq_length, 1);

    for itter = 1 : seq_length
        new_register = xor(register(end),   ...
                       xor(register(end-3), ...
                           register(end-16)));
        
        %generation of PN-sequence
        pilot_block(itter, 1) = new_register;
    
        % linear feedback
        register = circshift(register, 1);
        register(1) = new_register;
    end