function Z_parameter = identification(harmonicFreqs, Z_all, Ah_mes)

    global imp w

    totalChunks = size(Z_all, 1);
    w = 2 * pi * harmonicFreqs; 
    Z_parameter = zeros(totalChunks, 3);
    
    % Fichier temporaire pour fdident
    dat_filename = fullfile(pwd, 'dat_temp.fbn');
    if isfile(dat_filename)
        try
            delete(dat_filename);
            fprintf('✓ Ancien fichier supprimé: %s\n', dat_filename);
        catch
            fprintf('⚠ Impossible de supprimer: %s\n', dat_filename);
        end
    end

    % Impédance moyenne sur tous les segments
    imp = mean(Z_all, 1);

    % Concaténer toutes les données pour expfou (57 freq x totalChunks)
    Z_concat = Z_all.';      % 57 x totalChunks
    Z_concat = Z_concat(:);  % vecteur colonne (57*totalChunks x 1)
    Inp = ones(length(Z_concat), 1);
    Fdat = expfou(harmonicFreqs, Inp, Z_concat, [1:totalChunks], totalChunks, dat_filename);
    [vx, vy, cxy] = varanal(Fdat);

    % === FIGURE 1 : Spectres d'impédance + overlay modèle (semilogx, dB) ===
    figure;
    for i = 1:totalChunks
        semilogx(harmonicFreqs, 20 * log10(abs(Z_all(i, :))), '*');
        hold on;

        fd = fiddata(Z_all(i,:)', ones(length(harmonicFreqs),1), harmonicFreqs, vy, vx, cxy, '', '', '');   
        
        % Identification dans le domaine sqrt(s)
        figure(2);
        fct = elis(fd, 'w', 2, 2);
        close(figure(2));

        % Superposition modèle identifié vs mesure
        fonction = ((fct.num(1)*((w*1i)) + (fct.num(2)*sqrt(w*1i) + (fct.num(3))))) ./ ...
                   (((fct.den(1)*((w*1i)) + fct.den(2)*sqrt(w*1i) + fct.den(3))));
        semilogx(harmonicFreqs, 20*log10(abs(fonction)));

        % Extraction des paramètres (a1/b1, etc.)
        Z_parameter(i,:) = abs(fct.num ./ fct.den);
    end

    title('Identification de l''impédance');
    xlabel('Fréquence (Hz)');
    ylabel('Impédance (dB)');
    grid on;
    axis([0 21.55 -35 5]);

    % === FIGURE 2 : Évolution du paramètre Zp en fonction des Ah ===
    Ah_max = Ah_mes;
    Ah = linspace(0, Ah_mes, totalChunks);

    figure(3);
    plot(Ah, Z_parameter(:,2), '*-', 'LineWidth', 1.5, 'Color', 'g');
    xlabel('Ampère-heures (Ah)');
    ylabel('Paramètre d''impédance');
    title('Paramètres d''impédance en fonction des Ah');
    grid on;
    xlim([0 Ah_max]);
    set(gca, 'XTick', linspace(0, max(Ah_max), 6));

    % === FIGURE 3 : INFORMATIONS COMPLÉMENTAIRES ===
    figure('Name', 'INFORMATIONS COMPLÉMENTAIRES - Analyse et Statistiques', ...
           'NumberTitle', 'off', 'Position', [650 400 1000 600]);

    % Subplot 1 : Impédance moyenne ± écart-type par fréquence
    subplot(1, 2, 1);
    Z_mean_freq = mean(abs(Z_all), 1);
    Z_std_freq = std(abs(Z_all), 0, 1);
    errorbar(harmonicFreqs, Z_mean_freq, Z_std_freq, 'bo-', 'LineWidth', 1.5, 'MarkerSize', 4);
    set(gca, 'XScale', 'log');
    xlabel('Fréquence (Hz)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Impédance (Ω)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Impédance moyenne ± écart-type par fréquence', 'FontSize', 12, 'FontWeight', 'bold');
    grid on;

    % Subplot 2 : Évolution des 3 paramètres Z0, Z1, Z2
    subplot(1, 2, 2);
    Ah_vals = linspace(0, Ah_mes, totalChunks);
    hold on;
    plot(Ah_vals, Z_parameter(:,1), 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4, 'DisplayName', 'Z₀');
    plot(Ah_vals, Z_parameter(:,2), 'g-s', 'LineWidth', 1.5, 'MarkerSize', 4, 'DisplayName', 'Z₁');
    plot(Ah_vals, Z_parameter(:,3), 'r-^', 'LineWidth', 1.5, 'MarkerSize', 4, 'DisplayName', 'Z₂');
    xlabel('Capacité (Ah)', 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Paramètres', 'FontSize', 11, 'FontWeight', 'bold');
    title('Évolution des 3 paramètres d''impédance', 'FontSize', 12, 'FontWeight', 'bold');
    legend('show', 'FontSize', 10);
    grid on;
    xlim([0 Ah_max]);

    fprintf('✓ Graphiques d''identification affichés\n');
end