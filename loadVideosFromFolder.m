function videos= loadVideosFromFolder(folder, videos_type, window)
    videos_type= ['*', '.', videos_type];
    if (folder(length(folder))~=filesep)
        folder= [folder, filesep];
    end
    videos_names= dir([folder, videos_type]);
    videos= cell(length(videos_names));
    for i = 1:length(videos_names)                 
        videos{i} = Screen('OpenMovie', window, [folder, videos_names(i).name]);
    end
end

