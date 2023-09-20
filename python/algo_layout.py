from typing import Optional
from PySide6.QtCore import QObject, Slot, Signal, Property, QAbstractListModel, Qt
from PySide6.QtGui import QStandardItem, QStandardItemModel
from .algo_widgets import WidgetType, AbstractWidget
from typing import Sequence
import copy


class StackLayout(QObject):

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._layouts = []
        self._currentIndex = -1
        self._type = WidgetType.StackLayout

    def addWidget(self, layoutIndex: int, widget: AbstractWidget):
        self.addWidgets(layoutIndex, [widget])

    def addWidgets(self, layoutIndex: int, widgets: Sequence[AbstractWidget]):
        self._layouts[layoutIndex].appendRow(self._createItems(widgets))

    def _createItems(self, widgets):

        def createItem(widget):
            item = QStandardItem()
            item.setData(widget, Qt.UserRole)
            return item

        return [createItem(widget) for widget in widgets]

    def addLayout(self, widgets: Sequence[AbstractWidget]):
        model = QStandardItemModel(self)
        model.appendRow(self._createItems(widgets))
        self._layouts.append(model)

    def widgetAt(self, index: int, row: int):
        child = self._layouts.index(row, 0)
        if not child.isValid():
            raise IndexError("Index out of range")
        return self._layouts[index].data(child, Qt.UserRole)

    def __deepcopy__(self, memo):
        if memo is None:
            memo = {}
        layout = self.__class__.__new__(self.__class__)
        layout.__init__()
        layout._currentIndex = self._currentIndex
        memo[id(self)] = layout
        for i in range(len(self._layouts)):
            model: QStandardItemModel = self._layouts[i]
            layout.addLayout([
                copy.deepcopy(
                    model.data(model.index(row, 0),
                                Qt.UserRole), memo)
                for row in range(model.rowCount())
            ])
            
        return layout

    type = Property(int, lambda self: self._type.value, constant=True)

    layouts = Property(list, lambda self: self._layouts, constant=True)

    currentIndexChanged = Signal()
    currentIndex = Property(int,
                            lambda self: self._currentIndex,
                            notify=currentIndexChanged)

    @currentIndex.setter
    def currentIndex(self, index):
        if self._currentIndex != index:
            self._currentIndex = index
            self.currentIndexChanged.emit()
