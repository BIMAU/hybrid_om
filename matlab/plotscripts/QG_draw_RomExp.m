addpath('../')

base_dir = '~/Projects/hybrid_om/data/experiments/';
exportdir = '~/Projects/doc/mlqg/figs/QG_scaling/';
invert = false;

%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------
% Gather data
romexp4_dir = 'QG_RomExp_NR3200_MC4/SC_1-5_RF_1-0.0625_parallel_param_5.00e+02/';
fulldir4=[base_dir, romexp4_dir, '/'];
[~, nums4, ~, mdat4, ~, ~, ~] = ...
            Utils.gather_data(fulldir4);
p4 = Plot(fulldir4);

romexp8_dir = 'QG_RomExp_NR3200_MC8/SC_1-5_RF_1-0.0625_parallel_param_5.00e+02/';
fulldir8=[base_dir, romexp8_dir, '/'];
[~, nums8, ~, mdat8, ~,~, ~] = ...
    Utils.gather_data(fulldir8);
p8 = Plot(fulldir8);

% %  -------------
clf
% % DRAW ROM experiments
p4.plot_mean = false;
p4.plot_scatter = false;
p4.style = {'o','o','--o'};
p4.msize = {6, 6};
[n4,~,~,~,f4,h4] = p4.plot_experiment(false, false, nums4, mdat4);
h4{1}.Visible='off';

%-------------------
hold on
p8.plot_mean = false;
p8.plot_scatter = false;
p8.style = {'.','.-','.-'};
p8.msize = {15, 15};
[n8,~,~,~,f8,h8] = p8.plot_experiment(false, false, nums8, mdat8);
h8{1}.Visible='off';
hold off

legend([f8{2:end},f4{2:end}], ...
       'ESN+DMDc, wavelet modes', ...
       'ESN+DMDc, global POD modes', ...
       'ESN+DMDc, local POD modes', ...
       'ESNc, wavelet modes', ...
       'ESNc, global POD modes', ...
       'ESNc, local POD modes', ...
       'interpreter', 'latex','location','southwest','numcolumns', 2)
ylabel('accurate days', 'interpreter', 'latex')
xlabel('Reduction factor $r/N_c$', 'interpreter', 'latex')
set(gca,'xtick',[1,5,9,13])
set(gca,'xticklabels', {'1','3/4','1/2','1/4'})
xtickangle(0)

title('');

fs = 12;
dims = [20,14];
exportfig([exportdir, 'results_romexp.eps'], fs, dims, invert)