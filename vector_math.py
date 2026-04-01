import sys, json
import numpy as np

words = json.loads(sys.argv[1])
res = json.load(sys.stdin)

vecs = np.array([res["vectors"][w]["values"] for w in words]) 
json.dump(list(round(x,3) for x in vecs[0]-vecs[1]+vecs[2]), sys.stdout)