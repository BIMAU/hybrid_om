set(groot,'defaultAxesTickLabelInterpreter','latex');
% quantities = {'Km', 'Ke', 'Z'};
quantities = {'Km'};
% plot_types = {'density', 'lines'};
plot_types = {'density'};
clear p
do_annotate = true;
fs = 14.5;

for qu = 1:numel(quantities)
    for pt = 1:numel(plot_types)
        plot_type = plot_types{pt};
        quantity = quantities{qu};
        clf()
        idxMap.E = 0;
        idxMap.Z = 0;
        idxMap.Km = opts.windowsize;
        idxMap.Ke = opts.windowsize;

        ylbls.E = '$E$';
        ylbls.Z = '$Z$';
        ylbls.Km = '$K_m$';
        ylbls.Ke = '$K_e$';

        % Confidence interval for the reference run
        tserie_full = ref_stats.(quantity);
        trunc_ref = 50*365;
        mn = mean(tserie_full(trunc_ref:end));
        vr = var(tserie_full(trunc_ref:end));
        conf_hi = mn + 2*sqrt(vr);
        conf_lo = mn - 2*sqrt(vr);

        legnames = {};

        skip = {'noise'};

        pltidx = 0

        h = tiledlayout(2,3, 'TileSpacing', 'compact', 'Padding', 'normal');

        for kidx = 1:numel(keys)

            key = keys{kidx};
            values = nan(Nsubdirs, 365*40);
            for i = 1:Nsubdirs
                stst = allstats{kidx, i}.(quantity);
                values(i,1:numel(stst)) = stst;
            end

            time = (idxMap.(quantity) + (1:size(values,2)) ) / 365;

            % skip vars
            if ismember(key, skip)
                continue
            end

            pltidx = pltidx + 1;
            disp(key)

            % subplot(2,3,pltidx)
            nexttile
            if strcmp(plot_type, 'density')


                T = repmat(time,50,1);
                nbinsT = 160;
                nbinsV = 650;

                Tbins = linspace(min(T(:)), max(T(:)), nbinsT);

                Vbins = linspace(0, 0.1, nbinsV);
                % Vbins = linspace(0, max(values(:)), nbinsV);

                h = hist3( [T(:), values(:)], ...
                           'ctrs', {Tbins',  Vbins'});


                imagesc( Tbins, Vbins, h');
                my_colmap = [1,1,1; summer(128)];

                colormap(my_colmap);
                caxis([0,300]);

                set(gca,'ydir','normal')

            elseif strcmp(plot_type, 'lines')

                handles = my_plot(time, values, ...
                                  'color', originsMap.(key).color, ...
                                  'linewidth', 0.1);

                p(pltidx) = handles(1);
                legnames = [legnames, originsMap.(key).name];
            end
            hold on

            xticks([10,20,30])
            yticks([0.005,0.01,0.015,0.02,0.025])

            if ismember(pltidx, [4,5,6])
                xlabel('time (years)', 'interpreter', 'latex');
            else
                xticklabels([]);
            end

            if ismember(pltidx, [1,4])
                ylabel(ylbls.(quantity), 'interpreter', 'latex');
            else
                yticklabels([]);
            end

            if ismember(pltidx, [3,6])
                c = colorbar;
                c.TickLabelInterpreter = 'latex';
                c.Label.String = 'density (bin count)';
                c.Label.Interpreter = 'latex';
                c.Ticks = [100,200,300];
                c.TickLabels{3} = '$\ge 300$';
                c.Limits = [1,300];
            end

            f_c = plot(xlim(), [conf_hi, conf_hi], ...
                       '--', 'color', cols(1,:), 'linewidth',1.8);
            f_c = plot(xlim(), [conf_lo, conf_lo], ...
                       '--', 'color', cols(1,:), 'linewidth',1.8);

            if do_annotate
                message = sprintf('Restarts from\n%s', ...
                                     originsMap.(key).simplename)

                tx = 18;
                ty = 0.01;

                text(tx, ty, message, ...
                     'fontsize', fs, ...
                     'interpreter', 'latex');
                rectangle('Position', [tx-.4 ty-0.0027 21.5 0.006])
            end

            if strcmp(quantity, 'Km')
                ymax = max(max(values(:)), 0.025);
                ymax = 0.027;
                ymin = 0.007;
                ylim([ymin, ymax]);
            end
            xlim([opts.windowsize/365, 40]);

            grid on
            hold off
            set(gca,'fontsize',fs)
        end

        legnames = [legnames, [' confidence interval', newline, ' (perfect QG)']];

        % sp = subplot(2,3,6);
                    
        if pltidx == 6
            if strcmp(plot_type, 'lines')
                legend([p, f_c], legnames, ...
                       'interpreter', 'latex', ...
                       'orientation', 'vertical', 'location', 'north');
            elseif strcmp(plot_type, 'density')
                legend([f_c], legnames, ...
                       'interpreter', 'latex', ...
                       'orientation', 'vertical', 'location', 'north', 'fontsize',12);
            end
        end

        % exporting

        dims = [27, 12];
        invert = false;
        if do_annotate
            annotated = '_annotated';
        else
            annotated = '';
        end

        exportdir = '~/Projects/doc/mlqg/figs/QG_transients/';
        Utils.exportfig([exportdir, 'returnspinups_', ...
                         quantity, '_', plot_type, ...
                         annotated, '.eps'], ...
                        fs, dims, invert);
    end
end