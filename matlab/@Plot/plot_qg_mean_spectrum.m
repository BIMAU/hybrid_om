function [f, Pm, Pv, g] = plot_qg_mean_spectrum(self, qg, states, opts, varargin)

    if ~isfield(opts, 'conf_int')
        opts.conf_int = false;
    end

    if ~isfield(opts, 'power_laws')
        opts.power_laws = false;
    end

    if (size(states,1) == qg.nx*qg.ny*qg.nun)
        [Pm, Pv] = Utils.get_qg_mean_spectrum(qg, states, opts);
    else
        Pm = mean(states{1},2);
        Pv = mean(states{2},2);
    end
    maxr = size(Pm,1);
    plot_range = 2:maxr-2;
    plot_range_var = 2:maxr-2;

    f = loglog(plot_range-1, Pm(plot_range), varargin{:});
    hold on
    if opts.conf_int
        conf_int_low = max(Pm(plot_range_var)-2*sqrt(Pv(plot_range_var)), 0);
        conf_int_hi = Pm(plot_range_var)+2*sqrt(Pv(plot_range_var));
        loglog(plot_range_var-1, conf_int_low, '--', varargin{:});
        loglog(plot_range_var-1, conf_int_hi, '--', varargin{:});
    end
    kx = 5;
    ky = kx;
    wavNum = floor(sqrt(kx^2+ky^2));

    if ~isfield(opts, 'stircol')
        opts.stircol = [0,0,0];
    end

    g = loglog([wavNum,wavNum], ylim, '--', 'color', opts.stircol);

    if opts.power_laws % broken
        x1 = 10^3 /(wavNum^-(5/3));
        x2 = 10^3 /(wavNum^-(3));
        x3 = 10^2 /(wavNum^-(6));

        frst = 1:wavNum-plot_range(1)+1;
        last = wavNum-plot_range(1)+1:numel(plot_range);

        loglog(plot_range(frst)-1, x1*(plot_range(frst)).^(-5/3),'k:');
        loglog(plot_range(last)-1, x2*(plot_range(last)).^(-3),'k:');
        loglog(plot_range(last)-1, x3*(plot_range(last)).^(-6),'k:');

        text(3, 100,   '$k^{-5/3}$', 'interpreter', 'latex');
        text(19, 0.02, '$k^{-6}$',   'interpreter', 'latex');

    end

    xlim([min(plot_range),max(plot_range)]);
    ylim([1e-5,1e5]);
    hold off
end