%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                                                                  %%%%%
%%%%      NICTA Energy System Test Case Archive (NESTA) - v0.7.0      %%%%%
%%%%               Optimal Power Flow - Radial Topology               %%%%%
%%%%                         05 - June - 2017                         %%%%%
%%%%                                                                  %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   A modified version of the IEEE 30 bus network with a linear objective used in,
%
%   Kocuk, B. & Dey, S. & Sun, X.A.,
%   "Inexactness of SDP Relaxation and Valid Inequalities for Optimal Power Flow",
%   IEEE Transactions on Power Systems, March, 2015
%
function mpc = nesta_case30_l_kds__rad
mpc.version = '2';
mpc.baseMVA = 100.0;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	 3	 0.0	 0.0	 0.0	 0.0	 1	    1.06000	    0.00000	 132.0	 1	    1.06000	    0.94000;
	2	 2	 10.85	 6.35	 0.0	 0.0	 1	    1.04300	   -5.48000	 132.0	 1	    1.06000	    0.94000;
	3	 1	 1.2	 0.6	 0.0	 0.0	 1	    1.02100	   -7.96000	 132.0	 1	    1.06000	    0.94000;
	4	 1	 3.8	 0.8	 0.0	 0.0	 1	    1.01200	   -9.62000	 132.0	 1	    1.06000	    0.94000;
	5	 2	 47.1	 9.5	 0.0	 0.0	 1	    1.01000	  -14.37000	 132.0	 1	    1.06000	    0.94000;
	6	 1	 0.0	 0.0	 0.0	 0.0	 1	    1.01000	  -11.34000	 132.0	 1	    1.06000	    0.94000;
	7	 1	 11.4	 5.45	 0.0	 0.0	 1	    1.00200	  -13.12000	 132.0	 1	    1.06000	    0.94000;
	8	 2	 15.0	 15.0	 0.0	 0.0	 1	    1.01000	  -12.10000	 132.0	 1	    1.06000	    0.94000;
	9	 1	 0.0	 0.0	 0.0	 0.0	 1	    1.05100	  -14.38000	 1.0	 1	    1.06000	    0.94000;
	10	 1	 2.9	 1.0	 0.0	 19.0	 1	    1.04500	  -15.97000	 33.0	 1	    1.06000	    0.94000;
	11	 2	 0.0	 0.0	 0.0	 0.0	 1	    1.08200	  -14.39000	 11.0	 1	    1.06000	    0.94000;
	12	 1	 5.6	 3.75	 0.0	 0.0	 1	    1.05700	  -15.24000	 33.0	 1	    1.06000	    0.94000;
	13	 2	 0.0	 0.0	 0.0	 0.0	 1	    1.07100	  -15.24000	 11.0	 1	    1.06000	    0.94000;
	14	 1	 3.1	 0.8	 0.0	 0.0	 1	    1.04200	  -16.13000	 33.0	 1	    1.06000	    0.94000;
	15	 1	 4.1	 1.25	 0.0	 0.0	 1	    1.03800	  -16.22000	 33.0	 1	    1.06000	    0.94000;
	16	 1	 1.75	 0.9	 0.0	 0.0	 1	    1.04500	  -15.83000	 33.0	 1	    1.06000	    0.94000;
	17	 1	 4.5	 2.9	 0.0	 0.0	 1	    1.04000	  -16.14000	 33.0	 1	    1.06000	    0.94000;
	18	 1	 1.6	 0.45	 0.0	 0.0	 1	    1.02800	  -16.82000	 33.0	 1	    1.06000	    0.94000;
	19	 1	 4.75	 1.7	 0.0	 0.0	 1	    1.02600	  -17.00000	 33.0	 1	    1.06000	    0.94000;
	20	 1	 1.1	 0.35	 0.0	 0.0	 1	    1.03000	  -16.80000	 33.0	 1	    1.06000	    0.94000;
	21	 1	 8.75	 5.6	 0.0	 0.0	 1	    1.03300	  -16.42000	 33.0	 1	    1.06000	    0.94000;
	22	 1	 0.0	 0.0	 0.0	 0.0	 1	    1.03300	  -16.41000	 33.0	 1	    1.06000	    0.94000;
	23	 1	 1.6	 0.8	 0.0	 0.0	 1	    1.02700	  -16.61000	 33.0	 1	    1.06000	    0.94000;
	24	 1	 4.35	 3.35	 0.0	 4.3	 1	    1.02100	  -16.78000	 33.0	 1	    1.06000	    0.94000;
	25	 1	 0.0	 0.0	 0.0	 0.0	 1	    1.01700	  -16.35000	 33.0	 1	    1.06000	    0.94000;
	26	 1	 1.75	 1.15	 0.0	 0.0	 1	    1.00000	  -16.77000	 33.0	 1	    1.06000	    0.94000;
	27	 1	 0.0	 0.0	 0.0	 0.0	 1	    1.02300	  -15.82000	 33.0	 1	    1.06000	    0.94000;
	28	 1	 0.0	 0.0	 0.0	 0.0	 1	    1.00700	  -11.97000	 132.0	 1	    1.06000	    0.94000;
	29	 1	 1.2	 0.45	 0.0	 0.0	 1	    1.00300	  -17.06000	 33.0	 1	    1.06000	    0.94000;
	30	 1	 5.3	 0.95	 0.0	 0.0	 1	    0.99200	  -17.94000	 33.0	 1	    1.06000	    0.94000;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	 260.2	 -16.1	 10.0	 10.0	 1.06	 100.0	 1	 360.2	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0; % NG
	2	 40.0	 50.0	 50.0	 -30.0	 1.045	 100.0	 1	 140.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0; % NG
	5	 0.0	 37.0	 40.0	 -30.0	 1.01	 100.0	 1	 100.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0; % SYNC
	8	 0.0	 37.3	 40.0	 0.0	 1.01	 100.0	 1	 100.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0; % SYNC
	11	 0.0	 16.2	 24.0	 4.0	 1.082	 100.0	 1	 100.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0; % SYNC
	13	 0.0	 10.6	 24.0	 4.0	 1.071	 100.0	 1	 100.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0; % SYNC
];

