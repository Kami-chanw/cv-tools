# To be used on the @QmlElement decorator
# (QML_IMPORT_MINOR_VERSION is optional)
QML_IMPORT_NAME = "CvTools"
QML_IMPORT_MAJOR_VERSION = 1

from typing import Any, Dict, Optional, Union
from PySide6.QtCore import QAbstractItemModel, QObject, Property, Signal, QModelIndex, QEnum, Qt, QByteArray, Slot, \
    QAbstractListModel
from PySide6.QtGui import QStandardItemModel, QStandardItem
from PySide6.QtQml import QmlElement
from .algo_layout import *
from enum import Enum
from .algo_widgets import *
import warnings
import bisect
import copy


class AbstractAlgorithm(QObject):

    def __init__(self,
                 title: str = None,
                 informativeText: str | None = None,
                 parent: QObject = None) -> None:
        super().__init__(parent)
        self._title = title
        self._informativeText = informativeText

    title = Property(str, lambda self: self._title, constant=True)
    informativeText = Property(str,
                               lambda self: self._informativeText,
                               constant=True)


class AlgorithmGroup(AbstractAlgorithm):

    class ItemOrder(Enum):
        KeepOrder, Sorted = range(2)

    def __init__(self,
                 title: str,
                 parent: QObject = None,
                 itemOrder=ItemOrder.Sorted) -> None:
        super().__init__(title, None, parent)
        self._algorithms = []
        self.itemOrder = itemOrder

    def append(self, algorithm):
        if self.itemOrder == self.ItemOrder.Sorted:
            raise ValueError("Cannot use append with ItemOrder.Sorted.")
        self._algorithms.append(algorithm)
        self._currentIndex = 0  # for iteration

    @overload
    def insert(self, index: int, algorithm) -> None:
        ...

    @overload
    def insert(self, algorithm) -> None:
        ...

    def insert(self, *args):
        if self.itemOrder == self.ItemOrder.Sorted:
            if len(args) != 1:
                raise ValueError(
                    "insert can only be used with one argument in ItemOrder.Sorted mode"
                )
            algorithm = args[0]
            index = bisect.bisect_left(self._algorithms,
                                       algorithm.title,
                                       key=lambda x: x._title)
            self._algorithms.insert(index, algorithm)
        elif self.itemOrder == self.ItemOrder.KeepOrder:
            if len(args) != 2:
                raise ValueError(
                    "insert can only be used with two arguments in ItemOrder.KeepOrder mode"
                )
            index, algorithm = args
            self._algorithms.insert(index, algorithm)
        else:
            raise ValueError("Invalid itemOrder value")

    def remove(self, algorithm):
        self._algorithms.remove(algorithm)

    def index(self, algorithm):
        return self._algorithms.index(algorithm)

    def __getitem__(self, index):
        return self._algorithms[index]

    def __setitem__(self, index, algo):
        self._algorithms[index] = algo

    def __iter__(self):
        self._currentIndex = 0
        return self

    def __next__(self):
        if self._currentIndex >= len(self._algorithms):
            raise StopIteration
        else:
            algorithm = self._algorithms[self._currentIndex]
            self._currentIndex += 1
            return algorithm

    def __len__(self):
        return len(self._algorithms)


