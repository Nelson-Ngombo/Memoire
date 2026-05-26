function Z_harmonics = extractHarmonics(v, i, samplingFreq, harmonicFreqs)
    N = length(v);
    freqs = (0:N-1) * (samplingFreq / N);
    
    % Calcul FFT normalisée
    V = fft(v) / (N / 2);
    I = fft(i) / (N / 2);
 
    indices = 1:floor(N/2);  
    freqs_values = freqs(indices);
    V_values = V(indices);
    I_values = I(indices);

    Z_harmonics = zeros(length(harmonicFreqs), 1);

    for k = 1:length(harmonicFreqs)
        idx = find(abs(freqs_values - harmonicFreqs(k)) < (samplingFreq/N)/2, 1);
        if ~isempty(idx)
            % Garder l'impédance complexe (phase importante pour fdident)
            Z_harmonics(k) = V_values(idx) / I_values(idx);
        end
    end
end 