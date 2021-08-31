function set_model_config(self, value)
% set different model configurations
    if strcmp(value, 'model_only')
        self.esn_on = false;
        self.model_on = true;
    elseif strcmp(value, 'esn_only')
        self.esn_on = true;
        self.model_on = false;
    elseif strcmp(value, 'hybrid')
        self.esn_on = true;
        self.model_on = true;
    else
        error('invalid parameter')
    end                
end
