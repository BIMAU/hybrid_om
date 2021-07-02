function [value] = arg_to_value(arg)
    if (ischar(arg) || isstring(arg))
        value = str2num(arg);
    else
        value = arg;
    end
end