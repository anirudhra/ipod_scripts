#!/bin/bash
# (c) Anirudh Acharya 2025
# Script to generate M3U playlists from iTunes Library XML file
# and modify paths within them to replace local paths with NAS/iPod/relative paths

if ! command -v perl &> /dev/null; then
  echo "Error: perl is not installed. Please install it to continue." >&2
  exit 1
fi

export LC_ALL=C

# global defaults
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
current_library_hash=""

# Function declarations
# Function declarations
check_if_playlists_current() {
  local library_xml="$1"
  local playlists_dir="$2"
  local hash_file="${playlists_dir}/library.hash"
  local hash_program=""

  # Find available hash program
  if command -v sha256sum >/dev/null 2>&1; then
    hash_program="sha256sum"
  elif command -v shasum >/dev/null 2>&1; then
    hash_program="shasum -a 256"
  else
    return 1  # Can't check without a hash program
  fi

  # Compute current hash and store it globally
  current_library_hash=$($hash_program "$library_xml" | cut -d' ' -f1)

  # Check if hash file exists
  [ ! -f "$hash_file" ] && return 1

  # Check if any .m3u files exist
  [ "$(find "$playlists_dir" -name '*.m3u' | wc -l)" -eq 0 ] && return 1

  # Compare current and saved hashes
  local saved_hash=$(cat "$hash_file")
  [ "$current_library_hash" = "$saved_hash" ] || return 1

  return 0  # All checks passed
}

# Function to detect OS-specific itunesexport binary
detect_itunesexport_bin() {
  # Return path to platform-specific itunesexport binary located next to script
  local bin="${script_dir}/itunesexport_linux"
  case "$(uname -s)" in
    Darwin)
      bin="${script_dir}/itunesexport_macos"
      ;;
    Linux|*BSD|SunOS|AIX)
      bin="${script_dir}/itunesexport_linux"
      ;;
    CYGWIN*|MINGW*|MSYS*|Windows_NT)
      echo "Error: This script is only supported on macOS, Linux, or Unix-like systems." >&2
      exit 1
      ;;
    *)
      bin="${script_dir}/itunesexport_linux"
      ;;
  esac

  printf '%s\n' "${bin}"
}

# Function to detect iTunes media source path
detect_itunes_source_uri() {
  local xmlpath="${ituneslibraryxml}"
  local result=""

  if [ -n "${xmlpath}" ] && [ -f "${xmlpath}" ]; then
    # Extract the <string> that follows <key>Music Folder</key>
    raw=$(grep '<key>Music Folder</key>' "${xmlpath}" \
      | sed -n 's:.*<string>\(.*\)</string>.*:\1:p' | tr -d '\r')

    if [ -n "${raw}" ]; then
      # If it's already a file:// URI, just ensure spaces are percent-encoded
      if echo "${raw}" | grep -q '^file://'; then
        result=$(echo "${raw}" | sed 's/ /%20/g')
      else
        # If it contains backslashes (Windows path), convert to URI
        if echo "${raw}" | grep -q '\\\\'; then
          winpath=$(echo "${raw}" | sed 's|\\\\|/|g')
          winpath=$(echo "${winpath}" | sed 's|^\([A-Za-z]\):|/\1:|')
          result=$(echo "file://${winpath}" | sed 's/ /%20/g')
        else
          # Otherwise assume a POSIX filesystem path
          result=$(echo "file://${raw}" | sed 's/ /%20/g')
        fi
      fi
    fi
  fi

  # Fallback heuristics if XML not present or key missing (Unix-like only).
  if [ -z "${result}" ]; then
    basepath="${music_base:-${HOME}/Music}"
    if [ -d "${basepath}/MusicLibrary" ]; then
      result="file://${basepath}/MusicLibrary"
    else
      itunes_path=$(echo "${basepath}/iTunes/iTunes Media/Music" | sed 's| |%20|g')
      result="file://${itunes_path}"
    fi
  fi

  echo "${result}"
}

