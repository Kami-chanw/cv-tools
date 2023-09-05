from PySide6.QtCore import QSize, Slot, QEnum, QUrl, Signal, Property
from PySide6.QtGui import QImage
from PySide6.QtQml import QmlElement, QQmlImageProviderBase
from PySide6.QtQuick import QQuickImageProvider
from enum import Enum


class ImageProvider(QQuickImageProvider):

    @QEnum
    class ProviderType(Enum):
        Video, Image, Stream = range(3)

    def __init__(self, type: ProviderType) -> None:
        super().__init__(
            QQmlImageProviderBase.ImageType.Image,
            QQmlImageProviderBase.Flag.ForceAsynchronousImageLoading)
        self._frame = None
        self._source = None
        self.type = type
        self._counter = 0

    def requestImage(self, id: str, size: QSize,
                     requestedSize: QSize) -> QImage:
        size = QSize(self._frame.size())
        if requestedSize.isValid():
            return self._frame.scaled(requestedSize)
        return self._frame

    frameChanged = Signal(QImage)
    sourceChanged = Signal(str)

    def setFrame(self, newImage, emit = True):
        self._frame = newImage
        if emit:
            self.frameChanged.emit(newImage)
        self.setSource(f"image://{self.providerId()}/{self.type.name}/{self._counter}")

    @Property(QImage, fset=setFrame, notify=frameChanged)
    def frame(self):
        return self._frame

    def setSource(self, newSource):
        self._source = newSource
        self._counter += 1
        self.sourceChanged.emit(newSource)

    @Property(str, fset=setSource, notify=sourceChanged)
    def source(self):
        return self._source

    def providerId(self):
        return "cvtimageprovider"
