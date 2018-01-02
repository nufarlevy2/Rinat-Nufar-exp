function [is_key_down, secs, key_codes] = KbCheckResponseBox(read_byte_func)
    NONE= 120; %01111000
    % UPPER_RIGHT_FLIPPER= 16 (flip bit 5). key code by itself= 104
    % LOWER_RIGHT_FLIPPER= 32 (flip bit 6). key code by itself= 88 
    % UPPER_LEFT_FLIPPER= 64 (flip bit 7). key code by itself= 56
    % LOWER_LEFT_FLIPPER= 128 (flip bit 8). key code by itself= 248
    KEY_CODES= [64, 128, 32, 16];
                
    key_code= read_byte_func;    
    secs= GetSecs();
    flipped_bits_code= bitxor(key_code, NONE);
    is_key_down= flipped_bits_code;    
        
    key_codes= zeros(1,numel(KEY_CODES));    
    if (is_key_down)
        for i= 1:numel(KEY_CODES)
            key_codes(i)= any(bitand(flipped_bits_code, KEY_CODES(i)));
        end        
    end
end