# Function to replace paths and clean up playlists
do_path_replace_and_cleanup() {
  playlistdir="$1"
  dst_path="$2"

  # Array of playlist files to remove
  files_to_remove=(
    "Tones.m3u"
    "Music.m3u"
    "Downloaded.m3u"
    #"Podcasts.m3u"
    "Movies.m3u"
    "TV Shows.m3u"
    #"Audiobooks.m3u"
    "Dead Tracks.m3u"
  )
  # remove unwanted playlists
  for f in "${files_to_remove[@]}"; do
    if [ -e "$playlistdir/$f" ]; then
      rm "$playlistdir/$f"
    fi
  done

  # rename Library.m3u to Full Library.m3u (operate on full paths, don't cd)
  if [ -e "$playlistdir/Library.m3u" ]; then
    mv "$playlistdir/Library.m3u" "$playlistdir/Full Library.m3u"
  fi

  # now replace paths in playlist files without changing cwd
  src_path_raw="${sourcepathstring:-}"

  src_path_decoded=$(urldecode "$src_path_raw")

  for fpath in "$playlistdir"/*.m3u; do
    [ -f "$fpath" ] || continue
    # Use perl for robust in-place replacement.
    # \Q...\E treats the content as literal, avoiding issues with special characters.
    perl -i -pe "s#^.*\Q${src_path_decoded}\E#${dst_path}#g" "$fpath"
  done
}

# Function to URL decode strings
urldecode() {
  # Use perl to URL decode the string
  perl -pe 's/%([0-9a-fA-F]{2})/chr hex $1/ge' <<< "$1"
}

usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -p PLAYLISTSBASEDIR      Base directory for ituneslibraryxml, converted & backed up playlists (default: OS-dependent)"
  echo "  -l ITUNESLIBRARYXML      Path to iTunes Library XML file (default: \${PLAYLISTSBASEDIR}/library/Library.xml)"
  echo "  -s SOURCEPATHSTRING      Source path string (default: OS-dependent)"
  echo "  -d DESTINATIONPATHSTRING Destination path string (default: ../music)"
  echo "  -b                       Backup existing playlists before generating new ones (disabled by default)"
  echo "  -f                       Force run even if playlists are up to date"
  echo "  -c                       Cleanup only mode (path replace on existing .m3u files, no iTunes export)"
  echo "  -h                       Show this help message and exit"
  exit 1
}
# default music base (moved into main defaults)
music_base="${HOME}/Music"

# Detect platform-specific itunesexport binary and validate
itunesexport_bin="$(detect_itunesexport_bin)"
if [ -z "${itunesexport_bin}" ]; then
  echo "Error: itunesexport binary path is empty (detect_and_prepare_os_info failed)" >&2
  exit 1
fi
if [ ! -f "${itunesexport_bin}" ]; then
  echo "Error: itunesexport binary not found: ${itunesexport_bin}" >&2
  exit 1
fi
if [ ! -x "${itunesexport_bin}" ]; then
  chmod +x "${itunesexport_bin}" 2>/dev/null || {
    echo "Error: itunesexport binary is not executable and chmod failed: ${itunesexport_bin}" >&2
    exit 1
  }
fi

# Set default values for options
playlistsbasedir="${music_base}/Playlists"
sourcepathstring="" # do not set any defaults as there is an empty detection later
destinationpathstring="../music/"
ituneslibraryxml=""
backup_playlists=0
force_run=0
cleanup_only=0

while getopts "p:l:s:d:bfch" opt; do
  case $opt in
    p) playlistsbasedir="$OPTARG" ;;
    l) ituneslibraryxml="$OPTARG" ;;
    s) sourcepathstring="$OPTARG" ;;
    d) destinationpathstring="$OPTARG" ;;
    b) backup_playlists=1 ;;
    f) force_run=1 ;;
    c) cleanup_only=1 ;;
    *) usage ;;
  esac
done

# Set default values for paths that depend on playlistsbasedir or other options
if [ -z "${ituneslibraryxml}" ]; then
  ituneslibraryxml="${playlistsbasedir}/library/Library.xml"
fi
if [ ! -e "${ituneslibraryxml}" ]; then
  echo "No iTunes Library found in ${ituneslibraryxml}!"
  exit 1
fi
# If source path string wasn't provided on the command line, try to detect
# it now from the itunes library XML (uses detect_itunes_source_uri which
# uses the global ${ituneslibraryxml}). Place this immediately after
# ${ituneslibraryxml} is finalized.
if [ -z "${sourcepathstring}" ]; then
  sourcepathstring=$(detect_itunes_source_uri)
fi

# Destination directories
convertedplaylistsdir="${playlistsbasedir}/playlists"
existingplaylistsbackupdir="${playlistsbasedir}/playlists_backup"

# Early exit if playlists are up to date
if [ "$force_run" -eq 0 ] && check_if_playlists_current "${ituneslibraryxml}" "${convertedplaylistsdir}"; then
  echo "Playlists are up-to-date (Library.xml hash matches and .m3u files exist)"
  echo "Use -f to force regeneration of playlists"
  exit 0
elif [ "$force_run" -eq 1 ]; then
  echo "Force mode (-f) enabled: will regenerate playlists even if up-to-date"
fi

# Create playlistsbasedir if it doesn't exist
if [ ! -d "${playlistsbasedir}" ]; then
  mkdir -p "${playlistsbasedir}"
fi

if [ "$cleanup_only" -eq 0 ]; then
  # create temporary directory for export
  tempplaylistsdir=$(mktemp -d "${playlistsbasedir}/playlists.temp.XXXXXX")
  trap "rm -rf ${tempplaylistsdir}" EXIT

  # export xml to m3u in temporary directory
  itunes_cmd=("${itunesexport_bin}" -library "${ituneslibraryxml}" -output "${tempplaylistsdir}" -includeAllWithBuiltin)

  "${itunes_cmd[@]}" || {
    echo "Error: Failed to export playlists from iTunes Library XML using ${itunesexport_bin}"
    exit 1
  }

  # Store a quoted form of the command for inclusion in the summary
  quoted_itunes_cmd=$(printf '%q ' "${itunes_cmd[@]}")

  # change paths and cleanup in temporary directory
  do_path_replace_and_cleanup "$tempplaylistsdir" "$destinationpathstring" || {
    echo "Error: Failed to process playlists"
    exit 1
  }

  # Only commit if export and processing were successful
  # make backup of existing playlists if backup option is enabled
  if [ "$backup_playlists" -eq 1 ]; then
    if [ -d "${convertedplaylistsdir}" ]; then
      rm -rf "${existingplaylistsbackupdir}"
      mv "${convertedplaylistsdir}" "${existingplaylistsbackupdir}"
    fi
  fi

  # copy from temporary directory to final location
  mkdir -p "${convertedplaylistsdir}"
  cp -r "${tempplaylistsdir}"/* "${convertedplaylistsdir}" || {
    echo "Error: Failed to copy playlists to destination location"
    exit 1
  }

  # Count .m3u files copied to the converted playlists directory for the summary
  m3u_count=0
  if [ -d "${convertedplaylistsdir}" ]; then
    # find returns zero even if no matches; wc -l will be 0 in that case
    m3u_count=$(find "${convertedplaylistsdir}" -type f -name '*.m3u' | wc -l)
  fi

  # Cleanup temporary directory after successful completion
  rm -rf "${tempplaylistsdir}"
  trap - EXIT
else
  # cleanup only mode
  echo "Cleanup only mode enabled: skipping iTunes export and processing existing .m3u files."
  do_path_replace_and_cleanup "${convertedplaylistsdir}" "$destinationpathstring" || {
    echo "Error: Failed to process playlists"
    exit 1
  }
  m3u_count=0
  if [ -d "${convertedplaylistsdir}" ]; then
    m3u_count=$(find "${convertedplaylistsdir}" -type f -name '*.m3u' | wc -l)
  fi
fi

echo
echo "=============== Summary ==============="
echo
if [ "$cleanup_only" -eq 0 ]; then
  echo "iTunes playlist export command used: ${quoted_itunes_cmd}"
  echo
fi
echo "Directories created/modified:"
echo "  - Converted playlists saved to: ${convertedplaylistsdir}"
if [ "$backup_playlists" -eq 1 ] && [ -d "${existingplaylistsbackupdir}" ]; then
  echo "  - Existing playlists backuped up to: ${existingplaylistsbackupdir}"
fi
echo
echo "Path strings modified in converted playlists:"
echo "  - Source path: ${sourcepathstring}"
echo "  - Destination path: ${destinationpathstring}"
echo
if [ "$cleanup_only" -eq 0 ]; then
  echo "iTunes Library XML used: ${ituneslibraryxml}"

  # Save hash of current library
  if [ -n "${current_library_hash}" ]; then
    echo "${current_library_hash}" > "${convertedplaylistsdir}/library.hash"
    echo "  - iTunes Library XML hash saved to: ${convertedplaylistsdir}/library.hash"
  fi
  echo "Playlists generated: ${m3u_count} .m3u files"
echo
echo "All Done!"
echo
else
  echo "Playlists processed: ${m3u_count} .m3u files"
  echo
  echo "All Done!"
  echo
fi
