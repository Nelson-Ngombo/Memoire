function [Z_all, Ah_mes, T_mean_all] = Impedance(v, i, t_temp, harmonicFreqs, samplingFreq, AhStep, dschI, lengthChunk)
    % Calcul du nombre d'échantillons à sauter
    samplesToSkip = round(AhStep * 3600 * samplingFreq / dschI);
    totalChunks = floor((length(v) - lengthChunk) / (lengthChunk + samplesToSkip)) + 1;
    
    Z_all = zeros(totalChunks, length(harmonicFreqs));
    T_mean_all = zeros(totalChunks, 1);
    
    for chunkNr = 1:totalChunks
        [chunkV, chunkI, chunkT] = getSignalChunck(v, i, t_temp, samplingFreq, dschI, AhStep, chunkNr, lengthChunk);
        
        % Extraction des harmoniques (avec Hanning)
        Z_harmonics = extractHarmonics(chunkV, chunkI, samplingFreq, harmonicFreqs);
        Z_all(chunkNr, :) = Z_harmonics';
        
        % Température moyenne du segment
        T_mean_all(chunkNr) = mean(chunkT);
    end
    
    % Calcul total des Ah tirés
    Ah_mes = length(v) * (1 / samplingFreq / 3600) * dschI;
end 