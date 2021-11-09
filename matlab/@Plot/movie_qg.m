function [] = movie_qg(self, data, opts)
    [n,T] = size(data);
    for i = 1:opts.every:T
        plotQG(opts.nx, opts.ny, 1, data(:,i), false)
        drawnow
    end    
end