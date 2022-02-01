import json
import sys

with open(sys.argv[1], "r") as read_file:
    g_jsonData = json.load(read_file)
    PrettyJson = json.dumps(g_jsonData, indent=4, separators=(',', ': '), sort_keys=True)
    print(PrettyJson)
