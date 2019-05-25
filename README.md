# RISC-V Compliance Framework
The work here is under development and is not stable for consumption .. yet!

## Documentation
You can find the latest documentation of the work: [here](https://riscof.readthedocs.io/en/latest/)

## Setup
```
sudo apt-get install python3 pip3
pip3 intall -r requirements.txt
```

## Usage
```
python3 -m rips.main --help
python3 -m framework.main --help
```

## Example 
```
python3 -m rips.main --input Examples/eg1.yaml --schema rips/schema.yaml --verbose info
python3 -m framework.main --input Examples/eg1_checked.yaml --verbose info
```

