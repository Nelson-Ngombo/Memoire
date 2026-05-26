%% ========================================================================
% ANALYSE FFT DES FICHIERS TDMS (CH0, CH1, CH2)
% ========================================================================
% Script pour charger un fichier TDMS, calculer et afficher la FFT
% avec des points (plot) au lieu de barres verticales (bar)
% ========================================================================

clc; clear; close all;

% ======================
% INITIALISATION DES CHEMINS
% ======================

% Nettoyer le path
restoredefaultpath;

% Chemin vers TDMS_Reader
tdms_reader_main = 'C:\Users\Nelson\Documents\battery\Nelson\Code_Matlab\TDMS_Reader\v2p6';
tdms_reader_sub = fullfile(tdms_reader_main, 'tdmsSubfunctions');

if ~isfolder(tdms_reader_main)
    error('❌ TDMS_Reader introuvable!\nChemin attendu: %s', tdms_reader_main);
end

addpath(tdms_reader_main);
addpath(tdms_reader_sub);
fprintf('✓ TDMS_Reader ajouté au path\n');

% ======================
% SELECTION ET CHARGEMENT DU FICHIER
% ======================

% Demander l'utilisateur de sélectionner le fichier TDMS
fprintf('\n📁 Sélectionnez un fichier TDMS...\n');
[filename, pathname] = uigetfile('*.tdms', 'Choisir un fichier TDMS');

if isequal(filename, 0)
    fprintf('❌ Aucun fichier sélectionné\n');
    return;
end

filepath = fullfile(pathname, filename);
fprintf('✓ Fichier sélectionné: %s\n\n', filename);

% Charger le fichier TDMS
try
    tdms_data = TDMS_getStruct(filepath);
    fprintf('✓ Fichier TDMS chargé avec succès\n');
catch ME
    error('❌ Erreur lors du chargement TDMS:\n%s', ME.message);
end

% ======================
% EXTRACTION DES DONNEES (CH0, CH1, CH2)
% ======================

% Chercher la structure Untitled (groupe par défaut dans ces fichiers)
if isfield(tdms_data, 'Untitled')
    data_group = tdms_data.Untitled;
elseif isfield(tdms_data, 'Group')
    data_group = tdms_data.Group;
else
    % Prendre le premier groupe disponible
    group_names = fieldnames(tdms_data);
    data_group = tdms_data.(group_names{1});
end

% Initialiser les canaux
ch0 = []; ch1 = []; ch2 = [];

% Essayer de charger CH0, CH1, CH2
try
    if isfield(data_group, 'Ch0')
        ch0 = data_group.Ch0.data;
    end
    if isfield(data_group, 'Ch1')
        ch1 = data_group.Ch1.data;
    end
    if isfield(data_group, 'Ch2')
        ch2 = data_group.Ch2.data;
    end
catch
    error('❌ Erreur: Impossible de trouver CH0, CH1 ou CH2');
end

fprintf('✓ Données extraites:\n');
fprintf('  - CH0 (Tension):    %d points\n', length(ch0));
fprintf('  - CH1 (Courant):    %d points\n', length(ch1));
fprintf('  - CH2 (Température): %d points\n\n', length(ch2));

% Vérifier que les données existent
if isempty(ch0) || isempty(ch1) || isempty(ch2)
    error('❌ Impossible de charger les 3 canaux');
end

% S'assurer que les données sont des vecteurs colonne
ch0 = ch0(:);
ch1 = ch1(:);
ch2 = ch2(:);

% ======================
% PARAMETRES FFT
% ======================

fs = 100; % Fréquence d'échantillonnage (Hz)
N = length(ch0); % Nombre de points
freq = (0:N-1) * fs / N; % Vecteur de fréquence

% Calculer la FFT
FFT_ch0 = abs(fft(ch0)) / N; % Normalisation
FFT_ch1 = abs(fft(ch1)) / N;
FFT_ch2 = abs(fft(ch2)) / N;

% Garder seulement la moitié positive du spectre (symétrie)
freq_half = freq(1:floor(N/2));
FFT_ch0_half = FFT_ch0(1:floor(N/2));
FFT_ch1_half = FFT_ch1(1:floor(N/2));
FFT_ch2_half = FFT_ch2(1:floor(N/2));

fprintf('✓ FFT calculée\n');
fprintf('  - Nombre de points: %d\n', N);
fprintf('  - Fréquence max: %.2f Hz\n\n', freq_half(end));

% ======================
% CONVERSION EN dB ET AFFICHAGE DES GRAPHIQUES
% ======================

% Convertir en dB (20 * log10 pour l'amplitude)
% Ajouter un petit offset pour éviter log(0)
min_level = 1e-6;
FFT_ch0_dB = 20 * log10(FFT_ch0_half + min_level);
FFT_ch1_dB = 20 * log10(FFT_ch1_half + min_level);
FFT_ch2_dB = 20 * log10(FFT_ch2_half + min_level);

fig = figure('Name', sprintf('FFT - %s', filename), ...
             'NumberTitle', 'off', ...
             'Position', [100, 100, 1400, 900]);

% === Subplot 1: CH0 (Tension) ===
subplot(3, 1, 1);
plot(freq_half, FFT_ch0_dB, 'b.', 'MarkerSize', 4);
grid on;
xlabel('Fréquence (Hz)');
ylabel('Gain (dB)');
title('FFT - CH0 (Tension)');
xlim([0 max(freq_half)]);
ylim([-120 40]);

% === Subplot 2: CH1 (Courant) ===
subplot(3, 1, 2);
plot(freq_half, FFT_ch1_dB, 'r.', 'MarkerSize', 4);
grid on;
xlabel('Fréquence (Hz)');
ylabel('Gain (dB)');
title('FFT - CH1 (Courant)');
xlim([0 max(freq_half)]);
ylim([-120 40]);

% === Subplot 3: CH2 (Température) ===
subplot(3, 1, 3);
plot(freq_half, FFT_ch2_dB, 'g.', 'MarkerSize', 4);
grid on;
xlabel('Fréquence (Hz)');
ylabel('Gain (dB)');
title('FFT - CH2 (Température)');
xlim([0 max(freq_half)]);
ylim([-120 40]);

% Ajouter un titre global
sgtitle(sprintf('Analyse FFT - %s', filename), 'FontSize', 14, 'FontWeight', 'bold');

fprintf('✓ Graphiques affichés en dB (échelle: -120 à +40 dB)\n\n');

% ======================
% STATISTIQUES UTILES (EN dB)
% ======================

fprintf('📊 STATISTIQUES FFT (Gain en dB):\n');
fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

% Pour CH0
[max_gain_ch0, idx_ch0] = max(FFT_ch0_dB);
fprintf('CH0 (Tension):\n');
fprintf('  - Gain max: %.2f dB\n', max_gain_ch0);
fprintf('  - Fréquence dominante: %.2f Hz\n\n', freq_half(idx_ch0));

% Pour CH1
[max_gain_ch1, idx_ch1] = max(FFT_ch1_dB);
fprintf('CH1 (Courant):\n');
fprintf('  - Gain max: %.2f dB\n', max_gain_ch1);
fprintf('  - Fréquence dominante: %.2f Hz\n\n', freq_half(idx_ch1));

% Pour CH2
[max_gain_ch2, idx_ch2] = max(FFT_ch2_dB);
fprintf('CH2 (Température):\n');
fprintf('  - Gain max: %.2f dB\n', max_gain_ch2);
fprintf('  - Fréquence dominante: %.2f Hz\n');

fprintf('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n');

fprintf('✅ Analyse FFT terminée!\n');
