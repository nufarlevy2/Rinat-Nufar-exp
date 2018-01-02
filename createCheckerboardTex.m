function checkerboard_tex = createCheckerboardTex(window, sqrs_horizon_nr, sqrs_width, sqrs_vert_nr, sqrs_height, top_left_color_val)
    checkerboard_sz = [sqrs_horizon_nr*sqrs_width, sqrs_vert_nr*sqrs_height];
    checkerboard = zeros(checkerboard_sz(2), checkerboard_sz(1));
        
    top_row_vec_primal = 0:checkerboard_sz(1)-1;    
    top_row_vec = xor(floor(mod(top_row_vec_primal, sqrs_width*2)/sqrs_width),top_left_color_val);        
    left_col_vec_primal = 0:checkerboard_sz(2)-1;        
    left_col_vec = xor(floor(mod(left_col_vec_primal, sqrs_height*2)/sqrs_height),1);
        
    for row_pix_i = 1:checkerboard_sz(2)
        for col_pix_i = 1:checkerboard_sz(1)
            checkerboard(row_pix_i,col_pix_i) = not(xor(top_row_vec(col_pix_i),left_col_vec(row_pix_i)));
        end
    end
    
    checkerboard_tex= Screen('MakeTexture', window, checkerboard);
end

