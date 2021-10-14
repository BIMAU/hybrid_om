function [] = add_paths()
    if ~isdeployed
        addpath('~/local/matlab/');
        addpath('~/Projects/ESN/matlab/');
    end
end

