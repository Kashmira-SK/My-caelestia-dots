# Nested directory refresh regression

Build the model and run the actual Qt directory watcher against temporary image
and video files. Adding/removing files in `Live/` must preserve root-level images.

```sh
cmake --build build --target caelestia-models -j2
c++ -std=c++20 tests/filesystem/nested-refresh.cpp \
    -Iplugin/src/Caelestia/Models $(pkg-config --cflags --libs Qt6Gui Qt6Qml) \
    -Lbuild/plugin/src/Caelestia/Models -lcaelestia-models \
    -Wl,-rpath,"$PWD/build/plugin/src/Caelestia/Models" \
    -o /tmp/caelestia-nested-refresh
QT_QPA_PLATFORM=offscreen /tmp/caelestia-nested-refresh
```

The old installed library reproduces the failure (exit 2) when selected using
`LD_LIBRARY_PATH=/usr/lib/qt6/qml/Caelestia/Models`.
