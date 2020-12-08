function mpc = test_3_bus
mpc.version = '2';
mpc.baseMVA = 1.0;
 
%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1	 3	 90.0	 30.0	 0.0	 0.0	 1	    1.00000	    0.00000	 345.0	 1	    2	    1;
	2	 2	 90.0	 30.0	 0.0	 0.0	 1	    1.00000	    0.00000	 345.0	 1	    2	    1;
	3	 2	 90.0	 30.0	 0.0	 0.0	 1	    1.00000	    0.00000	 345.0	 1	    2	    1;
];

%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
mpc.gen = [
	1	 0.0	 0.0	 1000	 0	 1.0	 100.0	 1	 1000	 0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0; % NUC
	2	 100.0	 0.0	 1000	 0	 1.0	 100.0	 1	 1000	 0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0; % NUC
	3	 100.0	 0.0	 1000	 0	 1.0	 100.0	 1	 1000	 0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0	 0.0; % NUC
];

%% generator cost data
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	 1500.0	 0.0	 3	   0	   500	 0; % NUC
	2	 1500.0	 0.0	 3	   0	   500	 0; % NUC
	2	 1500.0	 0.0	 3	   0	   500	 0; % NUC
];

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
mpc.branch = [
	1	 2	 0.1	 0.1	 0.1	 1000	 250.0	 250.0	 0.0	 0.0	 1	 -30.0	 30.0;
	2	 3	 0.1	 0.1	 0.1	 1000	 250.0	 250.0	 0.0	 0.0	 1	 -30.0	 30.0;
];

% INFO    : === Translation Options ===
% INFO    : Phase Angle Bound:           30.0 (deg.)
% INFO    : Line Capacity Model:         ub
% INFO    : Gen Reactive Capacity Model: am50ag
% INFO    : Line Capacity PAB:           25.0 (deg.)
% WARNING : No active generation at the slack bus, assigning type - NUC
% INFO    : 
% INFO    : === Generator Classification Notes ===
% INFO    : NUC    1   -     0.00
% INFO    : COW    1   -    65.73
% INFO    : NG     1   -    34.27
% INFO    : 
% INFO    : === Generator Reactive Capacity Atmost Max 50 Percent Active Model Notes ===
% INFO    : Gen at bus 1 - NUC	: Pmax 250.0, Qmin 100.0, Qmax 300.0 -> Qmin 100.0, Qmax 125.0
% INFO    : Gen at bus 2 - COW	: Pmax 300.0, Qmin 100.0, Qmax 300.0 -> Qmin 100.0, Qmax 150.0
% INFO    : Gen at bus 3 - NG	: Pmax 270.0, Qmin 100.0, Qmax 300.0 -> Qmin 100.0, Qmax 135.0
% INFO    : 
% INFO    : === Line Capacity UB Model Notes ===
% INFO    : Updated Thermal Rating: on line 1-4 : Rate A , 9900.0 -> 910
% INFO    : Updated Thermal Rating: on line 4-5 : Rate A , 9900.0 -> 560
% INFO    : Updated Thermal Rating: on line 5-6 : Rate A , 9900.0 -> 301
% INFO    : Updated Thermal Rating: on line 3-6 : Rate A , 9900.0 -> 894
% INFO    : Updated Thermal Rating: on line 7-8 : Rate A , 9900.0 -> 723
% INFO    : Updated Thermal Rating: on line 8-2 : Rate A , 9900.0 -> 839
% INFO    : Updated Thermal Rating: on line 8-9 : Rate A , 9900.0 -> 320
% INFO    : Updated Thermal Rating: on line 9-4 : Rate A , 9900.0 -> 612
% INFO    : 
% INFO    : === Writing Matpower Case File Notes ===
