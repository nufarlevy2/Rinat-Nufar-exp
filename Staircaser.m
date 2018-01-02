classdef Staircaser < handle 
    properties (Access= public)
        ENUM_STAIRCASER_DIRECTION_UP= 0;
        ENUM_STAIRCASER_DIRECTION_DOWN= 1;
        ENUM_STAIRCASER_DIRECTION_AT_REST= 2;
        
        ENUM_STAIRCASER_FAILURE= 0;
        ENUM_STAIRCASER_SUCCESS= 1;
    end
    
    properties (Access= private)               
        failure_succes_record= [];
        level_value_record= [];
        curr_trials_nr= 0;
        progression_regiment= [];
        progression_func= [];
        extra_data_for_progression= [];
        successes_count= 0;
        failures_count= 0;
        curr_level= 1;        
        has_staircaser_reversed= false;
        staircaser_direction= [];
    end
    
    methods (Access= public)
        function obj= Staircaser(progression_regiment, progression_func, primal_extra_data_for_progression)    
            if nargin<=2
                obj.extra_data_for_progression= [];
            else
                obj.extra_data_for_progression= primal_extra_data_for_progression;
            end
            
            obj.progression_regiment= progression_regiment;
            obj.progression_func= progression_func;            
            obj.staircaser_direction= obj.ENUM_STAIRCASER_DIRECTION_AT_REST;
        end
        
        function obj= addFailure(obj)
            obj.failures_count= obj.failures_count + 1;
            if (obj.failures_count==obj.progression_regiment(2))
                obj.failures_count= 0; 
                obj.successes_count= 0;                
                obj.curr_level= obj.curr_level - 1;
                                
                if (obj.staircaser_direction==obj.ENUM_STAIRCASER_DIRECTION_UP) 
                     obj.has_staircaser_reversed= true;
                elseif (obj.staircaser_direction==obj.ENUM_STAIRCASER_DIRECTION_DOWN) 
                    obj.has_staircaser_reversed= false;
                end
                
                obj.staircaser_direction= obj.ENUM_STAIRCASER_DIRECTION_DOWN;
            else
                obj.has_staircaser_reversed= false;
            end
            
            obj.curr_trials_nr= obj.curr_trials_nr + 1;
            obj.failure_succes_record(obj.curr_trials_nr)= obj.ENUM_STAIRCASER_FAILURE;
            obj.level_value_record(obj.curr_trials_nr)= obj.curr_level;
        end
        
        function obj= addSuccess(obj)
            obj.successes_count= obj.successes_count + 1;
            if (obj.successes_count==obj.progression_regiment(1))
                obj.failures_count= 0; 
                obj.successes_count= 0;              
                obj.curr_level= obj.curr_level + 1;
                
                if (obj.staircaser_direction==obj.ENUM_STAIRCASER_DIRECTION_DOWN) 
                     obj.has_staircaser_reversed= true;
                elseif (obj.staircaser_direction==obj.ENUM_STAIRCASER_DIRECTION_UP) 
                    obj.has_staircaser_reversed= false;
                end
                
                obj.staircaser_direction= obj.ENUM_STAIRCASER_DIRECTION_UP;
            else
                obj.has_staircaser_reversed= false;
            end
            
            obj.curr_trials_nr= obj.curr_trials_nr + 1;
            obj.failure_succes_record(obj.curr_trials_nr)= obj.ENUM_STAIRCASER_SUCCESS;
            obj.level_value_record(obj.curr_trials_nr)= obj.curr_level;
        end
        
        function level= getLevel(obj)
            level= obj.curr_level;
        end
        
        function staircaser_direction= getStaircaserDirection(obj)
            staircaser_direction= obj.staircaser_direction;
        end
        
        function has_sataircaser_reversed= hasStaircaserReversed(obj)
            has_sataircaser_reversed= obj.has_staircaser_reversed;
        end
        
        function level_value= getLevelValue(obj)
            [level_value, obj.extra_data_for_progression]= obj.progression_func(obj.curr_level, obj.extra_data_for_progression);
        end
        
        function failure_succes_record= getFailureSuccessRecord(obj)
            failure_succes_record= obj.failure_succes_record;
        end
        
        function level_value_record= getLevelValueRecord(obj)
            level_value_record= obj.level_value_record;
        end
    end
    
end

