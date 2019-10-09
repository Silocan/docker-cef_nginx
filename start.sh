#!/bin/bash
set -e
# Restore original default config if no config has been provided
#if [[ ! "$(ls -A /docker/nginx/conf.d/default.template)" ]]; then
#    cp -a /etc/nginx/.conf.d.orig/. /etc/nginx/conf.d 2>/dev/null
#fi

# Copy template
cp /etc/nginx/conf.d/default.template /etc/nginx/conf.d/default.conf

# Replace variables $ENV{<environment varname>}
function ReplaceEnvironmentVariable() {
    grep -rl "\$ENV{\"$1\"}" $3|xargs -r \
        sed -i "s|\\\$ENV{\"$1\"}|$2|g"
}

if [ -n "$DEBUG" ]; then
    echo "Environment variables:"
    env
    echo "..."
fi

# Replace all variables
for _curVar in `env | awk -F = '{print $1}'`;do
    # awk has split them by the equals sign
    # Pass the name and value to our function
    ReplaceEnvironmentVariable ${_curVar} ${!_curVar} /etc/nginx/conf.d/default.conf
done

# Run nginx
exec nginx -g 'daemon off;'