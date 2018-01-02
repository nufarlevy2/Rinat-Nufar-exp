function sounds = loadSoundsFromFolder(folder, sound_type)
    sound_type= ['*', '.', sound_type];
    if (folder(length(folder))~=filesep)
        folder= [folder, filesep];
    end
    sound_names= dir([folder, sound_type]);
    sounds= cell(length(sound_names), 2);
    for i = 1:length(sound_names)
        [sounds{i,1}, sounds{i,2}] = audioread([folder, sound_names(i).name]);
    end
end

