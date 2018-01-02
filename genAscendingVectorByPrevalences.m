function ascending_vector = genAscendingVectorByPrevalences( prevalences )
    ascending_vector= zeros(1,sum(prevalences));
    ascending_vec_overall_i= 1;
    for val_i= 1:numel(prevalences)
        ascending_vector(ascending_vec_overall_i:prevalences(val_i)+ascending_vec_overall_i-1)= val_i;
        ascending_vec_overall_i= ascending_vec_overall_i+prevalences(val_i);
    end
end

