%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                                                                  %%%%%
%%%%      NICTA Energy System Test Case Archive (NESTA) - v0.7.0      %%%%%
%%%%               Optimal Power Flow - Radial Topology               %%%%%
%%%%                         05 - June - 2017                         %%%%%
%%%%                                                                  %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   A modified version of the FSR 30 bus network with a quadratic objective used in,
%
%   Kocuk, B. & Dey, S. & Sun, X.A.,
%   "Inexactness of SDP Relaxation and Valid Inequalities for Optimal Power Flow",
%   IEEE Transactions on Power Systems, March, 2015
%
%   Based on data from:
%     Alsac, O. & Stott, B., "Optimal Load Flow with Steady State Security",
%     IEEE Transactions on Power Apparatus and Systems, Vol. PAS 93, No. 3,
%     1974, pp. 745-751.
%   
%   With additional modifications from:
%     Ferrero, R.W., Shahidehpour, S.M., Ramesh, V.C., "Transaction analysis
%     in deregulated power systems using game theory", IEEE Transactions on
%     Power Systems, Vol. 12, No. 3, Aug 1997, pp. 1340-1347.
%
function mpc = nesta_case30_fsr_kds__rad
mpc.version = '2';
mpc.baseMVA = 100.0;

%% area data
%	area	refbus
mpc.areas = [
	1	 8;
	2	 23;
	3	 26;
];

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	 3	 0.0	 0.0	 0.0	 0.0	 1	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	2	 2	 21.7	 12.7	 0.0	 0.0	 1	    1.00000	    0.00000	 135.0	 1	    1.10000	    0.95000;
	3	 1	 2.4	 1.2	 0.0	 0.0	 1	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	4	 1	 7.6	 1.6	 0.0	 0.0	 1	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	5	 1	 0.0	 0.0	 0.0	 0.19	 1	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	6	 1	 0.0	 0.0	 0.0	 0.0	 1	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	7	 1	 22.8	 10.9	 0.0	 0.0	 1	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	8	 1	 30.0	 30.0	 0.0	 0.0	 1	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	9	 1	 0.0	 0.0	 0.0	 0.0	 1	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	10	 1	 5.8	 2.0	 0.0	 0.0	 3	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	11	 1	 0.0	 0.0	 0.0	 0.0	 1	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	12	 1	 11.2	 7.5	 0.0	 0.0	 2	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	13	 2	 0.0	 0.0	 0.0	 0.0	 2	    1.00000	    0.00000	 135.0	 1	    1.10000	    0.95000;
	14	 1	 6.2	 1.6	 0.0	 0.0	 2	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	15	 1	 8.2	 2.5	 0.0	 0.0	 2	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	16	 1	 3.5	 1.8	 0.0	 0.0	 2	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	17	 1	 9.0	 5.8	 0.0	 0.0	 2	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	18	 1	 3.2	 0.9	 0.0	 0.0	 2	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	19	 1	 9.5	 3.4	 0.0	 0.0	 2	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	20	 1	 2.2	 0.7	 0.0	 0.0	 2	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	21	 1	 17.5	 11.2	 0.0	 0.0	 3	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	22	 2	 0.0	 0.0	 0.0	 0.0	 3	    1.00000	    0.00000	 135.0	 1	    1.10000	    0.95000;
	23	 2	 3.2	 1.6	 0.0	 0.0	 2	    1.00000	    0.00000	 135.0	 1	    1.10000	    0.95000;
	24	 1	 8.7	 6.7	 0.0	 0.04	 3	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	25	 1	 0.0	 0.0	 0.0	 0.0	 3	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	26	 1	 3.5	 2.3	 0.0	 0.0	 3	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	27	 2	 0.0	 0.0	 0.0	 0.0	 3	    1.00000	    0.00000	 135.0	 1	    1.10000	    0.95000;
	28	 1	 0.0	 0.0	 0.0	 0.0	 1	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	29	 1	 2.4	 0.9	 0.0	 0.0	 3	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
	30	 1	 10.6	 1.9	 0.0	 0.0	 3	    1.00000	    0.00000	 135.0	 1	    1.05000	    0.95000;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	 23.54	 0.0	 40.0	 4.0	 1.0	 100.0	 1	 80.0	 30.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0; % PEL
	2	 60.97	 0.0	 40.0	 4.0	 1.0	 100.0	 1	 80.0	 30.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0; % NG
	22	 21.59	 0.0	 25.0	 9.0	 1.0	 100.0	 1	 50.0	 30.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0; % NG
	27	 26.91	 0.0	 28.0	 9.0	 1.0	 100.0	 1	 55.0	 30.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0; % NG
	23	 19.2	 0.0	 15.0	 14.0	 1.0	 100.0	 1	 30.0	 30.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0; % NG
	13	 37.0	 0.0	 20.0	 9.0	 1.0	 100.0	 1	 40.0	 30.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0; % NG
];

