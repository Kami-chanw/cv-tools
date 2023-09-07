# To be used on the @QmlElement decorator
# (QML_IMPORT_MINOR_VERSION is optional)
QML_IMPORT_NAME = "CvTools"
QML_IMPORT_MAJOR_VERSION = 1

from PySide6.QtCore import QObject, Slot, QEnum, QUrl, Signal, Property
from PySide6.QtGui import QImageReader
from PySide6.QtQml import QmlElement
from enum import Enum
from pathlib import Path
from .image_loader import *
from .algo_model import *
from functools import partial
import re
import cv2
import numpy as np
import pickle

@QmlElement
class Enums(QObject):
    QEnum(AlgorithmRole)


@QmlElement
class SessionData(QObject):

    nameChanged = Signal()
    frameChanged = Signal(int)
    isClonedViewChanged = Signal()

    def __init__(self, url: QUrl, parent=None) -> None:
        super().__init__(parent)

        self._isClonedView = False
        self._algoGroup = [[], []]
        self._sessionPath = None
        path = self._trimPath(url)

        if path.suffix in [".png", ".jpg", ".jpeg", ".jpe"]:
            self._type = TaskType.Image
            self._name = "untitled"
            self._fileName = path.name
            reader = QImageReader(str(path))
            self._origin_image = reader.read()
            if self._origin_image is None:
                raise IOError(reader.errorString())
            self.frame = [self._origin_image]

        elif path.suffix in [".mp4"]:
            self._type = TaskType.Video
            self._name = "untitled"
        elif path.suffix == ".cvsession":
            with open(path, 'wb') as f:
                data = pickle.load(f)
            for name, value in vars(self).items():
                value = data[name]
        else:
            raise ValueError("unknown file")
    
    def _qt2cv(self, qimage):
        if qimage.format() == QImage.Format_RGB32:
            qimage = qimage.convertToFormat(QImage.Format_RGB888)

        img = np.frombuffer(qimage.bits(), dtype=np.uint8).reshape(qimage.height(), qimage.width(), 4)
        return cv2.cvtColor(img, cv2.COLOR_RGBA2BGR)

    def _cv2qt(self,cv_img):
        if len(cv_img.shape) == 2:  # 灰度图像
            height, width = cv_img.shape
            bytes_per_line = width
            image_format = QImage.Format_Grayscale8
        elif len(cv_img.shape) == 3:  # 彩色图像
            height, width, channel = cv_img.shape
            bytes_per_line = 3 * width
            image_format = QImage.Format_RGB888
            cv_img = cv2.cvtColor(cv_img, cv2.COLOR_BGR2RGB)
        else:
            raise ValueError("Unsupported image format")

        return QImage(cv_img.data, width, height, bytes_per_line, image_format)
    
    def _trimPath(self, url : QUrl):
        path = url.path()
        match = re.match(r'^/([A-Za-z]):', path)
        if match:
            drive_letter = match.group(1)
            path = drive_letter + ":" + path[3:]
        return Path(path).resolve()
        
    
    @Slot(str)
    def save(self, url: QUrl = None):
        path = self._trimPath(QUrl(url))
        data = vars(self)
        if not path.suffix == '.cvsession':
            path += '.cvsession'
        with open(path, 'wb') as f:
            pickle.dump(data, f)
        self._sessionPath = url

    @Slot(int, int, dict)
    def setAlgoParams(self, index, algoIndex, **kwargs):
        for key, value in kwargs.items():
            setattr(self._algoGroup[index][algoIndex], key, value)
        self.setFrame(index, self.applyAlgorithms(index))
        

    def setFrame(self, index, newImage, emit=True):
        if index >= len(self.frame):
            self.frame.append(newImage)
        elif self.frame[index] != newImage:
            self.frame[index] = newImage
        else:
            return
        if emit:
            self.frameChanged.emit(index)

    @Slot(int, Algorithm)
    def appendAlgorithm(self, index: int, algo: Algorithm):
        self._algoGroup[index].append(algo)
        self.setFrame(index, self.applyAlgorithms(index))

    def applyAlgorithms(self, index):
        currentFrame = self._qt2cv(self._origin_image)
        for algo in self._algoGroup[index]:
            if algo.enabled:
                currentFrame = algo.apply(algo)
                if currentFrame is None:
                    raise ValueError(f"Faild to apply alogorithm {algo.title}")
        return currentFrame
    
    @Property(str)
    def fileName(self):
        return self._fileName

    @Property(list, constant=True)
    def algoGroup(self):
        return self._algoGroup

    @Property(TaskType, constant=True)
    def type(self):
        return self._type

    @Property(str, constant=True)
    def name(self):
        return self._name

    @Property(bool, notify=isClonedViewChanged)
    def isClonedView(self):
        return self._isClonedView

    @isClonedView.setter
    def isClonedView(self, value):
        if self._isClonedView != value:
            self._isClonedView = value
            self.isClonedViewChanged.emit()
    
    @Property(str, constant=True)
    def sessionPath(self):
        return self._sessionPath



@QmlElement
class Bridge(QObject):

    @Slot(QUrl, "QVariant", result=SessionData)
    def parseFile(self, url, provider: ImageProvider):
        data = SessionData(url, self)
        provider.type = data.type
        data.frameChanged.connect(
            lambda index: provider.setFrame(index, data.frame[index], False))
        provider.frameChanged.connect(
            lambda index: data.setFrame(index, provider.frame[index], False))
        data.frameChanged.emit(0)
        return data
