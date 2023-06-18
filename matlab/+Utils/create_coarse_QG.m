function [qg_c] = create_coarse_QG()

% coarse QG with periodic bdc
    nx_c = 32;
    ny_c = nx_c;
    Re_c = 500;
    ampl = 2; % stirring amplitude
    stir = 0; % stirring type: 0 = cos(5x), 1 = sin(16x)

    qg_c = QG(nx_c, ny_c, 1);
    qg_c.set_par(5,  Re_c);  % Reynolds number
    qg_c.set_par(11, ampl);  % stirring amplitude
    qg_c.set_par(18, stir);  % stirring type: 0 = cos(5x), 1 = sin(16x)

end