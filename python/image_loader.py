from PySide6.QtCore import QSize, Slot, QEnum, QUrl, Signal, Property
from PySide6.QtGui import QImage
from PySide6.QtQml import QmlElement, QQmlImageProviderBase
from PySide6.QtQuick import QQuickImageProvider
from enum import Enum


@QEnum
class TaskType(Enum):
    Video, Image, Stream = range(3)


class ImageProvider(QQuickImageProvider):

    def __init__(self) -> None:
        super().__init__(
            QQmlImageProviderBase.ImageType.Image,
            QQmlImageProviderBase.Flag.ForceAsynchronousImageLoading)
        self._frame = []
        self._source = None
        self.type = None
        self._counter = 0

    def requestImage(self, id: str, size: QSize,
                     requestedSize: QSize) -> QImage:
        index = int(id.split('/')[-2])
        size = QSize(self._frame[index].size())
        if requestedSize.isValid():
            return self._frame[index].scaled(requestedSize)
        return self._frame[index]

    frameChanged = Signal(int)
    sourceChanged = Signal()

    def setFrame(self, index, newImage, emit=True):
        if index >= len(self._frame):
            self._frame.append(newImage)
        elif self._frame[index] != newImage:
            self._frame[index] = newImage
        else:
            return
        if emit:
            self.frameChanged.emit(index)
        self.setSource(
            f"image://{self.providerId()}/{self.type.name}/{index}/{self._counter}"
        )

    @Property(list, constant=True)
    def frame(self):
        return self._frame

    def setSource(self, newSource):
        if self._source != newSource:
            self._source = newSource
            self._counter += 1
            self.sourceChanged.emit()

    @Property(str, fset=setSource, notify=sourceChanged)
    def source(self):
        return self._source

    def providerId(self):
        return "cvtimageprovider"
