import json

# Fred: you want to use the 'bal-red cases'

with open('enwl_data_eng_mod.json', 'r') as f:
    obj = json.load(f)

bal_red_cases = []
for key, value in obj.items():
    for key_1, value_1 in value.items():
        bal_red_cases.append(value_1['bal-red'])

# Fix weird linecode syntax and voltage_source syntax
for bal_red_case in bal_red_cases:
    for _, val in bal_red_case['linecode'].items():
        for _, val_1 in val.items():
            val_1['value'] = float(val_1['value'].strip('[]'))

    bal_red_case['voltage_source']['source']['rs']['value'] = float(bal_red_case['voltage_source']['source']['rs']['value'].strip('[]'))
    bal_red_case['voltage_source']['source']['xs']['value'] = float(bal_red_case['voltage_source']['source']['xs']['value'].strip('[]'))

for i in range(len(bal_red_cases)):
    with open(f'test_case_{i + 1}.json', 'w') as f:
        json.dump(bal_red_cases[i], f, indent=4)