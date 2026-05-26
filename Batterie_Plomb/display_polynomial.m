function poly_string = display_polynomial(model)
    coeffs = model.Coefficients;
    terms = model.ModelTerms;
    
    % Utiliser les noms de variables du modèle si disponibles, sinon défaut
    if isfield(model, 'VarNames') && ~isempty(model.VarNames)
        var_names = model.VarNames;
    else
        var_names = {'Ah', 'I', 'T'};
    end 
    
    poly_terms = strings(size(coeffs));
    for i = 1:length(coeffs)
        term_parts = strings(1, length(var_names));
        for j = 1:length(var_names)
            if terms(i, j) > 0
                term_parts(j) = sprintf('%s^%d', var_names{j}, terms(i, j));
            end
        end
        term_string = strjoin(term_parts(term_parts ~= ""), ' * ');
        if coeffs(i) ~= 0
            if term_string == ""
                poly_terms(i) = sprintf('%.6f', coeffs(i));
            else
                poly_terms(i) = sprintf('%.6f * %s', coeffs(i), term_string);
            end
        end
    end
    poly_terms = poly_terms(poly_terms ~= "");
    poly_string = strjoin(poly_terms, ' + ');
end 