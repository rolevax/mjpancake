# Pancake Mahjong

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/mjpancake)
[![Build Status](https://travis-ci.org/rolevax/mjpancake.svg?branch=develop)](https://travis-ci.org/rolevax/mjpancake)

Pancake Mahjong is an inofficial Saki mahjong game
with high-quality occult implementation.

Visit [https://mjpancake.github.io] for more information.

## Build

The client can be built on Linux, Windows, or macOS with
Qt (community version) installed, 
The least required version is Qt 5.7.1, 
but it is recommended to use the lastest Qt 5.9.1
to obtain a probably better performance.
The target platform can be Linux, Windows, macOS, Android, or iOS. 
Visit [https://www.qt.io/] to learn about Qt.

To obtain an executable client,
build it either by the Qt Creator (easier) or from the command line:

```
git clone --recursive https://github.com/rolevax/mjpancake.git
mkdir build && cd build
qmake -config release ../mjpancake
make (or nmake, or mingw32-make according to your platform)
```

## License

- The Pancake Mahjong client is released under the LGPLv3 license
- The Libsaki library is released under the MIT license


