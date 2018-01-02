function rect= genRect(pos, size)
    base_rect= [0, 0, size(1), size(2)];
    rect= CenterRectOnPointd(base_rect, pos(1), pos(2))';
end