%% generator cost data
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	 0.0	 0.0	 3	   0.000000	  20.000000	   0.000000; % NG
	2	 0.0	 0.0	 3	   0.000000	  20.000000	   0.000000; % NG
	2	 0.0	 0.0	 3	   0.000000	  40.000000	   0.000000; % SYNC
	2	 0.0	 0.0	 3	   0.000000	  40.000000	   0.000000; % SYNC
	2	 0.0	 0.0	 3	   0.000000	  40.000000	   0.000000; % SYNC
	2	 0.0	 0.0	 3	   0.000000	  40.000000	   0.000000; % SYNC
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	 3	 0.0452	 0.1652	 0.0408	 172	 172	 172	 0.0	 0.0	 1	 -30.0	 30.0;
	2	 4	 0.057	 0.1737	 0.0368	 161	 161	 161	 0.0	 0.0	 1	 -30.0	 30.0;
	3	 4	 0.0132	 0.0379	 0.0084	 731	 731	 731	 0.0	 0.0	 1	 -30.0	 30.0;
	2	 6	 0.0581	 0.1763	 0.0374	 159	 159	 159	 0.0	 0.0	 1	 -30.0	 30.0;
	5	 7	 0.046	 0.116	 0.0204	 236	 236	 236	 0.0	 0.0	 1	 -30.0	 30.0;
	6	 7	 0.0267	 0.082	 0.017	 341	 341	 341	 0.0	 0.0	 1	 -30.0	 30.0;
	6	 8	 0.012	 0.042	 0.009	 672	 672	 672	 0.0	 0.0	 1	 -30.0	 30.0;
	6	 10	 0.0	 0.556	 0.0	 53	 53	 53	 0.0	 0.0	 1	 -30.0	 30.0;
	9	 11	 0.0	 0.208	 0.0	 142	 142	 142	 0.0	 0.0	 1	 -30.0	 30.0;
	9	 10	 0.0	 0.11	 0.0	 267	 267	 267	 0.0	 0.0	 1	 -30.0	 30.0;
	4	 12	 0.0	 0.256	 0.0	 115	 115	 115	 0.0	 0.0	 1	 -30.0	 30.0;
	12	 13	 0.0	 0.14	 0.0	 210	 210	 210	 0.0	 0.0	 1	 -30.0	 30.0;
	12	 14	 0.1231	 0.2559	 0.0	 104	 104	 104	 0.0	 0.0	 1	 -30.0	 30.0;
	12	 15	 0.0662	 0.1304	 0.0	 201	 201	 201	 0.0	 0.0	 1	 -30.0	 30.0;
	16	 17	 0.0524	 0.1923	 0.0	 148	 148	 148	 0.0	 0.0	 1	 -30.0	 30.0;
	15	 18	 0.1073	 0.2185	 0.0	 121	 121	 121	 0.0	 0.0	 1	 -30.0	 30.0;
	18	 19	 0.0639	 0.1292	 0.0	 204	 204	 204	 0.0	 0.0	 1	 -30.0	 30.0;
	10	 20	 0.0936	 0.209	 0.0	 129	 129	 129	 0.0	 0.0	 1	 -30.0	 30.0;
	10	 17	 0.0324	 0.0845	 0.0	 325	 325	 325	 0.0	 0.0	 1	 -30.0	 30.0;
	10	 22	 0.0727	 0.1499	 0.0	 177	 177	 177	 0.0	 0.0	 1	 -30.0	 30.0;
	21	 22	 0.0116	 0.0236	 0.0	 1116	 1116	 1116	 0.0	 0.0	 1	 -30.0	 30.0;
	22	 24	 0.115	 0.179	 0.0	 138	 138	 138	 0.0	 0.0	 1	 -30.0	 30.0;
	23	 24	 0.132	 0.27	 0.0	 98	 98	 98	 0.0	 0.0	 1	 -30.0	 30.0;
	25	 26	 0.2544	 0.38	 0.0	 65	 65	 65	 0.0	 0.0	 1	 -30.0	 30.0;
	25	 27	 0.1093	 0.2087	 0.0	 125	 125	 125	 0.0	 0.0	 1	 -30.0	 30.0;
	28	 27	 0.0	 0.396	 0.0	 75	 75	 75	 0.0	 0.0	 1	 -30.0	 30.0;
	27	 29	 0.2198	 0.4153	 0.0	 63	 63	 63	 0.0	 0.0	 1	 -30.0	 30.0;
	29	 30	 0.2399	 0.4533	 0.0	 58	 58	 58	 0.0	 0.0	 1	 -30.0	 30.0;
	8	 28	 0.0636	 0.2	 0.0428	 140	 140	 140	 0.0	 0.0	 1	 -30.0	 30.0;
];

