% EEE 391 - MATLAB Mini Project 2: Signal Reconstruction
% Irmak Imdat
%
% Interactive version: reconstructs a discrete-time sequence y[n] into a
% continuous-time signal y(t) using a chosen interpolation pulse
% (square, triangular, parabolic, or truncated sinc).

clear
clc
close all

modeChoice = input('Select mode (1 demonstration of a, b, c; 2 trying your own sequence): ');

Ts = input('Enter the sampling period Ts: ');

pulseNumber = menu('Select pulse type', ...
    'Square', 'Triangular', 'Parabolic', 'Truncated ideal');

switch pulseNumber
    case 1
        pulse = 'square';
    case 2
        pulse = 'triangular';
    case 3
        pulse = 'parabolic';
    case 4
        pulse = 'sinc3';
end

if modeChoice == 1
    % Sequence a
    n_a = -3:6;
    y_a = [2, -2, 0, 2, 0, 1, 0, -5, 7, 0]; % id number values

    % Sequence b
    n_b = -12:12;
    y_b = 10 * exp(-0.25 * abs(n_b));

    % Parts a and b
    reconstruct_and_plot(n_a, y_a, Ts, pulse, 'Sequence (a)');
    reconstruct_and_plot(n_b, y_b, Ts, pulse, 'Sequence (b)');

    % Part c
    if strcmp(pulse, 'sinc3')
        compare_sinc_truncation(n_a, y_a, Ts, 'Sequence (a)');
        compare_sinc_truncation(n_b, y_b, Ts, 'Sequence (b)');
    end
elseif modeChoice == 2
    n = input('Enter index vector n: ');
    y = input('Enter sequence y[n] (same length as n): ');

    n = n(:).';
    y = y(:).';

    if numel(n) ~= numel(y)
        error('Error: n and y must have the same length.');
    end

    reconstruct_and_plot(n, y, Ts, pulse, 'User-defined sequence');

    if strcmp(pulse, 'sinc3')
        compare_sinc_truncation(n, y, Ts, 'User-defined sequence');
    end
end

function reconstruct_and_plot(n, y, Ts, pulse_type, seq_label)
    if strcmp(pulse_type, 'sinc3')
        spanTs = 3;
    elseif strcmp(pulse_type, 'sinc5')
        spanTs = 5;
    else
        spanTs = [];
    end

    [t, y_rec] = reconstruct_signal(n, y, Ts, pulse_type, spanTs);

    figure;
    plot(t, y_rec); hold on;
    stem(n*Ts, y, 'filled');
    grid on;

    xlabel('t (seconds)');
    ylabel('Amplitude');
    title([seq_label, ' using ', pulse_type]);
    legend('y(t)', 'y[n]');
end

function compare_sinc_truncation(n, y, Ts, seq_label)
    [t3, y3] = reconstruct_signal(n, y, Ts, 'sinc3', 3);
    [t5, y5] = reconstruct_signal(n, y, Ts, 'sinc5', 5);

    figure;
    plot(t3, y3); hold on;
    plot(t5, y5);
    grid on;
    xlabel('t (seconds)');
    ylabel('Amplitude');
    title([seq_label ' Sinc truncation comparison']);
    legend('+/- 3Ts', '+/- 5Ts');
end

function [t, y_rec] = reconstruct_signal(n, y, Ts, pulse_type, spanTs)
    % pulse support in Ts units
    switch pulse_type
        case 'square'
            pulse_span_Ts = 1;
        case 'triangular'
            pulse_span_Ts = 2;
        case 'parabolic'
            pulse_span_Ts = 4;
        case 'sinc3'
            pulse_span_Ts = 2 * 3;
        case 'sinc5'
            pulse_span_Ts = 2 * 5;
    end

    % time axis
    L = 50;
    dt = Ts / L;
    t_min = (min(n) - pulse_span_Ts/2) * Ts;
    t_max = (max(n) + pulse_span_Ts/2) * Ts;
    t = t_min : dt : t_max;

    % reconstruction
    y_rec = zeros(size(t));
    for k = 1:length(n)
        tk = t - n(k)*Ts;
        switch pulse_type
            case 'square'
                p = pulse_square(tk, Ts);
            case 'triangular'
                p = pulse_triangular(tk, Ts);
            case 'parabolic'
                p = pulse_parabolic(tk, Ts);
            case {'sinc3','sinc5'}
                p = pulse_sinc(tk, Ts, spanTs);
        end
        y_rec = y_rec + y(k) * p;
    end
end

function p = pulse_square(t, Ts)
    p = double( (t >= -Ts/2) & (t <= Ts/2) );
end

function p = pulse_triangular(t, Ts)
    p = max(0, 1 - abs(t)/Ts);
end

function p = pulse_parabolic(t, Ts)
    p = zeros(size(t));

    % middle segment, 1 - (t/Ts)^2
    mid = (abs(t) <= Ts);
    p(mid) = 1 - (t(mid)/Ts).^2;

    % left segment
    left = (t >= -2*Ts) & (t < -Ts);
    tl = t(left);
    % A * (x - r1) * (x - r2)
    p(left) = 0.85 * (tl/Ts + 1) .* (tl/Ts + 2);

    % right segment
    right = (t > Ts) & (t <= 2*Ts);

    if sum(left) == sum(right)
        p(right) = flip(p(left));
    else
        tr = t(right);
        p(right) = 0.85 * (tr/Ts - 1) .* (tr/Ts - 2);
    end
end

function p = pulse_sinc(t, Ts, spanTs)
    p = zeros(size(t));
    idx = abs(t) <= spanTs*Ts;
    x = pi * t(idx) / Ts;
    p(idx) = sin(x) ./ x;
    p(t == 0) = 1;
end
