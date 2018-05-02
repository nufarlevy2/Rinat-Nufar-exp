  function resultFinal = subjectLookingAt(AveragedRanks, fixation, endTrialsIndex)
      resultIndex = 1;
      %calculating the average of each candidate
      for trialI = 1:endTrialsIndex
          leftPIC = fixation(trialI).left_picture;
          rightPIC = fixation(trialI).right_picture;
          if isnan(leftPIC) || isnan(rightPIC) || isnan(AveragedRanks(leftPIC)) ...
            || isnan(AveragedRanks(rightPIC))
              continue;
          end
          if strcmp(fixation(trialI).race_model_predicted_response,'NO') && ...
                  strcmp(fixation(trialI).diffusion_model_predicted_response,'NO') && ...
                  strcmp(fixation(trialI).response, 'Left')
              if AveragedRanks(leftPIC) > AveragedRanks(rightPIC)
                  result(resultIndex) = 1;
              else
                  result(resultIndex) = 0;
              end
              resultIndex = resultIndex+1;
          elseif strcmp(fixation(trialI).race_model_predicted_response,'NO') && ...
                  strcmp(fixation(trialI).diffusion_model_predicted_response,'NO') && ...
                  strcmp(fixation(trialI).response, 'Right')
              if AveragedRanks(leftPIC) < AveragedRanks(rightPIC)
                  result(resultIndex) = 1;
              else
                  result(resultIndex) = 0;
              end
              resultIndex = resultIndex+1;
          end
                  
      end
      if resultIndex == 1
          resultFinal = NaN;
      else
          resultFinal = (sum(result)/length(result))*100;
      end
  end