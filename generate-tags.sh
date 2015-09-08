#!/bin/bash
set -e

declare -A aliases

contains() {
    for word in $1; do
        [[ $word = $2 ]] && return 0
    done
    return 1
}

aliases=(
    [0.7]='latest'
    [0.7-composable]='latest-composable'
)

# ignores=(
#     'hub-docs'
#     'files'
# )

ignores=('hub-docs files')


cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )
url='git@github.com:Wirecloud/docker-wirecloud'

echo '# Maintainer: WireCloud Team <wirecloud@conwet.com>'

for version in "${versions[@]}"; do
    commit="$(git log -1 --format='format:%H' -- "$version")"
    versionAliases=( $version ${aliases[$version]} )

    if ! contains "$ignores" $version; then
        echo
        for va in "${versionAliases[@]}"; do
            echo "$va: ${url}@${commit} $version"
        done
    fi
done
