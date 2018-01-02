function [texes, dims]= loadTexesFromPngsFolder(folder, window, progressBarPTB, progressContribution)   
    if (folder(length(folder))~=filesep)
        folder= [folder, filesep];
    end
    image_names= dir([folder, '*.png']);
    texes= cell(length(image_names),1); 
    dims= zeros(length(image_names), 2);
    imgsNr= length(image_names);
    for i = 1:imgsNr
        [texes{i}, dims(i,:)] = imgFileToTex([folder, image_names(i).name]);
        if nargin==4
            progressBarPTB.addProgress(1/imgsNr*progressContribution);
        end
    end
    
    function [tex, dim] = imgFileToTex(file_path)
        [im(:,:,1:3),~,im(:,:,4)]= imread(file_path);   
        dim= size(im);
        dim= dim([1,2]);
        tex= Screen('MakeTexture', window, im);
    end     
end