%% generator cost data
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	 0.0	 0.0	 3	   0.020000	   2.000000	   0.000000; % PEL
	2	 0.0	 0.0	 3	   0.017500	   1.750000	   0.000000; % NG
	2	 0.0	 0.0	 3	   0.062500	   1.000000	   0.000000; % NG
	2	 0.0	 0.0	 3	   0.008340	   3.250000	   0.000000; % NG
	2	 0.0	 0.0	 3	   0.025000	   3.000000	   0.000000; % NG
	2	 0.0	 0.0	 3	   0.025000	   3.000000	   0.000000; % NG
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	 3	 0.05	 0.19	 0.02	 147	 130.0	 130.0	 0.0	 0.0	 1	 -30.0	 30.0;
	2	 4	 0.06	 0.17	 0.02	 174	 65.0	 65.0	 0.0	 0.0	 1	 -30.0	 30.0;
	3	 4	 0.01	 0.04	 0.0	 699	 130.0	 130.0	 0.0	 0.0	 1	 -30.0	 30.0;
	2	 6	 0.06	 0.18	 0.02	 166	 65.0	 65.0	 0.0	 0.0	 1	 -30.0	 30.0;
	5	 7	 0.05	 0.12	 0.01	 222	 70.0	 70.0	 0.0	 0.0	 1	 -30.0	 30.0;
	6	 7	 0.03	 0.08	 0.01	 337	 130.0	 130.0	 0.0	 0.0	 1	 -30.0	 30.0;
	6	 8	 0.01	 0.04	 0.0	 699	 32.0	 32.0	 0.0	 0.0	 1	 -30.0	 30.0;
	6	 10	 0.0	 0.56	 0.0	 52	 32.0	 32.0	 0.0	 0.0	 1	 -30.0	 30.0;
	9	 11	 0.0	 0.21	 0.0	 138	 65.0	 65.0	 0.0	 0.0	 1	 -30.0	 30.0;
	9	 10	 0.0	 0.11	 0.0	 262	 65.0	 65.0	 0.0	 0.0	 1	 -30.0	 30.0;
	4	 12	 0.0	 0.26	 0.0	 111	 65.0	 65.0	 0.0	 0.0	 1	 -30.0	 30.0;
	12	 13	 0.0	 0.14	 0.0	 224	 65.0	 65.0	 0.0	 0.0	 1	 -30.0	 30.0;
	12	 14	 0.12	 0.26	 0.0	 101	 32.0	 32.0	 0.0	 0.0	 1	 -30.0	 30.0;
	12	 15	 0.07	 0.13	 0.0	 195	 32.0	 32.0	 0.0	 0.0	 1	 -30.0	 30.0;
	16	 17	 0.08	 0.19	 0.0	 140	 16.0	 16.0	 0.0	 0.0	 1	 -30.0	 30.0;
	15	 18	 0.11	 0.22	 0.0	 118	 16.0	 16.0	 0.0	 0.0	 1	 -30.0	 30.0;
	18	 19	 0.06	 0.13	 0.0	 202	 16.0	 16.0	 0.0	 0.0	 1	 -30.0	 30.0;
	10	 20	 0.09	 0.21	 0.0	 126	 32.0	 32.0	 0.0	 0.0	 1	 -30.0	 30.0;
	10	 17	 0.03	 0.08	 0.0	 337	 32.0	 32.0	 0.0	 0.0	 1	 -30.0	 30.0;
	10	 22	 0.07	 0.15	 0.0	 190	 32.0	 32.0	 0.0	 0.0	 1	 -30.0	 30.0;
	21	 22	 0.01	 0.02	 0.0	 1402	 32.0	 32.0	 0.0	 0.0	 1	 -30.0	 30.0;
	22	 24	 0.12	 0.18	 0.0	 145	 16.0	 16.0	 0.0	 0.0	 1	 -30.0	 30.0;
	23	 24	 0.13	 0.27	 0.0	 105	 16.0	 16.0	 0.0	 0.0	 1	 -30.0	 30.0;
	25	 26	 0.25	 0.38	 0.0	 64	 16.0	 16.0	 0.0	 0.0	 1	 -30.0	 30.0;
	25	 27	 0.11	 0.21	 0.0	 133	 16.0	 16.0	 0.0	 0.0	 1	 -30.0	 30.0;
	28	 27	 0.0	 0.4	 0.0	 79	 65.0	 65.0	 0.0	 0.0	 1	 -30.0	 30.0;
	27	 29	 0.22	 0.42	 0.0	 67	 16.0	 16.0	 0.0	 0.0	 1	 -30.0	 30.0;
	29	 30	 0.24	 0.45	 0.0	 57	 16.0	 16.0	 0.0	 0.0	 1	 -30.0	 30.0;
	8	 28	 0.06	 0.2	 0.02	 138	 32.0	 32.0	 0.0	 0.0	 1	 -30.0	 30.0;
];

