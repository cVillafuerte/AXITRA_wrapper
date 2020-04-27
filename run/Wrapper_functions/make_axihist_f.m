% Writing axi.hist file
%
% For Axitra force version:
%source_index, fx_amplitude, fy_amplitude, fz_amplitude, total_amplitude, time_delay

fid = fopen('axi.hist', 'wt');

    % Force version
    for is = 1:ns
        fprintf(fid,'%5d %12.6f %12.3f %12.3f %12.6e %12.3f\n',sources(is,1),fy(is),fx(is),fz(is),F_ampl(is),t0_delay(is));
    end
     