#!/bin/bash
# (c) Anirudh Acharya 2024
# Script to generate M3U playlists from iTunes Library XML file
#

usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -p PLAYLISTSBASEDIR      Base directory for ituneslibraryxml, converted & backed up playlists (default: OS-dependent)"
  echo "  -l ITUNESLIBRARYXML      Path to iTunes Library XML file (default: \${PLAYLISTSBASEDIR}/Library/Library.xml)"
  echo "  -s SOURCEPATHSTRING      Source path string (default: OS-dependent)"
  echo "  -d DESTINATIONPATHSTRING Destination path string (default: ../)"
  echo "  -b                       Backup existing playlists before generating new ones (disabled by default)"
  echo "  -h                       Show this help message and exit"
  exit 1
}

# Function to replace paths and clean up playlists
do_path_replace_and_cleanup() {
  playlistdir="$1"
  src_esc="$2"
  dst_esc="$3"

  cd "$playlistdir" || exit 1

  # Array of playlist files to remove
  files_to_remove=(
    "Tones.m3u"
    "Music.m3u"
    "Downloaded.m3u"
    "Dead Tracks.m3u"
  )
  # remove unwanted playlists
  for f in "${files_to_remove[@]}"; do
    rm "$playlistdir/$f"
  done

  # rename Library.m3u to Full Library.m3u
  mv "$playlistdir/Library.m3u" "$playlistdir/Full Library.m3u"

  # now replace paths in playlist files
  sed -i '' "s|$src_esc|$dst_esc|g" *
  cd -
}

# Detect OS-specific information and ensure the itunesexport binary is ready
detect_and_prepare_os_info() {
  local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local music_base="${HOME}/Music"
  local bin="${script_dir}/itunesexport_linux"

  # Centralized OS detection
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
      # Default to linux-style behavior for other Unix-like systems
      bin="${script_dir}/itunesexport_linux"
      ;;
  esac

  # Verify the binary exists
  if [ ! -f "${bin}" ]; then
    echo "Error: itunesexport binary not found: ${bin}" >&2
    exit 1
  fi

  # Ensure the binary is executable
  if [ ! -x "${bin}" ]; then
    chmod +x "${bin}" 2>/dev/null || {
      echo "Error: itunesexport binary is not executable and chmod failed: ${bin}" >&2
      exit 1
    }
  fi

  echo "${music_base}"
  echo "${bin}"
}

# Detect iTunes media source path as a file:// URI.
# Prefer reading the Library XML at ${playlistsbasedir}/Library/Library.xml and
# extracting the <key>Music Folder</key> <string>...</string> value. Fall back
# to heuristics if the XML or key isn't available.
detect_itunes_source_uri() {
  # Use the authoritative global ituneslibraryxml unconditionally. The main
  # flow already finalizes and validates ${ituneslibraryxml} before this is
  # called, so just read it directly.
  local xmlpath="${ituneslibraryxml}"

  if [ -n "${xmlpath}" ] && [ -f "${xmlpath}" ]; then
    # Extract the <string> that follows <key>Music Folder</key>
    raw=$(awk '/<key>Music Folder<\/key>/{getline; print}' "${xmlpath}" \
      | sed -n 's:.*<string>\(.*\)</string>.*:\1:p' | tr -d '\r')

    if [ -n "${raw}" ]; then
      # If it's already a file:// URI, just ensure spaces are percent-encoded
      if echo "${raw}" | grep -q '^file://'; then
        echo "${raw}" | sed 's/ /%20/g'
        return
      fi

      # If it contains backslashes (Windows path), convert to URI
      if echo "${raw}" | grep -q '\\\\'; then
        winpath=$(echo "${raw}" | sed 's|\\\\|/|g')
        winpath=$(echo "${winpath}" | sed 's|^\([A-Za-z]\):|/\1:|')
        echo "file://${winpath}" | sed 's/ /%20/g'
        return
      fi

      # Otherwise assume a POSIX filesystem path
      echo "file://${raw}" | sed 's/ /%20/g'
      return
    fi
  fi
  # Fallback heuristics if XML not present or key missing (Unix-like only).
  # Prefer a global music_base if already set; otherwise fall back to ${HOME}/Music.
  # Use the global music_base if available, else default to ${HOME}/Music
  basepath="${music_base:-${HOME}/Music}"

  if [ -d "${basepath}/MusicLibrary" ]; then
    echo "file://${basepath}/MusicLibrary"
  else
    local itunes_path=$(echo "${basepath}/iTunes/iTunes Media/Music" | sed 's| |%20|g')
    echo "file://${itunes_path}"
  fi
}

# Default values (OS-specific)
# Get music base and suggested itunesexport binary (and ensure it's ready)
read -r music_base itunesexport_bin < <(detect_and_prepare_os_info)
playlistsbasedir="${music_base}/Playlists"
destinationpathstring=".."
ituneslibraryxml=""
backup_playlists=0

while getopts "p:l:s:d:bh" opt; do
  case $opt in
    p) playlistsbasedir="$OPTARG" ;;
    l) ituneslibraryxml="$OPTARG" ;;
    s) sourcepathstring="$OPTARG" ;;
    d) destinationpathstring="$OPTARG" ;;
    b) backup_playlists=1 ;;
    h) usage ;;
    *) usage ;;
  esac
done

# Set default values for paths that depend on playlistsbasedir or other options
if [ -z "${ituneslibraryxml}" ]; then
  ituneslibraryxml="${playlistsbasedir}/Library/Library.xml"
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
convertedplaylistsdir="${playlistsbasedir}/playlists"
existingplaylistsbackupdir="${playlistsbasedir}/playlists_backup"

# Create playlistsbasedir if it doesn't exist
if [ ! -d "${playlistsbasedir}" ]; then
  mkdir -p "${playlistsbasedir}"
fi

# create temporary directory for export
tempplaylistsdir=$(mktemp -d "${playlistsbasedir}/playlists.temp")
trap "rm -rf ${tempplaylistsdir}" EXIT

# export xml to m3u in temporary directory
"${itunesexport_bin}" -library "${ituneslibraryxml}" -output "${tempplaylistsdir}" -includeAllWithBuiltin || {
  echo "Error: Failed to export playlists from iTunes Library XML using ${itunesexport_bin}"
  exit 1
}

# preprocess escaped versions of path strings
sourcepathstring_esc=$(echo ${sourcepathstring} | sed 's_/_\\/_g')
destinationpathstring_esc=$(echo ${destinationpathstring} | sed 's_/_\\/_g')

# change paths and cleanup in temporary directory
do_path_replace_and_cleanup "$tempplaylistsdir" "$sourcepathstring_esc" "$destinationpathstring_esc" || {
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

# Cleanup temporary directory after successful completion
rm -rf "${tempplaylistsdir}"
trap - EXIT

echo
echo "=== Summary ==="
echo "Directories created/modified:"
echo "  - Converted playlists save to: ${convertedplaylistsdir}"
if [ "$backup_playlists" -eq 1 ] && [ -d "${existingplaylistsbackupdir}" ]; then
  echo "  - Existing playlists backuped up to: ${existingplaylistsbackupdir}"
fi
echo "Path strings modified in converted playlists:"
echo "  - Source path: ${sourcepathstring}"
echo "  - Destination path: ${destinationpathstring}"
echo
echo "All Done!"
echo
