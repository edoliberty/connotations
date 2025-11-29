echo Enter q or use ^c to quit.
read -p "Enter a word: " word
while [[ $word !=  'q' ]]; do
  pc index vector query --index-name word-embeddings --id "$word" --top-k 10
  read -p "Enter a word: " word
done




