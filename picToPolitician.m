function nameOfPolitician = picToPolitician(num)
    dirCont = dir(['resources\\pics\\', '*.', 'jpg']);
    nameOfPolitician = dirCont(num).name;
end