function box = rotateBoundingBoxAroundPivot(box, pivot, degress)
    rads = deg2rad(degress);
    box_center = mean([box([1,2]); box([3,4])]);
    box_homogenized = [[box([1,2]), 1.0]', [box([3,4]), 1.0]'];   
    pivot_to_box_center_vec = box_center - pivot;
    translate_to_origin_mat = genTranslateMat(-box_center(1), -box_center(2));                               
    rotate_round_center_mat = genRotMat(-rads);    
    translate_by_vec_from_pivot_mat = genTranslateMat(pivot_to_box_center_vec(1), pivot_to_box_center_vec(2));                                   
    rotate_to_target_mat = genRotMat(rads);    
    undo_translate_to_origin_mat =  genTranslateMat(box_center(1) - pivot_to_box_center_vec(1), box_center(2) - pivot_to_box_center_vec(2));       
    box_homoginized_transformed = undo_translate_to_origin_mat * rotate_to_target_mat * translate_by_vec_from_pivot_mat * rotate_round_center_mat * translate_to_origin_mat * box_homogenized;
    box = [box_homoginized_transformed([1,2], 1)', box_homoginized_transformed([1,2], 2)'];
    
    function mat = genTranslateMat(x,y)
        mat = [1.0, 0.0, x;
               0.0, 1.0, y;
               0.0, 0.0, 1.0];
    end

    function mat = genRotMat(rads)
        mat = [cos(rads), -sin(rads), 0.0;
               sin(rads), cos(rads),  0.0;
               0.0,       0.0,        1.0];
    end
end

