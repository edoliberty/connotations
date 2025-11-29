
# Connotations

We will build a little game that, given a word in English, prints out some associations for that word. This is more of a fun way to learn about Pinecone's CLI than an actual game...

## Data prep

First, download the glove dataset that we'll use for this.

```
$ wget https://nlp.stanford.edu/data/wordvecs/glove.2024.wikigiga.50d.zip
$ unzip glove.2024.wikigiga.50d.zip wiki_giga_2024_50_MFT20_vectors_seed_123_alpha_0.75_eta_0.075_combined.txt
$ cat wiki_giga_2024_50_MFT20_vectors_seed_123_alpha_0.75_eta_0.075_combined.txt | python glove_to_jsonl.py | gzip > word-embeddings.jsonl.gz
```

Now the file ```word-embeddings.jsonl.gz``` contains 1,000,000 word embeddings in dimension 50 in json. You can look at it like this:

```
$ cat word-embeddings.jsonl.gz | gunzip | head -n 2
{"id": "the", "values": [-0.383, -0.481, -0.274, 0.133, 0.065, -0.092, -0.003, 0.169, 0.428, 0.032, 0.601, 0.005, 0.222, -0.107, 0.34, -0.248, -0.066, 0.165, -0.099, -0.267, -0.352, -0.596, -0.748, -0.262, -0.4, 0.306, 0.132, 0.15, -0.463, 0.436, -0.328, -0.112, -0.318, -0.586, -0.242, -0.383, -0.434, 5.955, 0.137, -0.065, 0.457, -0.019, 0.261, -0.294, 0.199, 0.278, 0.165, 0.406, -0.228, -0.4]}
{"id": "of", "values": [0.081, 0.385, -0.479, -0.27, -0.266, 0.104, -0.102, -0.053, 0.138, -0.137, 1.009, -0.205, 0.21, 0.395, 0.45, -0.306, 0.219, 0.818, -0.343, -0.416, -0.734, -0.102, -0.512, -0.483, 0.477, 0.272, 0.482, 0.01, -0.313, 0.669, -0.353, -0.076, 0.423, -0.454, -0.458, 0.177, 0.421, 5.71, -0.298, -0.046, 0.155, -0.251, -0.061, 0.289, 0.193, 0.206, -0.306, 0.318, -0.081, -0.376]}
```


## Creating your index

Make sure your client is authenticated

```
$ pc auth login
```

Create an index

```
$ pc index create --name word-embeddings -d 50 -m cosine --cloud "aws" --region "us-east-1"
```

Upsert the data into your new index

```
$ cat word-embeddings.jsonl.gz | gunzip | pc index vector upsert --index-name word-embeddings --namespace words --timeout 30m --body -
```

Note that we see ```--timeout 30m``` to give the client enough time to upload the 1,000,000 records.

## Play the game

We are now ready to play the connotations game!

```
$ pc index vector query --index-name word-embeddings --namespace words --id "coconut" --top-k 10

Namespace: words
Usage: 1 (read units)
ID           SCORE
coconut      0.997997
pineapple    0.878928
mango        0.832396
banana       0.821444
sugar        0.804870
almond       0.802615
guava        0.799427
dried        0.798168
juice        0.790972
lemon        0.788639
```