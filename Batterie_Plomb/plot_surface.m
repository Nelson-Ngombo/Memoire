function plot_surface(best_model, all_Ah, all_I, fixed_T)
    % Trace Zp = f(Ah, I) pour une température T fixée
    Ah_range = linspace(min(all_Ah), max(all_Ah), 50);
    I_range = linspace(min(all_I), max(all_I), 50);
    [Ah_grid, I_grid] = meshgrid(Ah_range, I_range);
    
    % On maintient T constant pour la visualisation 3D
    T_grid = repmat(fixed_T, size(Ah_grid));
    
    Z_grid = polyvaln(best_model, [Ah_grid(:), I_grid(:), T_grid(:)]);
    Z_grid = reshape(Z_grid, size(Ah_grid));
    
    figure;
    surf(Ah_grid, I_grid, Z_grid);
    xlabel('Ampères-heures (Ah)');
    ylabel('Courant (I) [A]');
    zlabel('Paramètre d''impédance (Zp)');
    title(sprintf('Surface Zp(Ah, I) à T = %.1f °C', fixed_T));
    grid on;
end