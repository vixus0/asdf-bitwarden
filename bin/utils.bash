source "$(dirname -- "$0")/constants.bash"

download () {
  local -r download_url="$1"
  local -r download_path="$2"

  echo "Downloading ${toolname} version ${ASDF_INSTALL_VERSION} from ${download_url}"
  curl -fsL "${download_url}" -o "${download_path}"
  if [[ ! "$?" ]] ; then
    echo "Error: ${toolname} version ${ASDF_INSTALL_VERSION} not found" >&2
    exit 1
  fi
}

get_download_url () {
  local version="v$1"

  local -r repository="$(get_repository "$version")"
  [[ "$version" == "latest" ]] && \
    versions=("$(get_versions "$repository")") && \
    version="$(get_latest_version "${versions[@]}")"

  [[ "$repository" == "bitwarden/clients" ]] && \
    version="cli-$version"

  local -r arch="$(get_arch)"
  printf "https://github.com/%s/releases/download/%s/%s-%s-%s.zip\n" \
    "$repository" "$version" "$toolname" "$arch" "${version/cli-v}"
}

get_repository () {
  case "$1" in 
    1.* )  echo "$old_repository" ;;
    *   )  echo "$repository" ;;
  esac
}

get_arch () {
  uname | tr '[:upper:]' '[:lower:]' | sed 's/darwin/macos/g'
}

get_versions() {
  local repo="$1"

  curl -s "${oauth_header[@]}" "https://api.github.com/repos/$repo/releases" | \
    grep "tag_name" | \
    cut -f 4 -d \" | \
    grep -E "^(cli-)?v" | \
    grep -oE "[0-9\.]+" | \
    tac
}

get_latest_version () {
  tail -n1 <<< "$1"
}
