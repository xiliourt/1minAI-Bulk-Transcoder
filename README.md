# Instructions
1. Update your API_KEY in both uploadAssets.sh and transcibe.sh
2. Run ./uploadAssets.sh in the folder with your mp3 files, generates "assets.txt"
3. Run ./transcribe.sh to transcribe all files in "assets.txt"

You now have all lyrics as "Song - Name.txt". 

Note they're one long string, I use gemini to make it into formatted lyrics, I prompt it via CLI with 
```
For every .txt file, format it as song lyrics then output to output/filename.txt
```


## Assets.txt format (incorrect json, enough that jq likes it)
```
{
  "key": "documents/2025_08_09_19_21_53_476_example.mp3",
  "songname": "example.mp3"
}
{
  "key": "documents/2025_08_09_19_23_12_444_example.mp3",
  "songname": "example.mp3"
}
```