class Algorithm(AbstractAlgorithm):
    currentValueChanged = Signal()
    enabledChanged = Signal()

    def __init__(self,
                 title: str,
                 informativeText: str,
                 parent: QObject = None) -> None:
        super().__init__(title, informativeText, parent)
        self._widgets = QStandardItemModel(self)
        self._enabled = True

    @classmethod
    def load(cls, data: dict):
        algo = cls()
        for i in range(len(data['types'])):
            widgetType = str(data['types'][i]).split('.')[1]
            class_to_call = globals()[widgetType]
            item = class_to_call.load(data['widgets'][i])
            algo.addWidget(item)
        algo._enabled = data['enabled']
        algo._title = data['title']
        algo._informativeText = data['informativeText']
        return algo

    def toPlainData(self):
        widgets = []
        types = []
        for i in range(self._widgets.rowCount()):
            item = self._widgets.item(i, 0).data(Qt.UserRole)
            print(item._type)
            widgets.append(item.toPlainData())
            types.append(item._type)
        return {
            'title': self._title,
            'informativeText': self._informativeText,
            'widgets': widgets,
            'enabled': self._enabled,
            'types': types
        }

    def apply(self, image):
        return image

    def __deepcopy__(self, memo):
        if memo is None:
            memo = {}
        result = self.newInstance()
        memo[id(self)] = result
        result._widgets.clear()
        for k, v in self.__dict__.items():
            if k == '_widgets':
                for i in range(self._widgets.rowCount()):
                    item = self._widgets.data(self._widgets.index(i, 0),
                                              Qt.UserRole)
                    if issubclass(type(item), AbstractWidget):
                        result.addWidget(copy.deepcopy(item, memo))
                    elif item is StackLayout:
                        result.addLayout(copy.deepcopy(item, memo))
            elif k.startswith("_"):
                setattr(result, k, copy.deepcopy(v, memo))
        return result

    @Slot(result=QObject)
    def clone(self):
        return copy.deepcopy(self)

    @Slot(result=QObject)
    def newInstance(self):
        return self.__class__()

    def addWidget(self, widget: AbstractWidget):
        item = QStandardItem()
        item.setData(widget, Qt.UserRole)
        item.setData(widget.title, Qt.DisplayRole)
        widget.currentValueChanged.connect(
            lambda: self.currentValueChanged.emit())
        self._widgets.appendRow(item)

    def addLayout(self, layout):
        if type(layout) is StackLayout:
            item = QStandardItem()
            item.setData(layout, Qt.UserRole)
            for model in layout._layouts:
                for row in range(model.rowCount()):
                    widget: AbstractWidget = model.data(
                        model.index(row, 0), Qt.UserRole)
                    widget.currentValueChanged.connect(
                        self.currentValueChanged)
            self._widgets.appendRow(item)
        else:
            raise TypeError("Unsupported layout type")

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
        self._rootItem = AlgorithmGroup(
            None, itemOrder=AlgorithmGroup.ItemOrder.KeepOrder)

    def columnCount(self, parent: QModelIndex = None) -> int:
        return 1

    def rowCount(self, parent: QModelIndex = QModelIndex()) -> int:
        parent_item: AlgorithmGroup = self._getItem(parent)
        if not issubclass(type(parent_item), AlgorithmGroup):
            return 0
        return len(parent_item)

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
        if role == Qt.UserRole:
            parent_item = item.parent(
            )  # parent_item here must be AlgorithmGroup
            if parent_item[index.row()] != value:
                if not type(parent_item[index.row()]) is AbstractAlgorithm:
                    warnings.warn(
                        f"Index at {index} already has an item, setData() will override current item.",
                        category=UserWarning)
                parent_item[index.row()] = value
                value.setParent(parent_item)
                self.dataChanged.emit(index, index, [role])
                return True
        return False

    def parent(self, index: QModelIndex = QModelIndex()) -> QModelIndex:
        if not index.isValid():
            return QModelIndex()

        child_item: AbstractAlgorithm = index.internalPointer()
        parent_item: AlgorithmGroup = child_item.parent(
        )  # parent_item here must be AlgorithmGroup

        return self.createIndex(parent_item.index(child_item), 0, parent_item)

    def index(self, row: int, column: int,
              parent: QModelIndex = QModelIndex()) -> QModelIndex:
        parent_item: AbstractAlgorithm = self._getItem(parent)
        if not issubclass(type(parent_item), AlgorithmGroup):
            return QModelIndex()

        if 0 <= row < len(parent_item):
            return self.createIndex(row, column, parent_item[row])
        return QModelIndex()

    def insertRows(self,
                   row: int,
                   count: int,
                   parent: QModelIndex = QModelIndex()) -> bool:

        parent_item: AlgorithmGroup = self._getItem(parent)
        if not issubclass(type(parent_item), AlgorithmGroup):
            return False

        if 0 <= row <= len(parent_item) and count > 0:
            self.beginInsertRows(parent, row, row + count - 1)
            for _ in range(count):
                parent_item._algorithms.insert(
                    row, AbstractAlgorithm(parent=parent_item))
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

        if 0 <= row and row + count <= len(parent_item):
            self.beginRemoveRows(parent, row, row + count - 1)
            for _ in range(count):
                parent_item.remove(row)
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
        self.rowsInserted.connect(self.countChanged)
        self.rowsRemoved.connect(self.countChanged)

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
    countChanged = Signal()
    count = Property(int, lambda self: len(self._algorithms), notify=countChanged)

    @Slot()
    def clear(self):
        self.removeRows(0, self.count)

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
