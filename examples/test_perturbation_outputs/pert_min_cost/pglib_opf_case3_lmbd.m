%% MATPOWER Case Format : Version 2
function mpc = pglib_opf_case3_lmbd
mpc.version = '2';

%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100.0;
%% bus data
%    bus_i    type    Pd    Qd    Gs    Bs    area    Vm    Va    baseKV    zone    Vmax    Vmin
mpc.bus = [
	1	3	110.00000000000001	40.0	0.0	0.0	1	1.0	0.0	240.0	1	1.1	0.9				
	2	2	110.00000000000001	40.0	0.0	0.0	1	1.0	0.0	240.0	1	1.1	0.9				
	3	2	95.0	50.0	0.0	0.0	1	1.0	0.0	240.0	1	1.1	0.9				
];

%% generator data
%    bus    Pg    Qg    Qmax    Qmin    Vg    mBase    status    Pmax    Pmin    Pc1    Pc2    Qc1min    Qc1max    Qc2min    Qc2max    ramp_agc    ramp_10    ramp_30    ramp_q    apf
mpc.gen = [
	1	1000.0	0.0	1000.0	-1000.0	1.0	100.0	1	2000.0	0.0															
	2	1000.0	0.0	1000.0	-1000.0	1.0	100.0	1	2000.0	0.0															
	3	0.0	0.0	1000.0	-1000.0	1.0	100.0	1	0.0	0.0															
];

%% branch data
%    f_bus    t_bus    r    x    b    rateA    rateB    rateC    ratio    angle    status    angmin    angmax
mpc.branch = [
	1	3	0.065	0.62	0.45	9000.0	9000.0	9000.0	0	0	1	-29.999999999999996	29.999999999999996								
	3	2	0.025	0.75	0.7	50.0	50.0	50.0	0	0	1	-29.999999999999996	29.999999999999996								
	1	2	0.042	0.9	0.3	9000.0	9000.0	9000.0	0	0	1	-29.999999999999996	29.999999999999996								
];

%%-----  OPF Data  -----%%
%% cost data
%    1    startup    shutdown    n    x1    y1    ...    xn    yn
%    2    startup    shutdown    n    c(n-1)    ...    c0
mpc.gencost = [
	2	0.0	0.0	3	0.11	5.0	0.0
	2	0.0	0.0	3	0.08500000000000002	1.2	0.0
	2	0.0	0.0	3	0.0	0.0	0.0
];

