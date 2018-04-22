  function presentageOfConsistancy = WhatIsThePresentageOfConsistency(AveragedRanks, endTrialsIndex, trials)
      resultIndex = 1;
      %calculating the average of each candidate
      for trialI = 1:endTrialsIndex
          leftPIC = trials(trialI).left_picture;
          rightPIC = trials(trialI).right_picture;
          if isnan(leftPIC) || isnan(rightPIC) || isnan(AveragedRanks(leftPIC)) ...
            || isnan(AveragedRanks(rightPIC)) || isnan(trials(trialI).response) ...
            || trials(trialI).response == 2
              continue;
          end
          if trials(trialI).response == 0 %response left
              if AveragedRanks(leftPIC) > AveragedRanks(rightPIC)
                  result(resultIndex) = 1;
              else
                  result(resultIndex) = 0;
              end
              resultIndex = resultIndex+1;
          elseif trials(trialI).response == 1 %response right
              if AveragedRanks(leftPIC) < AveragedRanks(rightPIC)
                  result(resultIndex) = 1;
              else
                  result(resultIndex) = 0;
              end
              resultIndex = resultIndex+1;
          end
      end
      if resultIndex == 1
          presentageOfConsistancy = NaN;
      else
          presentageOfConsistancy = (sum(result)/length(result))*100;
      end
  end