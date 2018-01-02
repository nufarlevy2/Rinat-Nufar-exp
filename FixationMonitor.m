classdef FixationMonitor < handle 
    properties (Access= public)
        FIXATION_MONITOR_RESULT_IS_FIXATING= 0;
        FIXATION_MONITOR_RESULT_IS_SUSPECTED= 1;
        FIXATION_MONITOR_RESULT_IS_BREAKING= 2;
    end
    
    properties (Access= private)        
        state= [];
        counter= 0;        
        eyelink_obj= [];
        max_gaze_dist_from_center_allowed= 0; 
        gaze_samples_for_verdict= [];        
    end
            
    methods (Access= public)
        function obj= FixationMonitor(eyelink_obj, max_gaze_dist_from_center_allowed, gaze_samples_for_verdict)
            obj.eyelink_obj= eyelink_obj;
            obj.max_gaze_dist_from_center_allowed= max_gaze_dist_from_center_allowed;            
            obj.state= obj.FIXATION_MONITOR_RESULT_IS_FIXATING;
            obj.gaze_samples_for_verdict= gaze_samples_for_verdict;            
        end
        
        %if (and only if) test_result is
        %obj.FIXATION_MONITOR_RESULT_IS_BREAKING, then fixation was broken.
        function [obj, test_result]= testFixationBreaking(obj, fixation_loc, is_blinking_allowed)
            test_result= obj.FIXATION_MONITOR_RESULT_IS_FIXATING;
            eye_used = Eyelink('EyeAvailable'); % get eye that's tracked                        
            if eye_used ~= -1 && Eyelink('NewFloatSampleAvailable') > 0                
                evt = Eyelink('NewestFloatSample');   % get the sample in the form of an event structure 
                gaze_coords = NaN(2,2);
                if (eye_used == obj.eyelink_obj.BINOCULAR || eye_used == obj.eyelink_obj.LEFT_EYE) && evt.gx(obj.eyelink_obj.LEFT_EYE+1) ~= obj.eyelink_obj.MISSING_DATA && evt.gy(obj.eyelink_obj.LEFT_EYE+1) ~= obj.eyelink_obj.MISSING_DATA
                    gaze_coords(1,:)= ceil([evt.gx(obj.eyelink_obj.LEFT_EYE+1), evt.gy(obj.eyelink_obj.LEFT_EYE+1)]);
                end
                
                if (eye_used == obj.eyelink_obj.BINOCULAR || eye_used == obj.eyelink_obj.RIGHT_EYE) && evt.gx(obj.eyelink_obj.RIGHT_EYE+1) ~= obj.eyelink_obj.MISSING_DATA && evt.gy(obj.eyelink_obj.RIGHT_EYE+1) ~= obj.eyelink_obj.MISSING_DATA
                    gaze_coords(2,:)= ceil([evt.gx(obj.eyelink_obj.RIGHT_EYE+1), evt.gy(obj.eyelink_obj.RIGHT_EYE+1)]);
                end
                
                x = nanmean(gaze_coords(:,1));
                y = nanmean(gaze_coords(:,2));                      
                if x == obj.eyelink_obj.MISSING_DATA && y == obj.eyelink_obj.MISSING_DATA
                    if is_blinking_allowed
                        resetState();                                  
                    else
                        obj.state= obj.FIXATION_MONITOR_RESULT_IS_BREAKING;
                    end                                       
                else                
                    fix_dist_from_center = sqrt( (x - fixation_loc(1))^2 + (y - fixation_loc(2))^2 );
                    if fix_dist_from_center < obj.max_gaze_dist_from_center_allowed                     
                        resetState();    
                    else                                            
                        incCounter();
                    end                         
                end
                
                test_result= obj.state;
            end
            
            function incCounter()
                obj.counter= obj.counter+1;                    
                if obj.counter<obj.gaze_samples_for_verdict
                    obj.state= obj.FIXATION_MONITOR_RESULT_IS_SUSPECTED;                   
                else
                    obj.state= obj.FIXATION_MONITOR_RESULT_IS_BREAKING;                    
                    obj.counter= obj.gaze_samples_for_verdict-1;
                end                                
            end
            
            function resetState()
                obj.counter= 0;            
                obj.state= obj.FIXATION_MONITOR_RESULT_IS_FIXATING;            
            end
        end
        
        function state= getState(obj)
            state= obj.state;
        end
    end        
end
    

