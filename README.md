# RISC-V Compliance Framework

## Setup
```
sudo apt-get install python3 pip3
pip3 intall cerberus oyaml
```

## Usage
```
python3 -m rips.main --help
python3 -m framework.main --help
```

## Example 
```
python3 -m rips.main --input Examples/eg1.yaml --schema rips/schema.yaml --verbose debug
python3 -m framework.main --input Examples/eg1_checked.yaml --verbose info
```

Differences against compliance suite:

rv32i/I-FENCE.I-01.S: line 81 needs to be added.
rv32i/I-IO.S: line 340 needs to be uncommented.
rv32i/I-RF_size-01.S: line 186 to line 189 need to be added
rv32i/I-RF_x0-01.S: add assertions at line:122, 126, 130, 134, 148, 154, 168, 172, 176, 180. Might
need to add lw x1, 0(x31) and the likes to check if sw value is correct?
rv32i/I-SLTI-01.S: lines 239 and 238 should be interchanged.
rv32i/I-SW-01.S: lines to be added: many many
