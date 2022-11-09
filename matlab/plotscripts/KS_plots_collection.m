% This script plots the relevant KS results for the paper

addpath('../')

exp_dirs = {'Pathak2018repl/NR_50-6400_MC_1-8_parallel_param_1.00e+00/', ...
            'Pathak2018repl/NR_50-6400_MC_1-8_parallel_param_1.00e-01/', ...
            'Pathak2018repl/NR_50-6400_MC_1-8_parallel_param_1.00e-02/' ...
            'KS_GridExp/NR_50-6400_MC_1-8_parallel_param_0.00e+00'};

base_dir = '../../data/experiments/';
set(groot,'defaultAxesTickLabelInterpreter','latex');
nums=[];
for k = 1:numel(exp_dirs)
    figure(k)
    clf
    dir = [base_dir, exp_dirs{k}, '/'];

    p = Plot(dir);
    p.legend=false;
    p.description = false;
    p.grid = false;
    p.plot_mean = false;
    p.plot_scatter = false;
    p.show_title = false;
    p.scaling = 0.25 * 0.07;
    p.ylab = 'Valid time';
    p.xlab = '$N_r$';
    p.style = {'.', '.-', {':', '-',':'}};
    p.msize = {15, 15};
    p.plot_q_conn = [1,1,1];

    [nums{k}, mdat, preds, truths, f] = p.plot_experiment(false);

    output_dir = ['~/Projects/doc/mlqg/figs/', exp_dirs{k}];
    eval(['mkdir ', output_dir]);

    Utils.create_description(mdat)
    if k == 3
        % create legend plot
        lgd = legend([f{:}], 'imperfect model', 'ESN', 'ESNc', 'DMDc', ...
                     'correction only', 'ESN+DMDc', 'location', 'northeastoutside', ...
                     'interpreter', 'latex', 'orientation','vertical');
        lgd.NumColumns = 1;
        Utils.exportfig([output_dir, '/fig.eps'], 16, [22,14])
    elseif k == 4
        % create legend plot
        lgd = legend([f{:}], 'imperfect model', 'ESN', 'ESNc', 'DMDc', ...
                     'correction only', 'ESN+DMDc', 'location', 'northwest', ...
                     'interpreter', 'latex', 'orientation','vertical');
        lgd.NumColumns = 1;
        Utils.exportfig([output_dir, '/fig.eps'], 16, [18,14])
    else
        Utils.exportfig([output_dir, '/fig.eps'], 16, [18,14])
    end
end