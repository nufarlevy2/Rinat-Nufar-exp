function images= loadImagesFromFolder(folder, img_type)
    %% images= loadImagesFromFolder(folder, img_type)
    % loads all the images of type img_type from folder into the
    % images cell array.
    %
    % input:
    % * folder: the full path to the folder containing the images.
    % * img_time: a string of the images format (ie. 'png', 'jpg', etc...).
    %
    % output:
    % images= a cell array containing an image in each cell.
    img_type= ['*', '.', img_type];
    if (folder(length(folder))~=filesep)
        folder= [folder, filesep];
    end
    image_names= dir([folder, img_type]);
    images= cell(1, length(image_names));
    for i = 1:length(image_names)
        images{i} = imread([folder, image_names(i).name]);
    end
end