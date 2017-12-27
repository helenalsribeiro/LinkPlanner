function [mag_x, mag_y, phase_dif] = plotPhotonStream(fname)

[data, symbolperiod,sampling,type,number] = readSignal_20171220(fname);
data_x = data(1:4:end) + 1i.*data(2:4:end);
data_x = real(data_x)' + imag(data_x)'.*1i;
data_y = data(3:4:end) + 1i.*data(4:4:end);
data_y = real(data_y)' + imag(data_y)'.*1i;

mag_x = abs(data_x(1:end));
mag_y = abs(data_y(1:end));


phase_dif = angle(data_x(1:end)) - angle(data_y(1:end));
phase_dif = rad2deg(phase_dif);

figure (1)

subplot(3,1,1);
plotSignal(mag_x,symbolperiod,sampling,'PhotonStreamXY',number)
axis([0 inf 0 1])
title ('Amplitude X');
subplot(3,1,2);
plotSignal(mag_y,symbolperiod,sampling,'PhotonStreamXY',number)
axis([0 inf 0 1])
title('Amplitude Y');
subplot(3,1,3);
plotSignal(phase_dif,symbolperiod,sampling,'PhotonStreamXY',number)
axis([0 inf -180 180])
title ('Phase shift (Degrees)');