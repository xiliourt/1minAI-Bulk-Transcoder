# Instructions
1. Run uploadAssets.sh in the folder with your mp3 files, generates "assets.txt"
2. Run transcribe.sh to transcribe all files in "assets.txt"
    a. Results are output to songname.txt for every 'asset'


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

I found gemini was best at then turning all the files into song lyrics, rather than a single long string.
