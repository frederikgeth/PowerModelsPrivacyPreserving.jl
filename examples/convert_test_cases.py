# TODO: Sort out units
# TODO: Understand if reference bus and root node stuff makes sense
import json
import math


def pretty_print(json_object):
    print(json.dumps(json_object, indent=4, sort_keys=True))


test_name = 'test_case_1.json'
with open(test_name, 'r') as f:
    obj = json.load(f)

# JSON syntax to handle inf
large_number = 1000000000

# Model constants
voltage_base = 400
power_base = 1000000
z_base = voltage_base / power_base

# Extract original data
buses = obj['bus']
loads = obj['load']
lines = obj['line']
voltage_source = obj['voltage_source']['source']
linecodes = obj['linecode']

# Lines
transformed_lines = {}
for line_id, line_json in lines.items():
    transformed_line = {}
    transformed_line['index'] = int(line_id.strip('line'))

    # Set to and from nodes
    transformed_line['f_bus'] = int(line_json['f_bus'])
    transformed_line['t_bus'] = int(line_json['t_bus'])

    # Set b and g
    transformed_line['b_to'] = 0
    transformed_line['g_to'] = 0
    transformed_line['b_fr'] = 0
    transformed_line['g_fr'] = 0

    # Get br_r and br_x values using linecode dictionary
    transformed_line['br_r'] = line_json['length'] * linecodes[line_json['linecode']]['rs']['value'] / z_base
    transformed_line['br_x'] = line_json['length'] * linecodes[line_json['linecode']]['xs']['value'] / z_base

    # Set rate_a to a large number as we can't use inf in json
    transformed_line['rate_a'] = large_number

    # Set angmin and angmax to default value pi / 6
    transformed_line['angmin'] = math.pi / 6
    transformed_line['angmax'] = math.pi / 6

    # Set unused params to default
    transformed_line['transformer'] = False
    transformed_line['tap'] = 1
    transformed_line['shift'] = 0
    transformed_line['br_status'] = 1

    # Powermodels wants numerical line_ids
    branch_id = line_id.strip('line')
    transformed_lines[branch_id] = transformed_line

# Loads
transformed_loads = {}
for load_id, load_json in loads.items():
    transformed_load = {}
    transformed_load['index'] = int(load_id.strip('load'))

    transformed_load['load_bus'] = load_json['bus']
    transformed_load['status'] = 1
    transformed_load['source_id'] = ['bus', load_json['bus']]
    transformed_load['qd'] = load_json['qd_nom'][0]
    transformed_load['pd'] = load_json['pd_nom'][0]

    # Powermodels wants numerical load_ids
    transformed_loads[load_id.strip('load')] = transformed_load

# Buses
transformed_buses = {}
for bus_id, bus_json in buses.items():
    transformed_bus = {}

    # Set all buses to type 1, except for reference bus
    if bus_id == 'sourcebus':
        transformed_bus['bus_type'] = 3
        bus_id = '0'
    transformed_bus['bus_type'] = 1

    transformed_bus['index'] = int(bus_id)

    # Set voltage parameters to constants
    transformed_bus['vmin'] = 0.94
    transformed_bus['vmax'] = 1.1
    transformed_bus['vm'] = 0
    transformed_bus['va'] = 0
    transformed_bus['base_kv'] = 0.4

    # Set unused parameters to arbitrary values
    transformed_bus['zone'] = 0
    transformed_bus['area'] = 0

    transformed_buses[bus_id] = transformed_bus


# Manually attach 1 gen to reference bus
ref_gen = {}
ref_gen['model'] = 2
ref_gen['pmin'] = -10000000  # Confirm using large negative number is acceptable
ref_gen['pmax'] = 10000000
ref_gen['qmin'] = -10000000  # Confirm using large negative number is acceptable
ref_gen['qmax'] = 10000000
ref_gen['cost'] = [0, 0]
ref_gen['source_id'] = ['gen', 1]
ref_gen['gen_status'] = 1
ref_gen['gen_bus'] = 0
ref_gen['index'] = 1

gens = {'1': ref_gen}



output_json = {
    'branch': transformed_lines,
    'bus': transformed_buses,
    'load': transformed_loads,
    'source_type': 'custom_json',
    'name': test_name,
    'shunt': {},
    'gen': gens,
    'storage': {},
    'switch': {},
    'dcline': {},
    'baseMVA': 1,  # TODO: what should this be?
    'per_unit': True  # TODO: what should this be?
}

with open('output.json', 'w') as f:
    json.dump(output_json, f, indent=4)

with open('/home/ver107/Dropbox/data61/NEAR/PowerModelsPrivacyPreserving.jl/test/data/output.json', 'w') as f:
    json.dump(output_json, f, indent=4)


