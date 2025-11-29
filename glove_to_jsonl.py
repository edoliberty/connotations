import sys
import string
import json

d = 50
n = 1_000_000
allowed_chars = set(string.ascii_lowercase + string.ascii_uppercase)
for i, line in enumerate(sys.stdin):
    try:
        parts = line.strip().split()
        word = parts[0]
        if not set(word).issubset(allowed_chars):
            continue
        values = [round(float(_),3) for _ in parts[-d:]]
        json_line = json.dumps( {"id":word, "values":values} )
        sys.stdout.write(f'{json_line}\n')
        if i >= n:
            break
    except:
        #sys.stderr.write(line)
        pass
