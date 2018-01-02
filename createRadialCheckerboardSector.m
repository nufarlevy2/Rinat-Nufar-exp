function img = createRadialCheckerboardSector(central_ang, min_radius, max_radius, sub_sectors_nr, circles_nr)
    diameter = 2*max_radius + 1;
    if (central_ang <= 0)
        img = zeros(diameter, diameter, 4);
        return;
    end
    
    central_ang = mod(central_ang - 1, 360)+1;    
    img = zeros(diameter, diameter, 4);
    img_center = [max_radius, max_radius];
    
    sub_sector_theta = central_ang/sub_sectors_nr;
    circles_radii_diff = (max_radius - min_radius)/circles_nr;
    
    for x = 1:diameter
        for y = 1:diameter            
           xy_dist_from_center = sqrt((x - img_center(1))^2 + (y - img_center(2))^2);
           xy_theta = rad2deg(atan2(y - img_center(2),x - img_center(1)));
           if (xy_theta < central_ang/2 && xy_theta >= -central_ang/2 || central_ang == 360) && ... 
               xy_dist_from_center > min_radius && xy_dist_from_center < max_radius
               img(y,x,1:3) = xor( mod(floor((xy_dist_from_center - min_radius)/circles_radii_diff), 2), ...
                                  mod(floor((xy_theta + central_ang/2)/sub_sector_theta), 2) );       
               img(y,x,4) = 1;           
           end
        end
    end    
end

