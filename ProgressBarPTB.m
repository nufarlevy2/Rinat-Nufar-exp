classdef ProgressBarPTB < handle      
    properties (Access = private)
        ptbWindow;
        ptbWindowRect;
        progressBarHeight;
        progressBarLen;
        progressBarFrameColor;
        progressBarFrameLineWidth;
        progressBarFillerColor;
        progress= 0;        
    end
    
    methods (Access = public)
        function obj = ProgressBarPTB(ptbWindow, ptbWindowRect, progressBarHeight, progressBarLen, progressBarFrameLineWidth, progressBarFrameColor, progressBarFillerColor)
            obj.ptbWindow = ptbWindow;
            obj.ptbWindowRect= ptbWindowRect;
            obj.progressBarHeight = progressBarHeight;
            obj.progressBarLen = progressBarLen;
            obj.progressBarFrameColor = progressBarFrameColor;
            obj.progressBarFrameLineWidth = progressBarFrameLineWidth;
            obj.progressBarFillerColor= progressBarFillerColor;
        end
        
        function drawProgressBar(obj, progress)
            obj.progress = min(max(progress, 0), 1);
            progress_bar_frame_rect= genRect(round(obj.ptbWindowRect(3:4)/2), [obj.progressBarLen, obj.progressBarHeight])';
            Screen('FrameRect', obj.ptbWindow, obj.progressBarFrameColor, progress_bar_frame_rect,  obj.progressBarFrameLineWidth);            
            if (progress>0)
                load_bar_filler_width= obj.progressBarLen-2*obj.progressBarFrameLineWidth;
                load_bar_filler_rect= [progress_bar_frame_rect(1:2)+obj.progressBarFrameLineWidth, ...
                    progress_bar_frame_rect(1)+obj.progressBarFrameLineWidth+round(progress*load_bar_filler_width), ...
                    progress_bar_frame_rect(4)-obj.progressBarFrameLineWidth];
                Screen('FillRect', obj.ptbWindow, obj.progressBarFillerColor, load_bar_filler_rect);
            end
            
            Screen('flip', obj.ptbWindow);
        end
        
        function addProgress(obj, progress)            
            drawProgressBar(obj, obj.progress + progress)
        end
        
        function res = isDone(obj)
            res= obj.progress == 1.0;
        end
    end    
end

