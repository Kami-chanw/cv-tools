# To be used on the @QmlElement decorator
# (QML_IMPORT_MINOR_VERSION is optional)
QML_IMPORT_NAME = "CvTools"
QML_IMPORT_MAJOR_VERSION = 1

from typing import Dict, Optional, Union
from PySide6.QtCore import QAbstractItemModel, QObject, Property, Signal, QModelIndex, QEnum, Qt, QByteArray, Slot, \
    QAbstractListModel
from PySide6.QtGui import QStandardItemModel, QStandardItem
from PySide6.QtQml import QmlElement
from enum import Enum
from .algo_widgets import *
import warnings


class AbstractAlgorithm(QObject):

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self._title = None
        self._informativeTitle = None

    titleChanged = Signal()
    title = Property(str, lambda self: self._title, notify=titleChanged)

    @title.setter
    def title(self, title: str):
        if self._title != title:
            self._title = title
            self.titleChanged.emit()

    informativeTextChanged = Signal()
    informativeText = Property(str,
                               lambda self: self._informativeTitle,
                               notify=informativeTextChanged)

    @informativeText.setter
    def informativeText(self, text: str):
        if self._informativeTitle != text:
            self._informativeTitle = text
            self.informativeTextChanged.emit()


class AlgorithmGroup(AbstractAlgorithm):

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self._algorithms = []

    algorithms = Property(list, lambda self: self._algorithms, constant=True)


class Algorithm(AbstractAlgorithm):
    currentValueChanged = Signal(QModelIndex)
    enabledChanged = Signal()

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self._widgets = QStandardItemModel(self)
        self._enabled = True

    @classmethod
    def load(cls, data: dict):
        model = cls()
        for i in range(len(data['types'])):
            _type = str(data['types'][i]).split('.')[1]
            class_to_call = globals()[_type]
            item = class_to_call.load(data['widgets'][i])
            # Set the (i,0) item here to the variable item
            temp = QStandardItem()
            temp.setData(item, Qt.DisplayRole)
            model._widgets.setItem(i, 0, temp)
        model._enabled = data['enabled']
        return model

    def toPlainData(self):
        widgets = []
        types = []
        for i in range(self._widgets.rowCount()):
            item = self._widgets.item(i, 0).data(Qt.UserRole)
            print(item._type)
            if item is not None:
                widgets.append(item.toPlainData())
                types.append(item._type)
            else:
                widgets.append(None)
                types.append(None)
        return {'title': self._title, 'informativeTitle': self._informativeTitle, 'widgets': widgets,
                'enabled': self._enabled, 'types': types}

    def apply(self, image):
        return None

    def indexFromWidget(self, widget: AbstractWidget):
        for row in range(self._widgets.rowCount()):
            if self._widgets.item(row, 0).data(Qt.DisplayRole) == widget.title:
                return row
        return -1

    def addWidget(self, widget: AbstractWidget):

        item = QStandardItem()
        item.setData(widget, Qt.UserRole)
        item.setData(widget.title, Qt.DisplayRole)
        widget.currentValueChanged.connect(
            lambda: self.currentValueChanged.emit(
                self.indexFromWidget(widget)))
        self._widgets.appendRow(item)

    widgets = Property(QObject, lambda self: self._widgets, constant=True)
    enabled = Property(bool, lambda self: self._enabled, notify=enabledChanged)

    @enabled.setter
    def enabled(self, enabled):
        if self._enabled != enabled:
            self._enabled = enabled
            self.enabledChanged.emit()


