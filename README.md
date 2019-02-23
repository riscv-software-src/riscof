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

