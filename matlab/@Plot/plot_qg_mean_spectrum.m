function [f, Pm, Pv] = plot_qg_mean_spectrum(self, qg, states, opts, varargin)

    P = [];
    for i = opts.trunc+1:opts.skip:opts.T
        [rPrf, ~, maxr, ~] = self.get_qg_spectrum(qg, states(:,i));
        P = [P, rPrf];
    end

    Pm = mean(P')';
    Pv = var(P')';

    plot_range = 2:maxr-2;
    plot_range_var = 2:maxr-2;


    f = loglog(plot_range, Pm(plot_range), '.-', varargin{:});
    hold on
    if opts.conf_int
        conf_int_low = max(Pm(plot_range_var)-2*sqrt(Pv(plot_range_var)), 0);
        conf_int_hi = Pm(plot_range_var)+2*sqrt(Pv(plot_range_var));
        loglog(plot_range_var, conf_int_low, '--', varargin{:});
        loglog(plot_range_var, conf_int_hi, '--', varargin{:});
    end
    kx = 5;
    ky = kx;
    wavNum = floor(sqrt(kx^2+ky^2))+1;
    g = loglog([wavNum,wavNum], ylim, 'k--');

    xlim([min(plot_range),max(plot_range)]);
    ylim([1e-5,1e5]);
    hold off
end