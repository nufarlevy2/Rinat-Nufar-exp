function hebrew_char_codes = asciiToUnicodeHebrew(ascii_codes)
    hebrew_char_codes = NaN(1, length(ascii_codes));
    for code_i = 1:length(ascii_codes)
        switch(ascii_codes(code_i))
            case 45
                %0
                hebrew_char_code = 0;
            case 48
                %0
                hebrew_char_code = 0;
            case 96
                %0
                hebrew_char_code = 0;                
            case 49
                %1
                hebrew_char_code = 1;
            case 35
                %1
                hebrew_char_code = 1;
            case 97
                %1
                hebrew_char_code = 1;                
            case 50
                %2
                hebrew_char_code = 2;
            case 40
                %2
                hebrew_char_code = 2;
            case 98
                %2
                hebrew_char_code = 2;                
            case 51
                %3
                hebrew_char_code = 3;
            case 34
                %3
                hebrew_char_code = 3;
            case 99
                %3
                hebrew_char_code = 3;                
            case 100
                %4
                hebrew_char_code = 4;            
            case 52
                %4
                hebrew_char_code = 4;
            case 37
                %4
                hebrew_char_code = 4;
            case 53
                %5
                hebrew_char_code = 5;
            case 12
                %5
                hebrew_char_code = 5;
            case 101
                %5
                hebrew_char_code = 5;                
            case 54
                %6
                hebrew_char_code = 6;
            case 102
                %6
                hebrew_char_code = 6;                
            case 39
                %6
                hebrew_char_code = 6;
            case 55
                %7
                hebrew_char_code = 7;
            case 36
                %7
                hebrew_char_code = 7;
            case 103
                %7
                hebrew_char_code = 7;                
            case 56
                %8
                hebrew_char_code = 8;
            case 38
                %8
                hebrew_char_code = 8;
            case 104
                %8
                hebrew_char_code = 8;                
            case 57
                %9
                hebrew_char_code = 9;
            case 33
                %9
                hebrew_char_code = 9;
            case 105
                %9
                hebrew_char_code = 9;                
            otherwise
                hebrew_char_code = -1;                                                                                                                                                                                                 
        end
        hebrew_char_codes(code_i) = hebrew_char_code;
    end
end