class AlgorithmTreeModel(QAbstractItemModel):
    """
    This model is used for global display. Its instance named `algorithmTreeModel` will be registered into qml engine when App start.
    Then it will be parsed and add to command pane or edit menu.
    """

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self._rootItem = AlgorithmGroup()

    def columnCount(self, parent: QModelIndex = None) -> int:
        return 1

    def rowCount(self, parent: QModelIndex = QModelIndex()) -> int:
        parent_item: AlgorithmGroup = self._getItem(parent)
        if not issubclass(type(parent_item), AlgorithmGroup):
            return 0
        return len(parent_item.algorithms)

    def data(self, index: QModelIndex, role: int = None):
        if not index.isValid():
            return None
        if role == Qt.UserRole:
            return index.internalPointer()
        if role == Qt.DisplayRole:
            return index.internalPointer().title
        return None

    def setData(self, index: QModelIndex, value, role: int) -> bool:
        if not index.isValid():
            return False
        item: AbstractAlgorithm = index.internalPointer()
        result = False
        if role == Qt.UserRole:
            parent_item = item.parent(
            )  # parent_item here must be AlgorithmGroup
            if parent_item.algorithms[index.row()] != value:
                if not type(parent_item.algorithms[
                                index.row()]) is AbstractAlgorithm:
                    warnings.warn(
                        f"Index at {index} already has an item, setData() will override current item.",
                        category=UserWarning)
                parent_item.algorithms[index.row()] = value
                value.setParent(parent_item)
                result = True
        elif role == Qt.DisplayRole:
            if item.title != value:
                item.title = value
                result = True

        if result:
            self.dataChanged.emit(index, index, [role])

        return result

    def parent(self, index: QModelIndex = QModelIndex()) -> QModelIndex:
        if not index.isValid():
            return QModelIndex()

        child_item: AbstractAlgorithm = index.internalPointer()
        parent_item: AlgorithmGroup = child_item.parent(
        )  # parent_item here must be AlgorithmGroup

        return self.createIndex(parent_item.algorithms.index(child_item), 0,
                                parent_item)

    def index(self, row: int, column: int,
              parent: QModelIndex = QModelIndex()) -> QModelIndex:
        parent_item: AbstractAlgorithm = self._getItem(parent)
        if not issubclass(type(parent_item), AlgorithmGroup):
            return QModelIndex()

        if 0 <= row < len(parent_item.algorithms):
            return self.createIndex(row, column, parent_item.algorithms[row])
        return QModelIndex()

    def insertRows(self,
                   row: int,
                   count: int,
                   parent: QModelIndex = QModelIndex()) -> bool:

        parent_item: AlgorithmGroup = self._getItem(parent)
        if not issubclass(type(parent_item), AlgorithmGroup):
            return False

        if 0 <= row <= len(parent_item.algorithms) and count > 0:
            self.beginInsertRows(parent, row, row + count - 1)
            for _ in range(count):
                parent_item.algorithms.insert(row,
                                              AbstractAlgorithm(parent_item))
            self.endInsertRows()
            return True
        return False

    def removeRows(self,
                   row: int,
                   count: int,
                   parent: QModelIndex = QModelIndex()) -> bool:
        parent_item: AlgorithmGroup = self._getItem(parent)
        if not issubclass(type(parent_item), AlgorithmGroup):
            return False

        if 0 <= row and row + count <= len(parent_item.algorithms):
            self.beginRemoveRows(parent, row, row + count - 1)
            for _ in range(count):
                parent_item.algorithms.pop(row)
            self.endRemoveRows()
            return True
        return False

    def _getItem(self, index: QModelIndex):
        if index.isValid():
            item: AbstractAlgorithm = index.internalPointer()
            if item:
                return item

        return self._rootItem


