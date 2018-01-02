function perms_mat= randomizedFactorial(lines_nr, ranges_vec)      
    perms_nr= prod(ranges_vec);
    randomization_vec= randperm(lines_nr);
    perms_mat_reps_nr= [floor(lines_nr/perms_nr), mod(lines_nr, perms_nr)];    
    if perms_mat_reps_nr(2)>0
        extra_draws_mat= zeros(perms_mat_reps_nr(2),numel(ranges_vec));
        for range_i= 1:numel(ranges_vec)
            extra_draws_mat(:,range_i)= randi(ranges_vec(range_i),perms_mat_reps_nr(2),1);            
        end
        extra_draws_mat(:,range_i+1)= 0;
    else
        extra_draws_mat= [];
    end
    
    if (perms_mat_reps_nr(1)>0)
        perms_mat= [fullfact([ranges_vec, perms_mat_reps_nr(1)]); extra_draws_mat];       
        perms_mat= perms_mat(randomization_vec, 1:end-1);
    else
        perms_mat= fullfact(ranges_vec);        
        perms_mat= perms_mat(randomization_vec, :);     
    end        
end