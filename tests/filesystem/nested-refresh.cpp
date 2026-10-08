#include "filesystemmodel.hpp"
#include <QGuiApplication>
#include <QTemporaryDir>
#include <QImage>
#include <QFile>
#include <QElapsedTimer>
#include <QThread>
#include <iostream>
using caelestia::models::FileSystemModel;
static bool waitFor(FileSystemModel& model, int count) {
    QElapsedTimer timer;
    timer.start();
    while (timer.elapsed() < 3000) {
        QCoreApplication::processEvents();
        if (model.rowCount() == count) return true;
        QThread::msleep(10);
    }
    return false;
}
int main(int argc, char** argv) {
    QGuiApplication app(argc, argv);
    QTemporaryDir dir;
    QDir(dir.path()).mkdir("Live");
    QImage image(8, 8, QImage::Format_RGB32);
    image.fill(Qt::blue);
    image.save(dir.filePath("static.png"));
    FileSystemModel images, videos;
    images.setFilter(FileSystemModel::Images);
    videos.setFilter(FileSystemModel::Files);
    videos.setNameFilters({"*.mp4"});
    for (auto* model : {&images, &videos}) {
        model->setRecursive(true);
        model->setPath(dir.path());
    }
    if (!waitFor(images, 1)) return 1;
    // Give the asynchronous recursive directory watcher time to attach.
    for (int i = 0; i < 30; ++i) {
        QCoreApplication::processEvents();
        QThread::msleep(10);
    }
    QFile video(dir.filePath("Live/new.mp4"));
    if (!video.open(QIODevice::WriteOnly)) return 5;
    video.write("inventory test");
    video.close();
    image.save(dir.filePath("Live/nested.png"));
    if (!waitFor(videos, 1) || !waitFor(images, 2)) return 2;
    video.remove();
    QFile::remove(dir.filePath("Live/nested.png"));
    if (!waitFor(videos, 0) || !waitFor(images, 1)) return 3;
    auto entries = images.entries();
    if (entries.at(&entries, 0)->path() != dir.filePath("static.png")) return 4;
    std::cout << "PASS: root image survives nested additions and removals\n";
}
