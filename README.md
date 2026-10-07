# EEE391 – Basics of Signals and Systems (Bilkent University, Fall 2025)

My homework and MATLAB mini project for EEE391.

| Folder | What it is |
|---|---|
| [`mini-project-2-signal-reconstruction`](mini-project-2-signal-reconstruction) | MATLAB: reconstructing continuous-time signals from samples |
| [`homework-1`](homework-1) | Written homework 1 (PDF) |
| [`homework-2`](homework-2) | Written homework 2 (PDF) |

## Mini Project 2 – Signal Reconstruction

`signal_reconstruction.m` rebuilds a continuous-time signal y(t) from a finite sequence y[n] and sampling period Ts by summing shifted interpolation pulses:

- **Square pulse** – zero-order hold, staircase output
- **Triangular pulse** – linear interpolation
- **Parabolic pulse** – piecewise-quadratic pulse with negative side lobes that approximates sinc
- **Truncated sinc** – ideal band-limited interpolation cut to ±3Ts or ±5Ts, with a comparison of the two

Run it in MATLAB. It asks for a mode (demo sequences, or your own `n` and `y[n]`), the sampling period and the pulse type. `report.pdf` explains the results with plots.

---
Author: Irmak İmdat
