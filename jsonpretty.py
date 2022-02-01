import json
import sys

with open(sys.argv[2], "r") as read_file:
    g_jsonData = json.load(read_file)
    if int(sys.argv[1]) > 0:
      PrettyJson = json.dumps(g_jsonData, indent=int(sys.argv[1]), separators=(',', ': '), sort_keys=True)
    else:
      PrettyJson = json.dumps(g_jsonData)
    print(PrettyJson)
