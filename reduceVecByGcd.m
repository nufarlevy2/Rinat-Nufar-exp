function reduced_vec = reduceVecByGcd(vec)
	gcd_res= vec(1);
    for lmnt_i= 2:numel(vec)
        gcd_res= gcd(gcd_res, vec(lmnt_i));
    end
       
    reduced_vec = vec / gcd_res;    
end

