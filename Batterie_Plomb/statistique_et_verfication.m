function statistique_et_verfication(best_model, all_Ah, all_I, all_T, all_Zp, ~)
% STATISTIQUE_ET_VERFICATION  Validation du modele polynomial Zp(Ah,I,T)
%
% Verifie 4 criteres :
%   1. R2 >= 0.95
%   2. RMSE% <= 5%
%   3. Zp predit > 0 partout
%   4. Zp predit dans la plage physique [0.001, 2] Ohm
%
% Appel depuis main.m :
%   statistique_et_verfication(best_model, all_Ah, all_I, all_T, all_Zp, courants);

    fprintf('\n========================================\n');
    fprintf('   VALIDATION DU MODELE Zp(Ah, I, T)   \n');
    fprintf('========================================\n\n');

    indepvar  = [all_Ah, all_I, all_T];
    Zp_pred   = polyvaln(best_model, indepvar);
    residuals = all_Zp - Zp_pred;

    % ================================================
    % 1. QUALITE DU FIT GLOBAL
    % ================================================
    fprintf('--- 1. QUALITE DU FIT GLOBAL ---\n');

    SS_res   = sum(residuals.^2);
    SS_tot   = sum((all_Zp - mean(all_Zp)).^2);
    R2       = 1 - SS_res / SS_tot;
    RMSE     = sqrt(mean(residuals.^2));
    RMSE_pct = RMSE / mean(all_Zp) * 100;
    MAE      = mean(abs(residuals));

    fprintf('  R2        : %.6f   %s\n', R2,       ok(R2       >= 0.95, 'R2>=0.95'));
    fprintf('  RMSE      : %.6f Ohm\n',  RMSE);
    fprintf('  RMSE (%%)  : %.2f%%   %s\n', RMSE_pct, ok(RMSE_pct <= 5,   'RMSE%%<=5%%'));
    fprintf('  MAE       : %.6f Ohm\n',  MAE);
    fprintf('  Zp mesure : [%.5f, %.5f] Ohm\n',   min(all_Zp),  max(all_Zp));
    fprintf('  Zp predit : [%.5f, %.5f] Ohm\n\n', min(Zp_pred), max(Zp_pred));

    % Test normalite residus (Kolmogorov-Smirnov)
    [h_ks, p_ks] = kstest((residuals - mean(residuals)) / std(residuals));
    if h_ks == 0
        fprintf('  Residus gaussiens (KS p=%.4f) : OK\n\n', p_ks);
    else
        fprintf('  Residus NON gaussiens (KS p=%.4f) : verifier\n\n', p_ks);
    end

    % ================================================
    % 2. COHERENCE PHYSIQUE
    % ================================================
    fprintf('--- 2. COHERENCE PHYSIQUE ---\n');

    Zp_min_phy = 0.001;
    Zp_max_phy = 2.0;
    hors_plage  = sum(Zp_pred < Zp_min_phy | Zp_pred > Zp_max_phy);
    nb_negatifs = sum(Zp_pred <= 0);

    fprintf('  Hors plage [%.3f, %.1f] Ohm : %d / %d   %s\n', ...
        Zp_min_phy, Zp_max_phy, hors_plage, length(Zp_pred), ...
        ok(hors_plage == 0, 'Toutes dans la plage'));
    fprintf('  Valeurs negatives ou nulles  : %d   %s\n\n', ...
        nb_negatifs, ok(nb_negatifs == 0, 'Zp>0 partout'));

    % ================================================
    % VERDICT FINAL
    % ================================================
    fprintf('========================================\n');
    fprintf('   VERDICT FINAL\n');
    fprintf('========================================\n');

    criteres = [R2 >= 0.95, RMSE_pct <= 5, nb_negatifs == 0, hors_plage == 0];
    labels   = {'R2>=0.95', 'RMSE%<=5%', 'Zp>0', 'Plage physique'};
    score    = sum(criteres);
    total    = length(criteres);

    for j = 1:total
        if criteres(j)
            fprintf('  [OK]  %s\n', labels{j});
        else
            fprintf('  [NON] %s\n', labels{j});
        end
    end

    fprintf('\n  Score : %d / %d criteres valides\n\n', score, total);
    if score == total
        fprintf('  [VALIDE]      MODELE VALIDE - Les resultats sont fiables.\n');
    elseif score >= ceil(total * 0.75)
        fprintf('  [ACCEPTABLE]  MODELE ACCEPTABLE - Verifier les criteres non valides.\n');
    else
        fprintf('  [INSUFFISANT] MODELE INSUFFISANT - Reviser l''''identification ou les donnees.\n');
    end
    fprintf('========================================\n\n');
end


% --- Fonction utilitaire locale ---
function s = ok(condition, label)
    if condition, s = ['[OK]  ' label];
    else,         s = ['[NON] ' label];
    end
end
