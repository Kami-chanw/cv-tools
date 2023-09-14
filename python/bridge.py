# To be used on the @QmlElement decorator
# (QML_IMPORT_MINOR_VERSION is optional)
QML_IMPORT_NAME = "CvTools"
QML_IMPORT_MAJOR_VERSION = 1

from typing import Optional
from PySide6.QtCore import QObject, Slot, QEnum, QUrl, Signal, Property
from PySide6.QtGui import QImageReader
from PySide6.QtQml import QmlElement
from enum import Enum
from pathlib import Path, WindowsPath
from .image_loader import *
from .algo_model import *
from .algo_widgets import AbstractWidget
from functools import partial
import re
import cv2
import numpy as np
import pickle


@QmlElement
class Enums(QObject):
    WidgetType = QEnum(AbstractWidget.WidgetType)
    SelectorType = QEnum(Selector.SelectorType)
    State = QEnum(QValidator.State)


@QmlElement
class SessionData(QObject):
    nameChanged = Signal()
    frameChanged = Signal(int)
    isClonedViewChanged = Signal()
    errorStringChanged = Signal()

    def __init__(self, path: WindowsPath, parent=None) -> None:
        super().__init__(parent)

        self._isClonedView = False
        self._errorString = None
        self._algoModel = [AlgorithmListModel(self), AlgorithmListModel(self)]
        self._algoModel[0].updateRequired.connect(lambda :self.applyAlgorithms(0))
        # self._algoModel[1].updateRequired.connect(lambda :self.applyAlgorithms(1))

        self._sessionPath = None

        if path.suffix in [".png", ".jpg", ".jpeg", ".jpe"]:
            self._type = TaskType.Image
            self._name = "untitled"
            self._filePath = path
            reader = QImageReader(str(path))
            self._origin_image = reader.read()
            if self._origin_image is None:
                raise IOError(reader.errorString())
            self.frame = [self._origin_image]

        elif path.suffix in [".mp4"]:
            self._type = TaskType.Video
            self._name = "untitled"
        elif path.suffix == ".cvsession":
            with open(path, 'rb') as f:
                data = pickle.load(f)
                # only self._isClonedView, self._algoGroup, self._sessionPath can be detected

                for name, value in vars(self).items():
                    if name.startswith('_'):
                        if name == '_algoModel':
                            self._algoModel = [AlgorithmListModel.load(data['_algoModel'][0]),
                                               AlgorithmListModel.load(data['_algoModel'][1])]
                        else:
                            value = data[name]

                try:
                    self._type = data['_type']
                    self._name = data['_name']
                    self._filePath = data['_filePath']
                except Exception as e:
                    print(e)
                print('Loading successfully')
                if not self._filePath.exists():
                    raise FileNotFoundError("Original file not found.")
                else:
                    reader = QImageReader(str(self._filePath))
                    self._origin_image = reader.read()
                    self.frame = [self._origin_image]
        else:
            raise ValueError("unknown file")

    def _qt2cv(self, qimage):
        if qimage.format() != QImage.Format.Format_RGB32:
            qimage = qimage.convertToFormat(QImage.Format.Format_RGB32)

        width = qimage.width()
        height = qimage.height()
        ptr = qimage.constBits()
        img_data = np.array(ptr).reshape(height, width, 4)
        return img_data

    def _cv2qt(self, cv_img):
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

    def setFrame(self, index, newImage, emit=True):
        if index >= len(self.frame):
            self.frame.append(newImage)
        elif self.frame[index] != newImage:
            self.frame[index] = newImage
        else:
            return
        if emit:
            self.frameChanged.emit(index)

    def applyAlgorithms(self, index):
        currentFrame = self._qt2cv(self._origin_image)
        for algo in self._algoModel[index].algorithms:
            if algo.enabled:
                try:
                    currentFrame = algo.apply(currentFrame)
                    if currentFrame is None:
                        raise ValueError(f"Faild to apply alogorithm {algo.title}")
                except Exception as e:
                    self.errorString = str(e)
                    return
        self.setFrame(index, self._cv2qt(currentFrame))

    fileName = Property(str, lambda self: self._filePath.name)
    algoModel = Property(list, lambda self: self._algoModel, constant=True)
    type = Property(TaskType, lambda self: self._type, constant=True)
    name = Property(str, lambda self: self._name, constant=True)
    isClonedView = Property(bool,
                            lambda self: self._isClonedView,
                            notify=isClonedViewChanged)
    sessionPath = Property(str, lambda self: self._sessionPath, constant=True)
    errorString = Property(str, lambda self:self._errorString, notify=errorStringChanged)

    @isClonedView.setter
    def isClonedView(self, value):
        if self._isClonedView != value:
            self._isClonedView = value
            self.isClonedViewChanged.emit()
    
    @errorString.setter
    def errorString(self, errorString):
        if self._errorString != errorString:
            self._errorString = errorString
            self.errorStringChanged.emit()



@QmlElement
class Bridge(QObject):

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._errorString = None

    @Slot(QUrl, "QVariant", result=SessionData)
    def parseFile(self, url, provider: ImageProvider):
        try:
            data = SessionData(self._trimPath(url), self)
            provider.type = data.type
            data.frameChanged.connect(lambda index: provider.setFrame(
                index, data.frame[index], False))
            provider.frameChanged.connect(lambda index: data.setFrame(
                index, provider.frame[index], False))
            data.frameChanged.emit(0)
            return data
        except Exception as e:
            self._errorString = str(e)
            return None

    def _trimPath(self, url: QUrl):
        path = url.path()
        match = re.match(r'^/([A-Za-z]):', path)
        if match:
            drive_letter = match.group(1)
            path = drive_letter + ":" + path[3:]
        return Path(path).resolve()

    @Slot(str, SessionData, int)
    def export(self, path, data, quality):
        if -1 <= quality <= 100:
            pass
        else:
            raise Exception('quality out of range, it should be between -1 and 100')
        type = 'JPG'
        if path.endswith('.jpg'):
            type = 'JPG'
        elif path.endswith('.png'):
            type = 'PNG'
        elif path.endswith('.jpeg'):
            type = 'JPEG'
        data.frame[0].save(path, type, quality)

    @Slot(SessionData, str, result=bool)
    def save(self, data, url: QUrl = None):
        path = self._trimPath(QUrl(url))
        if not path.suffix == '.cvsession':
            path += '.cvsession'
        try:
            with open(path, 'wb') as f:
                save_data = dict()
                for name, value in vars(data).items():
                    if name.startswith('_'):
                        if name == '_origin_image':
                            pass
                        elif name == '_algoModel':
                            save_data[name] = [value[0].toPlainData(), value[1].toPlainData()]
                        else:
                            save_data[name] = value
                    else:
                        pass
                pickle.dump(save_data, f)
            data._sessionPath = url
            print('Saved successfully')
            return True
        except FileNotFoundError as e:
            print(e)
            return False

    @Property(str, constant=True)
    def errroString(self):
        return self._errorString
