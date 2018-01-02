classdef TexturedTextMaker < handle       
    properties (Access = public, Constant)
        FONT_TYPE_HEBREW_DAVID = 1;        
    end            
    
    properties (Access = private, Constant)
        ENUM_TXT_DIRECTION_RIGHT_TO_LEFT = 1;
        ENUM_TXT_DIRECTION_LEFT_TO_RIGHT = 2;        
        ARIAL_TEXES_FOLDER = fullfile('resources', 'stimuli', 'hebrew_letters_david');
        HEBREW_LETTERS_FILE = fullfile('resources', 'stimuli', 'hebrew_letters.txt');
        TEXES_FOLDERS = {TexturedTextMaker.ARIAL_TEXES_FOLDER};         
        LETTERS_FILES = {TexturedTextMaker.HEBREW_LETTERS_FILE};
        TXT_DIRECTIONS = [TexturedTextMaker.ENUM_TXT_DIRECTION_RIGHT_TO_LEFT];
    end
    
    properties (Access = public)
        window;
        imgs;
        letters_height;
        texes_color;
        letter_codes;
        txt_direction;
        letters_scale_factor;
        space_width;
    end
    
    methods (Access = public)
        function obj = TexturedTextMaker(psychtoolbox_window_pointer, font_type, letters_height, font_color)
            obj.window = psychtoolbox_window_pointer;
            obj.imgs= loadImagesFromFolder(TexturedTextMaker.TEXES_FOLDERS{font_type}, 'png');            
            obj.letters_height = letters_height;
            obj.texes_color = font_color;     
            fid = fopen(TexturedTextMaker.LETTERS_FILES{font_type});
            obj.letter_codes = native2unicode(fread(fid)', 'Unicode');   
            obj.txt_direction = TexturedTextMaker.TXT_DIRECTIONS(font_type);  
            obj.letters_scale_factor = obj.letters_height/size(obj.imgs{1},1);
            obj.space_width =  obj.letters_scale_factor*size(obj.imgs{1},2);
        end
        
        function [texture, letter_codes_pos_mat] = createTexturedTxt(obj, txt)
            txt_len = numel(txt);
            imgs_to_show_is = cell(1, txt_len);
            imgs_szs = NaN(txt_len, 2);            
            texture_img_height_acc = obj.letters_height;
            
            texture_img_width_acc = 0;
            texture_img_width_acc_max = 0;
            for char_i = 1:txt_len
                % imgs_to_show_is{char_i} == [] where the text contains no
                % alpha-bet letters. will display spaces in their place.
                imgs_to_show_is{char_i} = find(txt(char_i) == obj.letter_codes); 
                if isempty(imgs_to_show_is{char_i})
                    texture_img_width_acc = texture_img_width_acc + obj.space_width;
                    imgs_szs(char_i,:) = [first_letter_img_width, obj.letters_height]; 
                elseif imgs_to_show_is{char_i} <= numel(obj.imgs) - 2
                    texture_img_width_acc = texture_img_width_acc + obj.letters_scale_factor*size(obj.imgs{imgs_to_show_is{char_i}},2);
                    imgs_szs(char_i,:) = [obj.letters_scale_factor*size(obj.imgs{imgs_to_show_is{char_i}},2), obj.letters_height];
                elseif imgs_to_show_is{char_i} == numel(obj.imgs) - 1
                    % new line
                    texture_img_height_acc = texture_img_height_acc + obj.letters_height;
                    imgs_szs(char_i,:) = [0, 0];
                    if texture_img_width_acc > texture_img_width_acc_max
                        texture_img_width_acc_max = texture_img_width_acc;
                        texture_img_width_acc = 0;
                    end
                end
            end
            
            if texture_img_width_acc_max < texture_img_width_acc
                texture_img_width_acc_max = texture_img_width_acc;
            end
                        
            texture_img = zeros(texture_img_height_acc, texture_img_width_acc_max, 4);
            letter_codes_pos_mat = NaN(texture_img_height_acc, texture_img_width_acc_max);
            if obj.txt_direction == TexturedTextMaker.ENUM_TXT_DIRECTION_LEFT_TO_RIGHT
                cursor_pos = [1,1];
                for char_i = 1:txt_len
                    if isempty(imgs_to_show_is{char_i});                        
                        cursor_pos = [cursor_pos(1) + obj.space_width, cursor_pos(2)];
                    elseif imgs_to_show_is{char_i} <= numel(obj.imgs) - 2
                        texture_img(cursor_pos(1):imgs_szs(char_i,1), cursor_pos(2):imgs_szs(char_i,2), 1:3) = obj.imgs{imgs_to_show_is{char_i}};
                        texture_img(cursor_pos(1):imgs_szs(char_i,1), cursor_pos(2):imgs_szs(char_i,2), 4) = 1;
                        letter_codes_pos_mat(cursor_pos(1):imgs_szs(char_i,1), cursor_pos(2):imgs_szs(char_i,2)) = obj.letter_codes{imgs_to_show_is{char_i}};
                        cursor_pos = [cursor_pos(1) + imgs_szs(char_i,2), cursor_pos(2)];
                        
                    elseif imgs_to_show_is{char_i} == numel(obj.imgs) - 1
                        % new line                        
                        cursor_pos = [1, cursor_pos(2) + obj.letters_height];
                    end
                end
            else
                cursor_pos = [texture_img_width_acc_max, 1];
                for char_i = 1:txt_len
                    if isempty(imgs_to_show_is{char_i});                        
                        cursor_pos = [cursor_pos(1) - obj.space_width, cursor_pos(2)];
                    elseif imgs_to_show_is{char_i} <= numel(obj.imgs) - 2
                        texture_img((cursor_pos(1) - imgs_szs(char_i,1)):cursor_pos(1), cursor_pos(2):imgs_szs(char_i,2), 1:3) = obj.imgs{imgs_to_show_is{char_i}};
                        texture_img((cursor_pos(1) - imgs_szs(char_i,1)):cursor_pos(1), cursor_pos(2):imgs_szs(char_i,2), 4) = 1;
                        letter_codes_pos_mat((cursor_pos(1) - imgs_szs(char_i,1)):cursor_pos(1), cursor_pos(2):imgs_szs(char_i,2)) = obj.letter_codes{imgs_to_show_is{char_i}};
                        cursor_pos = [cursor_pos(1) - imgs_szs(char_i,2), cursor_pos(2)];
                    elseif imgs_to_show_is{char_i} == numel(obj.imgs) - 1
                        % new line                        
                        cursor_pos = [texture_img_width_acc_max, cursor_pos(2) + obj.letters_height];
                    end
                end
            end                                    
        end
    end
end

