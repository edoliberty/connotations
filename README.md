
# Connotations

We will build a little game that, given a word in English, prints out some associations for that word. This is more of a fun way to learn about Pinecone's CLI than an actual game...


## Install the Pinecone CLI
if you don't yet have the Pinecone CLI, shame on you...

```sh
curl -fsSL https://pinecone.io/install.sh | sh
```

## Get the repo

You really need only the two python scripts, the rest are just bash commands in this readme.
```sh
git clone https://github.com/edoliberty/connotations.git
cd connotations
```

## Creating your index

Make sure your client is authenticated

```sh
pc login
```

Create an index for the [glove dataset](https://nlp.stanford.edu/projects/glove/)

```sh
pc index create --name glove -d 50 -m cosine --cloud "aws" --region "us-east-1"
```

Check that your index is ready. Create is an async call, an index might take a minute to be ready.
```sh
pc index describe --name glove
```


## Ingesting data

Download the glove dataset. This might take some time.

```sh
wget -nc https://nlp.stanford.edu/data/wordvecs/glove.2024.wikigiga.50d.zip
unzip glove.2024.wikigiga.50d.zip wiki_giga_2024_50_MFT20_vectors_seed_123_alpha_0.75_eta_0.075_combined.txt
cat wiki_giga_2024_50_MFT20_vectors_seed_123_alpha_0.75_eta_0.075_combined.txt | python glove_to_jsonl.py | gzip > glove.jsonl.gz
```

Now the file `glove.jsonl.gz` contains word embeddings in dimension 50 in jsonl. You can now delete the source files. They are no longer needed. 
```sh
rm glove.2024.wikigiga.50d.zip
rm wiki_giga_2024_50_MFT20_vectors_seed_123_alpha_0.75_eta_0.075_combined.txt
```


Upsert the data into your new index

```sh
cat glove.jsonl.gz | gunzip | pc index vector upsert --index-name glove --timeout 30m --file -
```

Note that we set ```--timeout 30m``` to give the client (more than) enough time to upload the 1,000,000 records.


## Searching for connotations

We are now ready to play the connotations game!
Since the `id` for each vector is the word itself, we can use the [search by record id](https://docs.pinecone.io/guides/search/semantic-search#search-with-a-record-id) mechanism to find similar words.

```sh
pc index vector query --index-name glove --id "coconut" --top-k 10
```

```text
Namespace: __default__
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

## Searching for analogies

Who has not seen the ["queen - king + man = woman"](https://www.technologyreview.com/2015/09/17/166211/king-man-woman-queen-the-marvelous-mathematics-of-computational-linguistics/) meme? It has become 
the cliche example for what embeddings are and why they are interesting or useful. 

While embeddings really are very interesting and useful, "semantic vector math" [doesn't work](https://mikexcohen.substack.com/p/king-man-woman-queen-is-fake-news) as-advertized in general. 
The point of this demo isn't to pitch "queen - king + man = woman" but rather to learn how to use Pinecone's new and versatile CLI. 

Here, just for fun, let's try to reproduce that...

Let's start with fetching the embedding vectors for those words:
```sh
pc index vector fetch --index-name glove --ids '["queen","king","man"]' --json > vectors.json
cat vectors.json | python vector_math.py '["queen","king","man"]' > query_vector.json
cat query_vector.json | pc index vector query --index-name glove -v -
```

Which gives:
```text
Namespace: __default__
Usage: 1 (read units)
ID          SCORE
woman       0.884853
girl        0.876178
man         0.836099
boy         0.828002
her         0.797578
she         0.781111
blonde      0.779127
stranger    0.763405
naked       0.760872
herself     0.759408
```

Hurray!

## Cleanup
To delete your index use:
```sh
pc index delete --name glove
```








