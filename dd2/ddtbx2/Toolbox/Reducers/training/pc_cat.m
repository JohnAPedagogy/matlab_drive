function pc = pc_cat(acc, val)

    if isempty(acc)
        pc = val;
    else
        pc =[acc; [val(:,1:2) val(:,3)+max(acc(:,3))]];
    end
end