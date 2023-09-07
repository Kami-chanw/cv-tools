from typing import Dict, Optional, Union
from PySide6.QtCore import QAbstractItemModel, QObject, Property, Signal, QModelIndex, QEnum, Qt, QByteArray, Slot
from enum import Enum
import warnings

@QEnum
class AlgorithmRole(Enum):
    ItemTypeRole, InformativeRole, EnabledRole = range(Qt.UserRole + 1,
                                                       Qt.UserRole + 4)

    @staticmethod
    def defaultRoleNames():
        return {
            AlgorithmRole.ItemTypeRole.value: "item",
            AlgorithmRole.InformativeRole.value: "informativeText",
            AlgorithmRole.EnabledRole.value: "enabled"
        }

    @classmethod
    def lastRoleValue(cls):
        return AlgorithmRole.EnabledRole.value


class AbstractAlgorithm(QObject):

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self._data = {}
        self._prerequisite = []

    @Property(str)
    def title(self):
        return self._data[Qt.DisplayRole]

    @title.setter
    def title(self, title: str):
        self._data[Qt.DisplayRole] = title

    @Property(str)
    def informativeText(self):
        return self._data[AlgorithmRole.InformativeRole.value]
    
    @informativeText.setter
    def informativeText(self, text :str):
        self._data[AlgorithmRole.InformativeRole.value] = text

    @Property(list, constant=True) 
    def prerequisite(self):
        return self._prerequisite

    def data(self, role: int):
        if role in self._data:
            return self._data[role]
        return None

    def setData(self, role, value):
        if role in self._data and self._data[role] == value:
            return False
        self._data[role] = value
        return True


class AlgorithmGroup(AbstractAlgorithm):

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self._algorithms = []

    @Property(list, constant=True)
    def algorithms(self):
        return self._algorithms


class Algorithm(AbstractAlgorithm):
    enabledChanged = Signal()

    @QEnum
    class WidgetType(Enum):
        Text, ComboBox = range(2)

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self._widgets = {}

    def apply(self, image):
        return None

    def addWidget(self, widgetType: WidgetType, callback=None, **kwargs):
        pass


class AlgorithmModel(QAbstractItemModel):

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self._rootItem = AlgorithmGroup()
        self._roleNames = super().roleNames()
        self.addRoleNames(AlgorithmRole.defaultRoleNames())

    def columnCount(self, parent: QModelIndex = None) -> int:
        return 1

    def rowCount(self, parent: QModelIndex = QModelIndex()) -> int:
        parent_item: AlgorithmGroup = self._getItem(parent)
        if not issubclass(type(parent_item), AlgorithmGroup):
            return 0
        return len(parent_item.algorithms)

    def roleNames(self):
        return self._roleNames

    def addRoleNames(self, roleNameDict: Dict[int, QByteArray]):
        for role, name in roleNameDict.items():
            if not type(role) is int:
                raise TypeError("The type of key in param 0 should be int")
            if role in self._roleNames:
                raise ValueError(
                    f"Duplicate role: previous name {self._roleNames[role]} and current is {name}"
                )
            self._roleNames[role] = name

    def data(self, index: QModelIndex, role: int = None):
        if not index.isValid():
            return None
        if role == AlgorithmRole.ItemTypeRole.value:
            return index.internalPointer()
        return index.internalPointer().data(role)

    def setData(self, index: QModelIndex, value, role: int) -> bool:
        if not index.isValid() or not role in self._roleNames:
            return False
        item: AbstractAlgorithm = index.internalPointer()
        if role == AlgorithmRole.ItemTypeRole.value:
            parent_item = item.parent(
            )  # parent_item here must be AlgorithmGroup
            if parent_item.algorithms[index.row()] == value:
                result = False
            else:
                if not type(parent_item.algorithms[
                        index.row()]) is AbstractAlgorithm:
                    warnings.warn(
                        f"Index at {index} already has an item, setData() will override current item.",
                        category=UserWarning)
                parent_item.algorithms[index.row()] = value
                value.setParent(parent_item)
                result = True
        else:
            result = item.setData(value, role)

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
