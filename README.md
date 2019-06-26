# RISC-V Compliance Framework
The work here is under development and is not stable for consumption .. yet!

## Documentation
You can find the latest documentation of the work: [here](https://riscof.readthedocs.io/)

Sample command for riscof

Spike vs Spike
```
python -m riscof.main -bm model_from_yaml -bf Examples/template_env.yaml -eyaml Examples/template_env.yaml -dm model_from_yaml -ispec Examples/rv32i_isa.yaml -pspec Examples/rv32i_platform.yaml --verbose debug


```

Eclass vs Spike
```
python -m riscof.main -bm model_from_yaml -bf Examples/template_env.yaml -dm model_from_yaml -ispec Examples/rv32i_isa.yaml -pspec Examples/rv32i_platform.yaml -eyaml Examples/e_class_env.yaml --verbose debug

```

dbgen
```
python -m riscof.dbgen

```