class AlgorithmListModel(QAbstractListModel):
    """
    This model is used to store current algorithms, which means it will be changed in qml frontend and listed in tool box.
    For Qml ListModel compatibility, it also implemented append(),
    """

    updateRequired = Signal()

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self._algorithms = []
        self.rowsMoved.connect(self.updateRequired)
        self.rowsRemoved.connect(self.updateRequired)

    @classmethod
    def load(cls, data: dict):
        model = cls()
        for algo in data['algorithms']:
            model._algorithms.append(Algorithm.load(algo))
        return model

    def toPlainData(self):
        algorithms = []
        for algo in self._algorithms:
            algorithms.append(algo.toPlainData())
        print(algorithms)
        return {'algorithms': algorithms}

    def rowCount(self, parent: QModelIndex = None) -> int:
        return len(self._algorithms)

    def columnCount(self, parent: QModelIndex = None) -> int:
        return 1

    def data(self, index: QModelIndex, role: int = None):
        if not index.isValid() or index.parent().isValid():
            return None
        if role == Qt.UserRole:
            return self._algorithms[index.row()]
        if role == Qt.DisplayRole:
            return self._algorithms[index.row()].title
        return None

    algorithms = Property(list, lambda self: self._algorithms, constant=True)

    def setData(self, index: QModelIndex, value, role: int) -> bool:
        if not index.isValid() or index.parent().isValid():
            return False
        if role == Qt.UserRole:
            if self._algorithms[index.row()] == value:
                return False
            else:
                if not value is None:
                    if not type(self._algorithms[
                                    index.row()]) is AbstractAlgorithm:
                        warnings.warn(
                            f"Index at {index} already has an item, setData() will override current item.",
                            category=UserWarning)
                    if not issubclass(type(value), Algorithm):
                        raise ValueError(
                            f"Value must subclass Algorithm, current type is {type(value)}"
                        )

                    value.currentValueChanged.connect(self.updateRequired)
                    value.enabledChanged.connect(self.updateRequired)
                    self._algorithms[index.row()] = value
                    value.setParent(None)
                    self.updateRequired.emit()
                else:
                    warnings.warn(
                        f"Value is NoneType, if you want to rmeove item here, set AbstractAlgorithm() instead",
                        category=UserWarning)
        elif role == Qt.DisplayRole:
            self._algorithms[index.row()].title = value
        else:
            return False

        self.dataChanged.emit(index, index, [role])

        return True

    def index(self, row: int, column: int,
              parent: QModelIndex = QModelIndex()) -> QModelIndex:
        if parent.isValid():
            return QModelIndex()

        if 0 <= row < len(self._algorithms):
            return self.createIndex(row, column, QModelIndex())
        return QModelIndex()

    def insertRows(self,
                   row: int,
                   count: int,
                   parent: QModelIndex = QModelIndex()) -> bool:
        if parent.isValid():
            return False

        if 0 <= row <= len(self._algorithms) and count > 0:
            self.beginInsertRows(parent, row, row + count - 1)
            for _ in range(count):
                self._algorithms.insert(row, AbstractAlgorithm())
            self.endInsertRows()
            return True
        return False

    def removeRows(self,
                   row: int,
                   count: int,
                   parent: QModelIndex = QModelIndex()) -> bool:
        if parent.isValid():
            return False

        if 0 <= row and row + count <= len(self._algorithms):
            self.beginRemoveRows(parent, row, row + count - 1)
            for _ in range(count):
                self._algorithms.pop(row)
            self.endRemoveRows()
            return True
        return False

    # Qml ListModel compatibility

    count = Property(int, lambda self: len(self._algorithms))

    @Slot(int, result=Algorithm)
    def get(self, index):
        if 0 <= index < self.count:
            return self._algorithms[index]
        return None

    @Slot(int, Algorithm)
    def set(self, index, algo):
        self.setData(self.index(index, 0), algo, Qt.UserRole)

    @Slot(Algorithm)
    def append(self, algo: Algorithm):
        self.insertRow(self.count)
        self.setData(self.index(self.count - 1, 0), algo, Qt.UserRole)

    @Slot(int, int)
    def remove(self, index, count):
        self.removeRows(index, count)

    @Slot(int, int, int)
    def move(self, frm, to, count):
        if frm < 0 or to < 0 or count < 1 or frm + count > len(
                self._algorithms) or to + count > len(self._algorithms):
            raise IndexError("index out of range")

        if self.beginMoveRows(QModelIndex(), frm, frm + count - 1,
                              QModelIndex(), to + (to > frm)) == False:
            raise ValueError(
                "beginMoveRows() failed, check params and read qt document.")

        for _ in range(count):
            self._algorithms.insert(to, self._algorithms.pop(frm))
        self.endMoveRows()
