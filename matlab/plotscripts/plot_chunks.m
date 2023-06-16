addpath('~/local/matlab')
addpath('../');

Re_f = 2000;
nx_f = 256;
ny_f = nx_f;
nun = 2;
dim = nun * nx_f * ny_f;

output_freq = 365;
final_day = 5110;
years = 40;
first_days = 1:output_freq:final_day;

E = zeros(1, output_freq * numel(first_days));
Z = zeros(1, output_freq * numel(first_days));

var_1y_E = [];
var_6m_E = [];
var_3m_E = [];
var_1y_Z = [];
var_6m_Z = [];
var_3m_Z = [];

% data_dir = sprintf(['/data/p267904/Projects/hybrid_om/data/QGmodel',...
%                     '/%d_%d'], dim, dim)

data_dir = '/home/erik/Projects/hybrid_om/data/QGmodel/return_from_esnc_131072_131072'

data_dir = '/home/erik/Projects/hybrid_om/data/QGmodel/return_from_modelonly_131072_131072'

 % '/home/erik/Projects/hybrid_om/data/QGmodel/return_from_esnc_131072_131072/transient_T=40_dt=2.740e-03_param=2.0e+03.chunk_1-365.mat'

for first_day = first_days
    last_day = first_day + output_freq - 1;
    data_fname = sprintf(['%s/transient_T=%d_dt=2.740e-03_param=%1.1e.chunk_%d-%d.mat'], ...
                         data_dir, years, Re_f, first_day, last_day);

    fprintf('load %s / %d\n', data_fname, final_day)
    data = load(data_fname);
    fprintf('  compute E, ')
    E(first_day:last_day) = sum(abs(data.X(1:nun:end,:) .* data.X(2:nun:end,:)));
    fprintf('  compute Z\n')
    Z(first_day:last_day) = sum(data.X(1:nun:end,:).^2);

    fprintf('  compute statistics\n')
    var_1y_E = [var_1y_E, var(E(first_day:last_day))];
    var_1y_Z = [var_1y_Z, var(Z(first_day:last_day))];

    range_6m1 = first_day:first_day + round((last_day-first_day)/2);
    range_6m2 = first_day + round((last_day-first_day)/2)+1:last_day;
    
    var_6m_E = [var_6m_E, var(E(range_6m1))];
    var_6m_E = [var_6m_E, var(E(range_6m2))];
    var_6m_Z = [var_6m_Z, var(Z(range_6m1))];
    var_6m_Z = [var_6m_Z, var(Z(range_6m2))];

    range_3m1 = first_day:first_day + round((last_day-first_day)/4);
    range_3m2 = first_day + round((last_day-first_day)/4)+1:first_day + round((last_day-first_day)/2);
    range_3m3 = first_day + round((last_day-first_day)/2)+1:first_day + round(3*(last_day-first_day)/4);
    range_3m4 = first_day + round(3*(last_day-first_day)/4)+1:last_day;

    var_3m_E = [var_3m_E, var(E(range_3m1))];
    var_3m_E = [var_3m_E, var(E(range_3m2))];
    var_3m_E = [var_3m_E, var(E(range_3m3))];
    var_3m_E = [var_3m_E, var(E(range_3m4))];
    var_3m_Z = [var_3m_Z, var(Z(range_3m1))];
    var_3m_Z = [var_3m_Z, var(Z(range_3m2))];
    var_3m_Z = [var_3m_Z, var(Z(range_3m3))];
    var_3m_Z = [var_3m_Z, var(Z(range_3m4))];
    
end

plot_name = sprintf(['%s/plot_transient_T=%3d_dt=2.740e-03_param=%1.1e.eps'], ...
                    data_dir, years, Re_f);

subplot(2,2,1)
plot(E)
title('kin. energy')
subplot(2,2,2)
plot(Z)
title('enstrophy')
subplot(2,2,3)
plot(1:numel(var_1y_E), var_1y_E); hold on
plot(linspace(1,numel(var_1y_E),2*numel(var_1y_E)), var_6m_E);
plot(linspace(1,numel(var_1y_E),4*numel(var_1y_E)), var_3m_E);
hold off
title('kin. energy variance')
set(gca, 'yscale', 'log')

subplot(2,2,4)
plot(1:numel(var_1y_Z), var_1y_Z); hold on
plot(linspace(1,numel(var_1y_Z),2*numel(var_1y_Z)), var_6m_Z);
plot(linspace(1,numel(var_1y_Z),4*numel(var_1y_Z)), var_3m_Z);
hold off
title('enstrophy variance')
set(gca, 'yscale', 'log')

fprintf('saving to %s\n', plot_name)
print(plot_name, '-depsc2', '-painters');