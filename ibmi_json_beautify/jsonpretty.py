import json
import sys

parsed = json.loads(sys.argv[1])
print(json.dumps(parsed, indent=4, sort_keys=True))