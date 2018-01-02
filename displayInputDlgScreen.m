function final_input = displayInputDlgScreen(window, window_sz, instruction_txt, txt_color)    
    CURSOR_CHAR = '_';
    KEY_COOLDOWN_DUR = 0.15;
    
    window_center = round(0.5 * window_sz);
    [instruction_txt_bounds,~]= Screen('TextBounds', window, instruction_txt, window_center(1), window_center(2));
    input_vert_offset = 0.5*instruction_txt_bounds(4);    
   
    DrawFormattedText(window, instruction_txt, 'center', 'center', txt_color, [], [], [], 2);
    [cursor_txt_bounds,~]= Screen('TextBounds', window, double(CURSOR_CHAR));
    input_txt_y_pos = window_center(2) + 0.5*instruction_txt_bounds(4) + input_vert_offset + 0.5*cursor_txt_bounds(4);        
    exp_text_style = Screen('TextStyle', window, 1);
    DrawFormattedText(window, CURSOR_CHAR, window_center(1) - 0.5*cursor_txt_bounds(3), input_txt_y_pos, txt_color, [], [], [], 2);
    Screen('TextStyle', window, exp_text_style);
    Screen('Flip', window);
    final_input = [];
    cooldowns_vec = zeros(1,256);
    key_codes_on_cooldown = [];
    
    %wait until no key is down
    is_key_down = true;
    while (is_key_down)
        [is_key_down, ~, ~, ~] = KbCheck(); 
    end
    
    while(1)                     
        [is_key_down, ~, pressed_key_codes_vec, time_delta] = KbCheck(); 
        resumed_key_codes_on_cooldown_logical_vec = pressed_key_codes_vec(key_codes_on_cooldown) == 0;        
        cooldowns_vec(key_codes_on_cooldown(resumed_key_codes_on_cooldown_logical_vec)) = 0;
        key_codes_on_cooldown(resumed_key_codes_on_cooldown_logical_vec) = []; %#ok<AGROW>
        cooldowns_vec(key_codes_on_cooldown) = max(cooldowns_vec(key_codes_on_cooldown) - time_delta, 0);
        key_codes_on_cooldown(cooldowns_vec(key_codes_on_cooldown)==0) = []; %#ok<AGROW>
        if is_key_down
            pressed_key_codes = find(pressed_key_codes_vec); 
            if any(pressed_key_codes == 13) % 13 == 'ENTER'
                break; 
            else
                ready_activated_keys_logical_vec = cooldowns_vec(pressed_key_codes)==0;
                ready_activated_key_codes = pressed_key_codes(ready_activated_keys_logical_vec);
                key_codes_on_cooldown = [key_codes_on_cooldown, ready_activated_key_codes]; %#ok<AGROW>
                cooldowns_vec(ready_activated_key_codes) = KEY_COOLDOWN_DUR;
                if any(ready_activated_key_codes == 8) % 8 == 'BACKSPACE'
                    if ~isempty(final_input)                
                        final_input(end) = [];
                    end
                else
                    final_input = [final_input, asciiToUnicodeHebrew(ready_activated_key_codes)]; %#ok<AGROW>
                end                                                            
            end
            
            DrawFormattedText(window, instruction_txt, 'center', 'center', txt_color, [], [], [], 2);
            [final_input_plus_cursor_txt_bounds,~]= Screen('TextBounds', window, [double(CURSOR_CHAR), final_input]);
            input_txt_y_pos = window_center(2) + 0.5*instruction_txt_bounds(4) + input_vert_offset + 0.5*final_input_plus_cursor_txt_bounds(4);
            if ~isempty(final_input)
                DrawFormattedText(window, final_input, window_center(1)-0.5*final_input_plus_cursor_txt_bounds(3), input_txt_y_pos, txt_color, [], [], [], 2);
                [final_input_txt_bounds,~]= Screen('TextBounds', window, final_input);
            else
                final_input_txt_bounds = [0 0 0 0];
            end
            
            exp_text_style = Screen('TextStyle', window, 1);
            DrawFormattedText(window, CURSOR_CHAR, window_center(1) - 0.5*final_input_plus_cursor_txt_bounds(3) - cursor_txt_bounds(3), input_txt_y_pos, txt_color, [], [], [], 2);
            Screen('TextStyle', window, exp_text_style);
            Screen('Flip', window);
        end        
    end
end

