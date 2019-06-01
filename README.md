# RISC-V Compliance Framework
The work here is under development and is not stable for consumption .. yet!

## Documentation
You can find the latest documentation of the work: [here](https://riscof.readthedocs.io/en/latest/)

Sample command for framework (under development)

Spike vs Spike
```
python3 -m framework.main -bm model_from_yaml -bf Examples/template_env.yaml -df Examples/template_env.yaml -dm model_from_yaml -ispec Examples/template_isa_checked.yaml -pspec Examples/template_platform_checked.yaml --verbose debug

python3 -m framework.main -bm model_from_yaml -bf Examples/template_env_2.yaml -df Examples/template_env.yaml -dm model_from_yaml -ispec Examples/template_isa_checked.yaml -pspec Examples/template_platform_checked.yaml --verbose debug
```

Eclass vs Spike
```
python3 -m framework.main -bm model_from_yaml -bf Examples/template_env_2.yaml -df Examples/e_class_env.yaml -dm model_from_yaml -ispec Examples/template_isa_checked.yaml -pspec Examples/template_platform_checked.yaml --verbose debug

python3 -m framework.main -bm model_from_yaml -bf Examples/template_env.yaml -df Examples/e_class_env.yaml -dm model_from_yaml -ispec Examples/template_isa_checked.yaml -pspec Examples/template_platform_checked.yaml --verbose debug
```