function [] = printpid(self, varargin)
    fid = fopen(['output_',num2str(self.pid),...
                 '.txt'], 'a');
    fprintf('pid_%d: ', self.pid);
    fprintf(varargin{:});
    fprintf(fid, varargin{:});
end