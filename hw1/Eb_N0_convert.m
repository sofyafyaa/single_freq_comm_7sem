function [Eb_N0] = Eb_N0_convert(SNR, Constellation)
    switch Constellation
        case "BPSK"
            bitperpoint = 1;
        case "QPSK"
            bitperpoint = 2;
        case "8PSK"
            bitperpoint = 3;
        case "16-QAM"
            bitperpoint = 4;
    end
    Eb_N0 = SNR + 10*log10(1/bitperpoint);
end