function best_model = fit_and_validate_polynomial(all_Ah, all_I, all_T, all_Z)
    best_model = [];
    best_rmse = inf;
    
    % La matrice indépendante a maintenant 3 colonnes : [Ah, I, T]
    indepvar = [all_Ah, all_I, all_T];
    
    for poly_order = 1:3
        model = polyfitn(indepvar, all_Z, poly_order);
        predicted_Z = polyvaln(model, indepvar);
        rmse = sqrt(mean((predicted_Z - all_Z).^2));
        
        fprintf('Ordre %d | RMSE : %.6f\n', poly_order, rmse);
        
        if rmse < best_rmse
            best_model = model;
            best_rmse = rmse;
        end
    end 
end