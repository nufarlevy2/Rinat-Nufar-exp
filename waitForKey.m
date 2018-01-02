function key_press_vbl = waitForKey(key_to_wait_for)
%% key_press_vbl= waitForKey(key_to_wait_for)
% wait for a specific key press.
%
% input:
%   key_to_wait_for: the keycode of the key to wait for.
%
% output:
%   key_press_vbl: the time of the key press

    is_key_pressed = true;
    while (is_key_pressed)
        [~, ~, pressed_keys_arr]= KbCheck;
        is_key_pressed = ismember(key_to_wait_for, find(pressed_keys_arr));        
    end
    
    while (~is_key_pressed)
        [~, key_press_vbl, pressed_keys_arr]= KbCheck;                    
        is_key_pressed = ismember(key_to_wait_for, find(pressed_keys_arr));
    end
end

