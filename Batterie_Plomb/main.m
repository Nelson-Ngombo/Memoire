% Script principal pour l'identification Zp(Ah, I, T)
clc; clear; close all;

% ======================
% NETTOYAGE ET INITIALISATION DES CHEMINS
% ======================
 
% Nettoyer le path des entrées doublons
restoredefaultpath;

% Chemin vers fdident-toolbox (le bon dossier racine)
fdident_main = 'C:\Users\Nelson\Documents\battery\Nelson\Code_Matlab\fdident-toolbox';

% Vérifier que le dossier existe
if ~isfolder(fdident_main)
    error('❌ fdident-toolbox introuvable!\nChemin attendu: %s', fdident_main);
end

% Ajouter SEULEMENT les chemins corrects (pas les doublons)
addpath(fullfile(fdident_main, 'fdident'));
addpath(fullfile(fdident_main, 'fddemos'));
addpath(fdident_main);
fprintf('✓ fdident-toolbox ajouté au path\n');

% Chemin vers PolyfitnTools
polyfitn_main = 'C:\Users\Nelson\Documents\battery\Nelson\Code_Matlab\PolyfitnTools\PolyfitnTools';

if ~isfolder(polyfitn_main)
    error('❌ PolyfitnTools introuvable!\nChemin attendu: %s', polyfitn_main);
end

addpath(polyfitn_main);
fprintf('✓ PolyfitnTools ajouté au path\n');

% Chemin vers TDMS_Reader (outil pour lire les fichiers .tdms)
tdms_reader_main = 'C:\Users\Nelson\Documents\battery\Nelson\Code_Matlab\TDMS_Reader\v2p6';
tdms_reader_sub = fullfile(tdms_reader_main, 'tdmsSubfunctions');

% Vérifier que le dossier existe
if ~isfolder(tdms_reader_main)
    error('❌ TDMS_Reader introuvable!\nChemin attendu: %s', tdms_reader_main);
end

% Ajouter les dossiers au chemin MATLAB
addpath(tdms_reader_main);
addpath(tdms_reader_sub);
fprintf('✓ TDMS_Reader ajouté au path\n\n');

% ======================
% PARAMÈTRES GÉNÉRAUX
% ======================
samplingFreq = 100; % Hz
lengthChunk = 4000; % points
AhStep = 1; % Pas 
Ah_nominal = 22; % Capacité de la batterie

% Fichiers et courants associés
fichiers = {'3A_17_04_2026_multisinus.tdms', '4A_04_05_2026_multisinus.tdms', '5A_16_04_2026.tdms', '6A_28_04_2026_multisinus.tdms'};
courants = [3, 4, 5, 6];

% Initialisation des matrices globales pour le fitting
all_Ah = [];
all_I = [];
all_T = [];
all_Zp = [];

% Traitement de chaque fichier
for k = 1:length(fichiers)
    fprintf('Traitement du fichier %s (I = %d A)...\n', fichiers{k}, courants(k));
    
    % Extraction et identification
    [Ah_vals, T_vals, Zp_vals] = process_tdms_data(fichiers{k}, courants(k), samplingFreq, lengthChunk, AhStep);
    
    % Concaténation pour le modèle global
    all_Ah = [all_Ah; Ah_vals];
    all_I = [all_I; repmat(courants(k), length(Ah_vals), 1)];
    all_T = [all_T; T_vals];
    all_Zp = [all_Zp; Zp_vals];
end

% Sauvegarde des données extraites (génère pas_15.m indirectement)
save('donnees_extraites_15Ah.mat', 'all_Ah', 'all_I', 'all_T', 'all_Zp');

% Visualisation des courbes d'impédance
plot_impedance_curves(all_Ah, all_I, all_Zp, courants, Ah_nominal);

% Ajustement Polynomial 3D : Zp = f(Ah, I, T)
best_model = fit_and_validate_polynomial(all_Ah, all_I, all_T, all_Zp);

% Affichage du modèle
disp('Meilleur modèle polynomial Zp(Ah, I, T) :');
disp(display_polynomial(best_model));

% Affichage de la surface (à T moyen pour la visualisation 3D)
plot_surface(best_model, all_Ah, all_I, mean(all_T));

% Validation statistique et physique du modèle
statistique_et_verfication(best_model, all_Ah, all_I, all_T, all_Zp, courants);