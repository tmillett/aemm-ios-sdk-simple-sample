import json
import base64

assets = []
size = 100000000
with open('/Users/tmillett/Library/Mobile Documents/com~apple~CloudDocs/images.txt') as fp:
    for line in fp:
    	dict = {}
    	dict['url'] = line.strip()
    	dict['localPath'] = base64.b64encode(line)
    	dict['length'] = size
    	size = size + 1
    	assets.append(dict)
manifest = {}
manifest['assets'] = assets
str = json.dumps(manifest, sort_keys=True, indent=4, separators=(',', ': '))
print str