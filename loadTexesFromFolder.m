function [texes, dims]= loadTexesFromFolder(folder, window, file_ext, progressBarPTB, progressContribution)   
    if (folder(length(folder))~=filesep)
        folder= [folder, filesep];
    end
    image_names= dir([folder, '*.', file_ext]);
    texes= cell(1, length(image_names)); 
    dims= zeros(length(image_names), 2);
    imgsNr= length(image_names);
    for i = 1:imgsNr
        [texes{i}, dims(i,:)] = imgFileToTex([folder, image_names(i).name]);
        if nargin==5
            progressBarPTB.addProgress(1/imgsNr*progressContribution);
        end
    end
    
    function [tex, dim] = imgFileToTex(file_path)
        im(:,:,1:3)= imread(file_path, file_ext);   
        dim= size(im);
        dim= dim([1,2]);
        tex= Screen('MakeTexture', window, im);
    end     
end