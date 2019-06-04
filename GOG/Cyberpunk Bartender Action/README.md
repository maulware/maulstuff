# VA-11 Hall-A: Cyberpunk Bartender Action
Source: [https://www.gog.com/game/va11_halla]

Game working on newer linux.

# Fixing small library issue
Game requires libssl1.0.0:i386 to be installed as well.
add `deb http://security.debian.org/debian-security jessie/updates main` to new created `/etc/apt/sources.list.d/legacy-jesssie.list`
run update and install 32 bit library:
```apt update && apt install libssl1.0.0:i386```


Previously was showing `libcrypto.so.1.0.0 => not found` (same for libssl) and starting the game returned:
```/home/user/GOG Games/VA 11 Hall A Cyberpunk Bartender Action/game/runner: error while loading shared libraries: libcrypto.so.1.0.0: cannot open shared object file: No such file or directory```


actual "fixed" now has all required libraries installed.
```
user@machine: ldd ~/GOG\ Games/VA\ 11\ Hall\ A\ Cyberpunk\ Bartender\ Action/game/runner
	linux-gate.so.1 (0xf7f6f000)
	libstdc++.so.6 => /usr/lib/i386-linux-gnu/libstdc++.so.6 (0xf7d91000)
	libz.so.1 => /lib/i386-linux-gnu/libz.so.1 (0xf7d72000)
	libXxf86vm.so.1 => /usr/lib/i386-linux-gnu/libXxf86vm.so.1 (0xf7d6b000)
	libGL.so.1 => /usr/lib/i386-linux-gnu/libGL.so.1 (0xf7d05000)
	libopenal.so.1 => /usr/lib/i386-linux-gnu/libopenal.so.1 (0xf7c0f000)
	libm.so.6 => /lib/i386-linux-gnu/libm.so.6 (0xf7b09000)
	librt.so.1 => /lib/i386-linux-gnu/librt.so.1 (0xf7afe000)
	libpthread.so.0 => /lib/i386-linux-gnu/libpthread.so.0 (0xf7add000)
	libdl.so.2 => /lib/i386-linux-gnu/libdl.so.2 (0xf7ad7000)
	libcrypto.so.1.0.0 => /usr/lib/i386-linux-gnu/libcrypto.so.1.0.0 (0xf78f4000)
	libXext.so.6 => /usr/lib/i386-linux-gnu/libXext.so.6 (0xf78dd000)
	libX11.so.6 => /usr/lib/i386-linux-gnu/libX11.so.6 (0xf778e000)
	libXrandr.so.2 => /usr/lib/i386-linux-gnu/libXrandr.so.2 (0xf7781000)
	libGLU.so.1 => /usr/lib/i386-linux-gnu/libGLU.so.1 (0xf7706000)
	libssl.so.1.0.0 => /usr/lib/i386-linux-gnu/libssl.so.1.0.0 (0xf76a2000)
	libgcc_s.so.1 => /lib/i386-linux-gnu/libgcc_s.so.1 (0xf7684000)
	libc.so.6 => /lib/i386-linux-gnu/libc.so.6 (0xf74a6000)
	/lib/ld-linux.so.2 (0xf7f71000)
	libGLX.so.0 => /usr/lib/i386-linux-gnu/libGLX.so.0 (0xf7482000)
	libGLdispatch.so.0 => /usr/lib/i386-linux-gnu/libGLdispatch.so.0 (0xf7420000)
	libsndio.so.7.0 => /usr/lib/i386-linux-gnu/libsndio.so.7.0 (0xf740d000)
	libatomic.so.1 => /usr/lib/i386-linux-gnu/libatomic.so.1 (0xf7401000)
	libxcb.so.1 => /usr/lib/i386-linux-gnu/libxcb.so.1 (0xf73d3000)
	libXrender.so.1 => /usr/lib/i386-linux-gnu/libXrender.so.1 (0xf73c7000)
	libasound.so.2 => /usr/lib/i386-linux-gnu/libasound.so.2 (0xf72ad000)
	libbsd.so.0 => /usr/lib/i386-linux-gnu/libbsd.so.0 (0xf728e000)
	libXau.so.6 => /usr/lib/i386-linux-gnu/libXau.so.6 (0xf7289000)
	libXdmcp.so.6 => /usr/lib/i386-linux-gnu/libXdmcp.so.6 (0xf7282000)
```
