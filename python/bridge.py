# To be used on the @QmlElement decorator
# (QML_IMPORT_MINOR_VERSION is optional)
QML_IMPORT_NAME = "CvTools"
QML_IMPORT_MAJOR_VERSION = 1

from PySide6.QtCore import QObject, Slot, QEnum, QUrl, Signal, Property
from PySide6.QtGui import QImage
from PySide6.QtQml import QmlElement, QQmlImageProviderBase
from PySide6.QtQuick import QQuickImageProvider
from enum import Enum
from pathlib import Path
import cv2 as cv
import numpy as np
from .image_loader import *
from functools import partial
import re

@QmlElement
class SessionData(QObject):

    @QEnum
    class SessionType(Enum):
        Video, Image, Stream, Session = range(4)

    def __init__(self, url: QUrl, parent=None) -> None:
        super().__init__(parent)
        path = url.path()
        match = re.match(r'^/([A-Za-z]):', path)
        if match:
            drive_letter = match.group(1)
            path = drive_letter + ":" + path[3:]
        path = Path(path).resolve()
        if path.suffix in [".png", ".jpg", ".jpeg", ".jpe"]:
            self.setType(SessionData.SessionType.Image)
            self.setName("untitled")
            self.setFrame(self._array2img(cv.imread(str(path))))

        elif path.suffix in [".mp4"]:
            self.setType(SessionData.SessionType.Video)
            self.setName("untitled")
        elif path.suffix == ".cvsession":
            # self._type = SessionData.Type
            pass
        else:
            raise ValueError("unknown file")

    def _array2img(self, imgarr):
        h, w, ch = imgarr.shape
        if ch == 1:
            img = QImage(imgarr.data ,w,h,ch*w, QImage.Format.Format_Grayscale8)
        else:
            img = QImage(imgarr.data, w, h, ch * w, QImage.Format.Format_BGR888)
        return img

    typeChanged = Signal(int)
    nameChanged = Signal(str)
    frameChanged = Signal(QImage)

    def setFrame(self, newImage, emit=True):
        self._frame = newImage
        if emit:
            self.frameChanged.emit(newImage)

    @Property(QImage, fset=setFrame, notify=frameChanged)
    def frame(self):
        return self._frame

    def setType(self, newType):
        self._type = newType
        self.typeChanged.emit(newType)

    @Property(SessionType, fset=setType, notify=typeChanged)
    def type(self):
        return self._type

    def setName(self, newName):
        self._name = newName
        self.nameChanged.emit(newName)

    @Property(str, fset=setName, notify=nameChanged)
    def name(self):
        return self._name


@QmlElement
class Bridge(QObject):

    @Slot(QUrl, "QVariant", result=SessionData)
    def parseFile(self, url, provider : ImageProvider):
        data = SessionData(url, self)
        provider.type = ImageProvider.ProviderType[data.type.name]
        data.frameChanged.connect(partial(provider.setFrame, emit=False))
        provider.frameChanged.connect(partial(data.setFrame, emit=False))
        data.frameChanged.emit(data.frame)
        return data

