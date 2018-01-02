function [perms_mat, trials_per_block_nr]= randomizedWeightedEqualizedFactorial(blocks_nr, conditions_combos_multiplier, weights_cell_arr, performWeightsReduction) 
    %normalizing weights
    normalized_weights_cell_arr= cell(1, numel(weights_cell_arr));
    perms_nr= 1;
    for weights_vec_i= 1:numel(weights_cell_arr)
        if performWeightsReduction
            normalized_weights_cell_arr{weights_vec_i}= weights_cell_arr{weights_vec_i}./iteratedGcd(weights_cell_arr{weights_vec_i});
        else
            normalized_weights_cell_arr{weights_vec_i}= weights_cell_arr{weights_vec_i};
        end
        perms_nr= perms_nr*sum(normalized_weights_cell_arr{weights_vec_i});
    end               
    
    %calculating trials numbers for each condition
    multiplied_weights_cell_arr= cell(1, numel(normalized_weights_cell_arr));
    multiplied_weights_cell_arr{1}= perms_nr/sum(normalized_weights_cell_arr{1}).*normalized_weights_cell_arr{1};
    for weights_vec_i=2:numel(normalized_weights_cell_arr)
        multiplied_weights_cell_arr{weights_vec_i}= zeros( 1,numel(normalized_weights_cell_arr{weights_vec_i-1}*numel(normalized_weights_cell_arr{weights_vec_i})) );
        curr_weights_multiplication_factors= multiplied_weights_cell_arr{weights_vec_i-1}./sum(normalized_weights_cell_arr{weights_vec_i});
        for weight_i= 1:numel(multiplied_weights_cell_arr{weights_vec_i-1})
            multiplied_weights_cell_arr{weights_vec_i}( (weight_i-1)*numel(normalized_weights_cell_arr{weights_vec_i})+1:weight_i*numel(normalized_weights_cell_arr{weights_vec_i}) )= curr_weights_multiplication_factors(weight_i)*normalized_weights_cell_arr{weights_vec_i};
        end
    end                                                       
    
    %generating permutations matrix according to the calculated number of
    %trials for each condition + duplicating it lines_multiplier times
    perms_mat= zeros(perms_nr, numel(multiplied_weights_cell_arr));
    for variable_i= 1:numel(multiplied_weights_cell_arr)
        curr_variable_vals_nr= numel(weights_cell_arr{variable_i});
        curr_multiplied_weights_vec= multiplied_weights_cell_arr{variable_i};
        overall_trial_i= 1;
        for multiplied_weight_i= 1:numel(curr_multiplied_weights_vec)                    
            for trial_i= 1:curr_multiplied_weights_vec(multiplied_weight_i)
                perms_mat(overall_trial_i,variable_i)= mod(multiplied_weight_i-1, curr_variable_vals_nr)+1;
                overall_trial_i= overall_trial_i + 1;
            end            
        end
    end
    
    perms_mat= repmat(perms_mat,conditions_combos_multiplier,1);
    trials_per_block_nr= size(perms_mat,1);
    perms_mat= repmat(perms_mat,blocks_nr,1);
    %shuffling permutations matrix
    for block_i= 1:blocks_nr
        curr_shuffled_trials_is= (block_i-1)*trials_per_block_nr+1:block_i*trials_per_block_nr;
        randomization_vec= curr_shuffled_trials_is(1)+randperm(trials_per_block_nr)-1;
        perms_mat(curr_shuffled_trials_is,:)= perms_mat(randomization_vec,:);
    end                         
    
    function gcd_res= iteratedGcd(numbers)
        gcd_res= numbers(1);
        for num_i= 2:numel(numbers)
            gcd_res= gcd(gcd_res,numbers(num_i)); 
        end
    end
end