% INFO    : === Translation Options ===
% INFO    : Phase Angle Bound:           30.0 (deg.)
% INFO    : Line Capacity Model:         ub
% INFO    : Gen Reactive Capacity Model: am50ag
% INFO    : Line Capacity PAB:           15.0 (deg.)
% INFO    : 
% INFO    : === Generator Classification Notes ===
% INFO    : PEL    1   -    12.44
% INFO    : NG     5   -    87.56
% INFO    : 
% INFO    : === Generator Reactive Capacity Atmost Max 50 Percent Active Model Notes ===
% INFO    : Gen at bus 1 - PEL	: Pmax 80.0, Qmin 4.0, Qmax 150.0 -> Qmin 4.0, Qmax 40.0
% INFO    : Gen at bus 2 - NG	: Pmax 80.0, Qmin 4.0, Qmax 60.0 -> Qmin 4.0, Qmax 40.0
% INFO    : Gen at bus 22 - NG	: Pmax 50.0, Qmin 9.0, Qmax 62.5 -> Qmin 9.0, Qmax 25.0
% INFO    : Gen at bus 27 - NG	: Pmax 55.0, Qmin 9.0, Qmax 48.7 -> Qmin 9.0, Qmax 28.0
% INFO    : Gen at bus 23 - NG	: Pmax 30.0, Qmin 14.0, Qmax 40.0 -> Qmin 14.0, Qmax 15.0
% INFO    : Gen at bus 13 - NG	: Pmax 40.0, Qmin 9.0, Qmax 44.7 -> Qmin 9.0, Qmax 20.0
% INFO    : 
% INFO    : === Line Capacity UB Model Notes ===
% INFO    : Updated Thermal Rating: on line 1-3 : Rate A , 9900.0 -> 147
% INFO    : Updated Thermal Rating: on line 2-4 : Rate A , 9900.0 -> 174
% INFO    : Updated Thermal Rating: on line 3-4 : Rate A , 9900.0 -> 699
% INFO    : Updated Thermal Rating: on line 2-6 : Rate A , 9900.0 -> 166
% INFO    : Updated Thermal Rating: on line 5-7 : Rate A , 9900.0 -> 222
% INFO    : Updated Thermal Rating: on line 6-7 : Rate A , 9900.0 -> 337
% INFO    : Updated Thermal Rating: on line 6-8 : Rate A , 9900.0 -> 699
% INFO    : Updated Thermal Rating: on line 6-10 : Rate A , 9900.0 -> 52
% INFO    : Updated Thermal Rating: on line 9-11 : Rate A , 9900.0 -> 138
% INFO    : Updated Thermal Rating: on line 9-10 : Rate A , 9900.0 -> 262
% INFO    : Updated Thermal Rating: on line 4-12 : Rate A , 9900.0 -> 111
% INFO    : Updated Thermal Rating: on line 12-13 : Rate A , 9900.0 -> 224
% INFO    : Updated Thermal Rating: on line 12-14 : Rate A , 9900.0 -> 101
% INFO    : Updated Thermal Rating: on line 12-15 : Rate A , 9900.0 -> 195
% INFO    : Updated Thermal Rating: on line 16-17 : Rate A , 9900.0 -> 140
% INFO    : Updated Thermal Rating: on line 15-18 : Rate A , 9900.0 -> 118
% INFO    : Updated Thermal Rating: on line 18-19 : Rate A , 9900.0 -> 202
% INFO    : Updated Thermal Rating: on line 10-20 : Rate A , 9900.0 -> 126
% INFO    : Updated Thermal Rating: on line 10-17 : Rate A , 9900.0 -> 337
% INFO    : Updated Thermal Rating: on line 10-22 : Rate A , 9900.0 -> 190
% INFO    : Updated Thermal Rating: on line 21-22 : Rate A , 9900.0 -> 1402
% INFO    : Updated Thermal Rating: on line 22-24 : Rate A , 9900.0 -> 145
% INFO    : Updated Thermal Rating: on line 23-24 : Rate A , 9900.0 -> 105
% INFO    : Updated Thermal Rating: on line 25-26 : Rate A , 9900.0 -> 64
% INFO    : Updated Thermal Rating: on line 25-27 : Rate A , 9900.0 -> 133
% INFO    : Updated Thermal Rating: on line 28-27 : Rate A , 9900.0 -> 79
% INFO    : Updated Thermal Rating: on line 27-29 : Rate A , 9900.0 -> 67
% INFO    : Updated Thermal Rating: on line 29-30 : Rate A , 9900.0 -> 57
% INFO    : Updated Thermal Rating: on line 8-28 : Rate A , 9900.0 -> 138
% INFO    : 
% INFO    : === Writing Matpower Case File Notes ===
