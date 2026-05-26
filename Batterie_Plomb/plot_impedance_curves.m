function plot_impedance_curves(all_Ah, all_I, all_Z, courants, Ah_max)
    figure;
    hold on;
    colors = lines(length(courants));
    
    for k = 1:length(courants)
        idx = (all_I == courants(k));
        plot(all_Ah(idx), all_Z(idx), '*-', 'LineWidth', 1.5, ...
             'Color', colors(k,:), 'DisplayName', sprintf('I = %.1f A', courants(k)));
    end
    
    xlabel('Ampères-heures (Ah)');
    ylabel('Paramètre d''Impédance (Zp)');
    title('Évolution de Zp en fonction de Ah et I');
    legend('show');
    grid on;
    xlim([0 Ah_max]);
end 