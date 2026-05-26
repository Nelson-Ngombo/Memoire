function [Ah_vals, T_vals, Zp_vals] = process_tdms_data(filename, dschI, samplingFreq, lengthChunk, AhStep)
    % Lecture des données
    [v, i, t] = readTDMSData(filename);
    
    % Fréquences harmoniques fixes (58 fréquences, identiques à l'ancien projet)
    harmonicFreqs = [0;0.05;0.15;0.25;0.35;0.45;0.55;0.65;0.75;0.95;1.05;1.15;1.25;1.35;1.55;1.65;1.75;1.95;2.05;2.25;2.35;2.55;2.65;2.85;3.05;3.15;3.35;3.55;3.75;3.95;4.15;4.45;4.65;4.95;5.15;5.45;5.75;6.15;6.45;6.85;7.25;7.65;8.15;8.55;9.15;9.65;10.35;10.95;11.65;12.45;13.25;14.15;15.15;16.25;17.35;18.65;20.05;21.55]; 
    
    % Calcul de l'impédance par segments
    [Z_all, Ah_mes, T_mean_all] = Impedance(v, i, t, harmonicFreqs, samplingFreq, AhStep, dschI, lengthChunk);
    
    % Identification des paramètres Warburg
    Z_parameter = identification(harmonicFreqs, Z_all, Ah_mes);
    
    % On extrait le paramètre Zp (généralement le ratio a1/b1, soit la colonne 2 dans l'ancien code)
    Zp_vals = Z_parameter(:, 2); 
    
    % Vecteur des Ah correspondants (Ah réels par chunk avec pas AhStep)
    Ah_vals = (0:length(Zp_vals)-1)' * AhStep;
    T_vals = T_mean_all;
end