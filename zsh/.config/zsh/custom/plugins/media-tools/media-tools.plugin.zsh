yt-dl () {
  # VARS
  ARGS=()
  DOWNLOADER="aria2c"
  COOKIES="$HOME/Downloads/cookies.txt"
  FORMAT="(bestvideo[vcodec^=av01][height>=4320][fps>30]/bestvideo[vcodec^=vp09.02][height>=4320][fps>30]/bestvideo[vcodec^=vp09.00][height>=4320][fps>30]/bestvideo[vcodec^=vp9][height>=4320][fps>30]/bestvideo[vcodec^=avc1][height>=4320][fps>30]/bestvideo[height>=4320][fps>30]/bestvideo[vcodec^=av01][height>=4320]/bestvideo[vcodec^=vp09.02][height>=4320]/bestvideo[vcodec^=vp09.00][height>=4320]/bestvideo[vcodec^=vp9][height>=4320]/bestvideo[vcodec^=avc1][height>=4320]/bestvideo[height>=4320]/bestvideo[vcodec^=av01][height>=2880][fps>30]/bestvideo[vcodec^=vp09.02][height>=2880][fps>30]/bestvideo[vcodec^=vp09.00][height>=2880][fps>30]/bestvideo[vcodec^=vp9][height>=2880][fps>30]/bestvideo[vcodec^=avc1][height>=2880][fps>30]/bestvideo[height>=2880][fps>30]/bestvideo[vcodec^=av01][height>=2880]/bestvideo[vcodec^=vp09.02][height>=2880]/bestvideo[vcodec^=vp09.00][height>=2880]/bestvideo[vcodec^=vp9][height>=2880]/bestvideo[vcodec^=avc1][height>=2880]/bestvideo[height>=2880]/bestvideo[vcodec^=av01][height>=2160][fps>30]/bestvideo[vcodec^=vp09.02][height>=2160][fps>30]/bestvideo[vcodec^=vp09.00][height>=2160][fps>30]/bestvideo[vcodec^=vp9][height>=2160][fps>30]/bestvideo[vcodec^=avc1][height>=2160][fps>30]/bestvideo[height>=2160][fps>30]/bestvideo[vcodec^=av01][height>=2160]/bestvideo[vcodec^=vp09.02][height>=2160]/bestvideo[vcodec^=vp09.00][height>=2160]/bestvideo[vcodec^=vp9][height>=2160]/bestvideo[vcodec^=avc1][height>=2160]/bestvideo[height>=2160]/bestvideo[vcodec^=av01][height>=1440][fps>30]/bestvideo[vcodec^=vp09.02][height>=1440][fps>30]/bestvideo[vcodec^=vp09.00][height>=1440][fps>30]/bestvideo[vcodec^=vp9][height>=1440][fps>30]/bestvideo[vcodec^=avc1][height>=1440][fps>30]/bestvideo[height>=1440][fps>30]/bestvideo[vcodec^=av01][height>=1440]/bestvideo[vcodec^=vp09.02][height>=1440]/bestvideo[vcodec^=vp09.00][height>=1440]/bestvideo[vcodec^=vp9][height>=1440]/bestvideo[vcodec^=avc1][height>=1440]/bestvideo[height>=1440]/bestvideo[vcodec^=av01][height>=1080][fps>30]/bestvideo[vcodec^=vp09.02][height>=1080][fps>30]/bestvideo[vcodec^=vp09.00][height>=1080][fps>30]/bestvideo[vcodec^=vp9][height>=1080][fps>30]/bestvideo[vcodec^=avc1][height>=1080][fps>30]/bestvideo[height>=1080][fps>30]/bestvideo[vcodec^=av01][height>=1080]/bestvideo[vcodec^=vp09.02][height>=1080]/bestvideo[vcodec^=vp09.00][height>=1080]/bestvideo[vcodec^=vp9][height>=1080]/bestvideo[vcodec^=avc1][height>=1080]/bestvideo[height>=1080]/bestvideo[vcodec^=av01][height>=720][fps>30]/bestvideo[vcodec^=vp09.02][height>=720][fps>30]/bestvideo[vcodec^=vp09.00][height>=720][fps>30]/bestvideo[vcodec^=vp9][height>=720][fps>30]/bestvideo[vcodec^=avc1][height>=720][fps>30]/bestvideo[height>=720][fps>30]/bestvideo[vcodec^=av01][height>=720]/bestvideo[vcodec^=vp09.02][height>=720]/bestvideo[vcodec^=vp09.00][height>=720]/bestvideo[vcodec^=vp9][height>=720]/bestvideo[vcodec^=avc1][height>=720]/bestvideo[height>=720]/bestvideo[vcodec^=av01][height>=480][fps>30]/bestvideo[vcodec^=vp09.02][height>=480][fps>30]/bestvideo[vcodec^=vp09.00][height>=480][fps>30]/bestvideo[vcodec^=vp9][height>=480][fps>30]/bestvideo[vcodec^=avc1][height>=480][fps>30]/bestvideo[height>=480][fps>30]/bestvideo[vcodec^=av01][height>=480]/bestvideo[vcodec^=vp09.02][height>=480]/bestvideo[vcodec^=vp09.00][height>=480]/bestvideo[vcodec^=vp9][height>=480]/bestvideo[vcodec^=avc1][height>=480]/bestvideo[height>=480]/bestvideo[vcodec^=av01][height>=360][fps>30]/bestvideo[vcodec^=vp09.02][height>=360][fps>30]/bestvideo[vcodec^=vp09.00][height>=360][fps>30]/bestvideo[vcodec^=vp9][height>=360][fps>30]/bestvideo[vcodec^=avc1][height>=360][fps>30]/bestvideo[height>=360][fps>30]/bestvideo[vcodec^=av01][height>=360]/bestvideo[vcodec^=vp09.02][height>=360]/bestvideo[vcodec^=vp09.00][height>=360]/bestvideo[vcodec^=vp9][height>=360]/bestvideo[vcodec^=avc1][height>=360]/bestvideo[height>=360]/bestvideo[vcodec^=avc1][height>=240][fps>30]/bestvideo[vcodec^=av01][height>=240][fps>30]/bestvideo[vcodec^=vp09.02][height>=240][fps>30]/bestvideo[vcodec^=vp09.00][height>=240][fps>30]/bestvideo[vcodec^=vp9][height>=240][fps>30]/bestvideo[height>=240][fps>30]/bestvideo[vcodec^=avc1][height>=240]/bestvideo[vcodec^=av01][height>=240]/bestvideo[vcodec^=vp09.02][height>=240]/bestvideo[vcodec^=vp09.00][height>=240]/bestvideo[vcodec^=vp9][height>=240]/bestvideo[height>=240]/bestvideo[vcodec^=avc1][height>=144][fps>30]/bestvideo[vcodec^=av01][height>=144][fps>30]/bestvideo[vcodec^=vp09.02][height>=144][fps>30]/bestvideo[vcodec^=vp09.00][height>=144][fps>30]/bestvideo[vcodec^=vp9][height>=144][fps>30]/bestvideo[height>=144][fps>30]/bestvideo[vcodec^=avc1][height>=144]/bestvideo[vcodec^=av01][height>=144]/bestvideo[vcodec^=vp09.02][height>=144]/bestvideo[vcodec^=vp09.00][height>=144]/bestvideo[vcodec^=vp9][height>=144]/bestvideo[height>=144]/bestvideo)+(bestaudio[acodec^=opus]/bestaudio)/best"
  # Add default args
  ARGS+=(
    "--external-downloader" "$DOWNLOADER"
    "--format" "$FORMAT"
    "--output" "%(uploader)s - %(upload_date)s - %(title)s [%(id)s].%(ext)s"
    "--verbose"
    "--force-ipv4"
    "--ignore-errors"
    "--no-overwrites"
    "--embed-metadata"
    "--embed-subs"
    "--embed-thumbnail"
    "--download-archive" "archive.log"
    "--parse-metadata" "%(tags|)s:%(meta_genre)s" # set genre to tags (if there)
    "--parse-metadata" "%(uploader|)s:%(meta_artist)s" # prioritize uploader as artist
    "--parse-metadata" ":(?P<meta_synopsis>)" # ignore synopsis (this is almost always a duplicate of description)
    "--sub-langs" "all,-live_chat"
    "--check-formats"
    "--concurrent-fragments" "5"
    "--merge-output-format" "mkv"
    "--throttled-rate" "100K"
    "--cookies-from-browser" "vivaldi"
  )

  # add cookies if the file exists
  if [ -f "$COOKIES" ]; then
    ARGS+=("--cookies" "$COOKIES")
  fi

  # fall back to todo.txt as a batch file when no URLs were passed
  if [ $# -eq 0 ]; then
    echo "No arguments passed; looking for a todo.txt batch file..."
    if [ -f "todo.txt" ] && [[ "$(head -n 1 todo.txt)" =~ ^https?:// ]]; then
      echo "Found todo.txt; adding '--batch-file todo.txt' to command arguments"
      ARGS+=("--batch-file" "todo.txt")
    else
      echo "Warning: no todo.txt found in working directory"
    fi
  fi

  # run the command
  yt-dlp "${ARGS[@]}" "$@"
}

makemkv-update-keydb () {
  local makemkv_home="$HOME/Library/MakeMKV"
  local tmpdir
  tmpdir=$(mktemp -d)

  echo "Downloading latest sdf.bin..."
  curl -\#L -z "$makemkv_home/sdf.bin" -o "$makemkv_home/sdf.bin" "https://www.makemkv.com/svq/sdf.bin"

  echo "Downloading latest FindVUK Online Database..."
  local archive="$tmpdir/keydb_eng.zip"
  curl -\#L -z "$makemkv_home/keydb.cfg" -o "$archive" "http://fvonline-db.bplaced.net/fv_download.php?lang=eng"

  if [ -e "$archive" ]; then
    echo "Unzipping..."
    if ! unzip -o -j "$archive" keydb.cfg -d "$makemkv_home" ; then
      echo "ERROR: could not extract keydb.cfg from archive"
      return 1
    fi
    chmod 644 "$makemkv_home/keydb.cfg"
  fi

  rm -rf "$tmpdir"
}

mkvsetdefaultlang () {
  # Check if the correct number of arguments is provided
  if [[ $# -lt 3 ]]; then
    print -rC1 -- \
      "Usage: $0 <language> <codec> <file1.mkv> [<file2.mkv> ...]"
    return
  fi

  local language=$1
  shift
  local codec=$1
  shift

  # Loop through each file provided
  for file in "$@"; do
    # Check if the file exists
    if [[ -f "$file" ]]; then
      echo "Processing '$file'..."
      metadata="$(mkvmerge -J "$file")"

      # Check if there are audio tracks
      audio_tracks=("${(f)$(yq -e '.tracks | filter(.type=="audio") | .[]' <<<"$metadata")}")
      if [[ ${#audio_tracks[@]} -eq 0 ]]; then
          echo "No audio tracks found in '$file'."
          continue
      fi

      # Check of the language exists
      languages=("${(f)$(yq -e '.tracks | filter(.type=="audio") | [.[].properties.language] | unique | .[]' <<<"$metadata")}")
      if [[ $languages[(Ie)$language] -eq 0 ]]; then
        echo "No audio track for language '$language' found in '$file' (found: [${(j:,:)languages}])."
        continue
      fi

      # Set the default flag for each audio track
      for track in "${audio_tracks[@]}"; do
        default=0
        track_id="$(yq -e '.properties.number' <<<"$track")"
        track_lang="$(yq -e '.properties.language' <<<"$track")"
        track_codec="$(yq -e '.codec' <<<"$track")"
        if [[ "$track_lang" == "$language" && "$track_codec" == "$codec" ]]; then
          default=1
        fi
        mkvpropedit "$file" --quiet --edit track:@$track_id --set flag-default=$default
        echo "Track $track_id ($track_lang $track_codec): set flag-default=$default"
      done
    else
      echo "File '$file' does not exist."
    fi
  done
}

mkvlistmuxers () {
  # Check if the correct number of arguments is provided
  if [[ $# -ne 2 ]]; then
    print -rC1 -- \
      "Usage: $0 DIRECTORY OUTPUT_FILE"
    return
  fi

  local dir=$1
  local output=$2

  echo "Finding files"
  files=$(mktemp)
  find "$1" -name '*.mkv' > $files

  echo "Extracting data"
  data=$(mktemp)
  parallel --bar -j 8 mkvmerge -J {} "|" jq -r "'\"\(.container.properties.title);\(.container.properties.muxing_application)\"'" > "$data" < "$files"

  column -s \; -t $data | tee "$output"
}
