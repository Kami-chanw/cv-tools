# To be used on the @QmlElement decorator
# (QML_IMPORT_MINOR_VERSION is optional)
QML_IMPORT_NAME = "CvTools"
QML_IMPORT_MAJOR_VERSION = 1

from typing import Dict, Optional, Union
from PySide6.QtCore import QAbstractItemModel, QObject, Property, Signal, QModelIndex, QEnum, Qt, QByteArray, Slot, QAbstractListModel
from PySide6.QtQml import QmlElement
from enum import Enum
import warnings


class AbstractAlgorithm(QObject):

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self._title = None
        self._informativeTitle = None

    title = Property(str, lambda self: self._title)

    @title.setter
    def title(self, value: str):
        self._title = value

    informativeText = Property(str, lambda self: self._informativeTitle)

    @informativeText.setter
    def informativeText(self, text: str):
        self._informativeTitle = text

    @Slot(list, result=False)
    def checkPrerequisition(self, algoList: list):
        return False


class AlgorithmGroup(AbstractAlgorithm):

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self._algorithms = []

    algorithms = Property(list, lambda self: self._algorithms, constant=True)


class Algorithm(AbstractAlgorithm):

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self._widgets = []
        self._enabled = True

    def apply(self, image):
        return None

    widgets = Property(list, lambda self: self._widgets)
    enabled = Property(bool, lambda self: self._enabled)


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


@QmlElement
class AlgorithmListModel(QAbstractListModel):
    """
    This model is used to store current algorithms, which means it will be changed in qml frontend and listed in tool box.
    For Qml ListModel compatibility, it also implemented append(),
    """

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self._algorithms = []

    def rowCount(self, parent: QModelIndex = None) -> int:
        return len(self._algorithms)

    def columnCount(self, parent: QModelIndex = None) -> int:
        return 1

    def data(self, index: QModelIndex, role: int = None):
        if not index.isValid():
            return None
        if role == Qt.UserRole:
            return index.internalPointer()
        if role == Qt.DisplayRole:
            return index.internalPointer().title
        return None

    algorithms = Property(list, lambda self: self._algorithms, constant=True)

    def setData(self, index: QModelIndex, value, role: int) -> bool:
        if not index.isValid() or index.parent().isValid():
            return False
        if role == Qt.UserRole:
            if self._algorithms[index.row()] == value:
                return False
            else:
                if not type(
                        self._algorithms[index.row()]) is AbstractAlgorithm:
                    warnings.warn(
                        f"Index at {index} already has an item, setData() will override current item.",
                        category=UserWarning)
                self._algorithms[index.row()] = value
                value.setParent(None)
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

    # def 
