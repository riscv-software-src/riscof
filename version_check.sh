#!/bin/bash
export CHNGVER=$(grep -P "^## \[.*?\]" CHANGELOG.md -m1 | awk '{print $2}' |awk '{print $1}'| sed 's/[][]//g'); 
echo "CHANGELOG VERSION: $CHNGVER"
export INITVER=$(grep -P "__version__ = '.*?'" riscof/__init__.py | awk '{print $3}'|sed "s/'//g"); 
echo "INIT VERSION: $INITVER"
export PYPIVER=$(pip search riscof | grep -P "riscof (.*?)" | awk '{print $2}' | sed 's/(//g'| sed 's/)//g')
echo "PYPI VERSION: $PYPIVER" 
if [ "$CHNGVER" = "$INITVER" ]; then
    echo "Versions are equal in Changelog and init.py."
else
    echo "Versions are not equal in Changelog and init.py."
    exit 1
fi
if [ "$PYPIVER" = "$CHNGVER" ]; then
    echo "Version matches PyPi version and needs to be updated"
    exit 1
else 
    echo "Versions have been updated and ready for push"
fi
