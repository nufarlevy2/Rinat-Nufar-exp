classdef Sides < double
    enumeration
        left(1), right(2), up(3), down(4)
    end
        
    methods (Static)
        function str= asstr(side)
            switch (side)
                case Sides.left
                    str= 'left';
                case Sides.right
                    str= 'right';
                case Sides.up
                    str= 'up';
                case Sides.down
                    str= 'down';
            end
        end
    end
end

