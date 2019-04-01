# mpv wrapper

Allows all local mpv instances to be controlled via commandline. Normally only 1 is required, but in case multiple mpv instances are running, it makes sense to have a convinient way of controlling all of them simultaniously.

## Install

Put the mpv wrapper script into any directory in your PATH (e.g. $HOME/bin or $HOME/.local/bin). Verify with `which mpv` that the wrapper is actually being used.

## Use

Use mpv like before `mpv whatever`, now all started instaces can be paused and contiued via:
```
for s in /tmp/mpvsocks/* ; do
    echo '{ "command": ["set_property", "pause", true] }' | socat - $s
done
sleep 5
for s in /tmp/mpvsocks/* ; do
    echo '{ "command": ["set_property", "pause", false] }' | socat - $s
done
```

## Aftermath

In some rare cases the process might have been killed without having triggered the TRAP, use this to ensure you dont have too many leftovers:
```
/usr/bin/find /tmp/mpvsocks/ -type s | grep -vE "$(ss -pna | grep -oE "/tmp/mpvsocks/[0-9]+" | tr '\n' '|')stupidcra" | xargs rm
```
