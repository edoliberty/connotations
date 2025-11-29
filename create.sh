pc auth login

# Create data
wget https://nlp.stanford.edu/data/wordvecs/glove.2024.wikigiga.50d.zip
unzip glove.2024.wikigiga.50d.zip wiki_giga_2024_50_MFT20_vectors_seed_123_alpha_0.75_eta_0.075_combined.txt
cat wiki_giga_2024_50_MFT20_vectors_seed_123_alpha_0.75_eta_0.075_combined.txt | python glove_to_jsonl.py | gzip > word-embeddings.jsonl.gz

# Delete unneeded files 
rm wiki_giga_2024_50_MFT20_vectors_seed_123_alpha_0.75_eta_0.075_combined.txt glove.2024.wikigiga.50d.zip

# Create index
pc index create --name word-embeddings -d 50 -m cosine --cloud "aws" --region "us-east-1"

# Upload data
cat word-embeddings.jsonl.gz | gunzip | pc index vector upsert --index-name word-embeddings --timeout 30m --body -
