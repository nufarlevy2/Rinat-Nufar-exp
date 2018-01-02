function smudged_vec= smudgeVec(vec, smudgings_vec)
   if numel(smudgings_vec)<numel(vec)
       smudgings_vec= [smudgings_vec, smudgings_vec(end)*ones(1, numel(vec)-numel(smudgings_vec))];
   end   
   smudgings_vec(smudgings_vec<1)= 1;
   
   smudged_vec= zeros(1,sum(smudgings_vec));
   smudged_vec_i= 1;
   for lmnt_in_vec_i= 1:numel(vec)
       for smudge_i= 1:smudgings_vec(lmnt_in_vec_i)
           smudged_vec(smudged_vec_i)= vec(lmnt_in_vec_i);
           smudged_vec_i= smudged_vec_i + 1;
       end
   end
end