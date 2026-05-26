function [voltage, current, temperature] = readTDMSData(filename)
    % Lit un fichier TDMS et retourne Tension (CH0), Courant (CH1) et Température (CH2)
    try
        tdms_data = TDMS_getStruct(filename);
    catch ME
        error('Erreur lors de la lecture du fichier TDMS: %s', ME.message);
    end
    
    if isfield(tdms_data, 'Untitled')
        group = tdms_data.Untitled;
        if isfield(group, 'Ch0') && isfield(group, 'Ch1') && isfield(group, 'Ch2')
            voltage = group.Ch0.data(:);
            current = group.Ch1.data(:);
            temperature = group.Ch2.data(:);
            fprintf('✓ CH0(V), CH1(I), CH2(T) chargés avec succès.\n');
            return;
        end
    end
    error('Canaux Ch0, Ch1, ou Ch2 introuvables dans le fichier TDMS.');
end