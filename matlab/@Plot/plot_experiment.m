function [nums, mdat, preds, truths] = plot_experiment(self, ignore_nans, flip_axes)
%
% gather data from experiment dir

    if nargin < 3
        flip_axes = false
    end
    if nargin < 2
        ignore_nans = true;
    end        
    
    [errs, nums, pids, mdat, preds, truths] = ...
        self.gather_data(self.dir);

    if ignore_nans
        % Failed experiments (usually out of memory) give nans. The whole row
        % is ignored. 
        plotIds = find(~isnan(sum(nums,2)));
        if numel(plotIds) ~= size(nums,1)
            fprintf('ignoring rows with nans\n');
            nums = nums(plotIds,:);
        end
    end
    
    [exp_ind, I] = sort( [mdat.exp_ind{:}] );
    Nexp = numel(exp_ind);

    labels  = [];
    Nvalues = [];

    for i = 1:Nexp
        labels{i}  = mdat.hyp_range(exp_ind(i), :);
        Nvalues(i) = numel(unique(labels{i}));
        xlab{i}    = mdat.xlab{I(i)};
    end

    if flip_axes
        [~, I] = sort(Nvalues, 'ascend');
    else
        [~, I] = sort(Nvalues, 'descend');
    end
    
    xlab_index = I(1); % x label corresponds to parameter with largest number of values
    maxValues  = Nvalues(xlab_index);
    Ntotal     = size(nums,2);
    Nboxplots  = Ntotal/maxValues;
    assert(Nboxplots == round(Nboxplots))

    % plot results
    f = [];
    clrs = lines(Nboxplots);

    H = mdat.hyp_range(exp_ind(xlab_index), :);
    range1 = 1:numel(H);
    range2 = 1:numel(H);
    if Nexp == 2 && numel(H) > 1
        M = reshape(1:numel(H), Nvalues(1), Nvalues(2));
        if H(2) ~= H(1)
            range1 = M(:);
            M = M';
            range2 = M(:);
        else
            range2 = M(:);
            M = M';
            range1 = M(:);
        end
        
    elseif Nexp > 2
        warning('undefined behaviour for Nexp = %d', Nexp);
    end

    nums = nums * self.scaling;

    for i = 1:Nboxplots
        subrange = range1((i-1)*maxValues+1:i*maxValues);
        f{i} = self.my_boxplot(nums(:, subrange), {clrs(i,:), clrs(i,:)});
        grid on;
        xticklabels([]);
        hold on
    end
    hold off

    xticklabels(mdat.hyp_range(exp_ind(xlab_index), subrange));
    xtickangle(45);
    xlabel(xlab{xlab_index});
    
    if isempty(self.ylab)
        ylabel(mdat.ylab);
    else
        ylabel(self.ylab);
    end

    % for combined experiments and multiple boxplots we need a legend
    if Nexp >= 2
        str = cell(Nboxplots,1);
        for i = 1:Nboxplots
            value = mdat.hyp_range(exp_ind(I(2)), range2(i));
            str{i} = sprintf('%s: %1.1e', xlab{I(2)}, value);
        end
        legend([f{:}], str, 'location', 'north')
    end

    if self.description
        % create description
        descr = self.create_description(mdat);
        ylim([min(ylim), 1.1*max(ylim)])
        text(min(xlim), max(ylim), descr, ...
             'color', [0,0,0] , 'VerticalAlignment', 'top', ...
             'FontName', 'Monospaced', 'FontSize', 9,'Interpreter', 'none');
    end

    title(sprintf('Experiment: %d training sets, %d par combinations', ...
                  size(nums,1), size(nums,2)));
end