exp_dirs = {'Pathak2018repl/NR_200-6400_MC_1-8_parallel_param_1.00e+00/', ...
            'Pathak2018repl/NR_200-6400_MC_1-8_parallel_param_1.00e-01/', ...
            'Pathak2018repl/NR_200-6400_MC_1-8_parallel_param_1.00e-02/'};

base_dir = '~/Projects/hybrid_om/data/experiments/';

for k = 1:numel(exp_dirs)
    dir = [base_dir, exp_dirs{k}, '/'];

    p = Plot(dir);
    p.description = false;
    p.legend = false;
    p.grid = false;
    p.plot_mean = false;
    p.plot_scatter = false;
    p.show_title = false;
    p.scaling = 0.25 * 0.07;
    p.ylab = 'Valid time';
    p.xlab = 'Reservoir size';

    [nums, mdat, preds, truths, Nbox] = p.plot_experiment();

    output_dir = ['~/Projects/doc/mlqg/figs/', exp_dirs{k}];
    eval(['mkdir ', output_dir]);
    exportfig([output_dir, '/fig.eps'], 12, [18,14])
end

% create legend plot

% -- TODO