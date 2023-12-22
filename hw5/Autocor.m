function Autocor_res = Autocor(Signal)

    Autocor_res(1 : length(Signal)) = 0;
    
    for itter_cor = 1 : length(Signal)
        shif_sz = itter_cor - round(length(Signal)/2);
        Autocor_res(itter_cor) = (sum(Signal .* circshift(Signal, shif_sz)))/length(Signal);
    end

end