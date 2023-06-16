function [chunk] = load_chunk(qg, data, first, last, total_T)

    dim = qg.nun * qg.nx * qg.ny;

    if isstr(data)
        data_dir = data;
    else
        data_dir = sprintf(['%s/%s',...
                            '/%d_%d'], data.data_dir, qg.name, dim, dim);
    end

    chunk_fname = sprintf(['%s/transient_T=%d_dt=2.740e-03_param=%1.1e.chunk_%d-%d.mat'], ...
                          data_dir, total_T, qg.control_param(), first, last);

    time = tic();
    fprintf('loading chunk: %s\n', chunk_fname);
    chunk = load(chunk_fname);
    fprintf('loading chunk (done, %3.3fs)\n', toc(time));
end