% INFO    : === Translation Options ===
% INFO    : Phase Angle Bound:           30.0 (deg.)
% INFO    : Line Capacity Model:         ub
% INFO    : Gen Reactive Capacity Model: am50ag
% INFO    : Line Capacity PAB:           15.0 (deg.)
% INFO    : 
% INFO    : === Generator Classification Notes ===
% INFO    : SYNC   4   -     0.00
% INFO    : NG     2   -   100.00
% INFO    : 
% INFO    : === Generator Reactive Capacity Atmost Max 50 Percent Active Model Notes ===
% INFO    : 
% INFO    : === Line Capacity UB Model Notes ===
% INFO    : Updated Thermal Rating: on line 1-3 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 172
% INFO    : Updated Thermal Rating: on line 2-4 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 161
% INFO    : Updated Thermal Rating: on line 3-4 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 731
% INFO    : Updated Thermal Rating: on line 2-6 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 159
% INFO    : Updated Thermal Rating: on line 5-7 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 236
% INFO    : Updated Thermal Rating: on line 6-7 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 341
% INFO    : Updated Thermal Rating: on line 6-8 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 672
% INFO    : Updated Thermal Rating: on line 6-10 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 53
% INFO    : Updated Thermal Rating: on line 9-11 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 142
% INFO    : Updated Thermal Rating: on line 9-10 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 267
% INFO    : Updated Thermal Rating: on line 4-12 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 115
% INFO    : Updated Thermal Rating: on line 12-13 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 210
% INFO    : Updated Thermal Rating: on line 12-14 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 104
% INFO    : Updated Thermal Rating: on line 12-15 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 201
% INFO    : Updated Thermal Rating: on line 16-17 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 148
% INFO    : Updated Thermal Rating: on line 15-18 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 121
% INFO    : Updated Thermal Rating: on line 18-19 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 204
% INFO    : Updated Thermal Rating: on line 10-20 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 129
% INFO    : Updated Thermal Rating: on line 10-17 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 325
% INFO    : Updated Thermal Rating: on line 10-22 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 177
% INFO    : Updated Thermal Rating: on line 21-22 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 1116
% INFO    : Updated Thermal Rating: on line 22-24 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 138
% INFO    : Updated Thermal Rating: on line 23-24 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 98
% INFO    : Updated Thermal Rating: on line 25-26 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 65
% INFO    : Updated Thermal Rating: on line 25-27 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 125
% INFO    : Updated Thermal Rating: on line 28-27 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 75
% INFO    : Updated Thermal Rating: on line 27-29 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 63
% INFO    : Updated Thermal Rating: on line 29-30 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 58
% INFO    : Updated Thermal Rating: on line 8-28 : Rate A, Rate B, Rate C , 9900.0, 0.0, 0.0 -> 140
% INFO    : 
% INFO    : === Writing Matpower Case File Notes ===
