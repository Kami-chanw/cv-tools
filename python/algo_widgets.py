from typing import Optional
from PySide6.QtCore import QObject, Property, Signal, QEnum, Qt, Slot
from PySide6.QtGui import QValidator, QStandardItem, QStandardItemModel
from enum import Enum


class AbstractWidget(QObject):

    @QEnum
    class WidgetType(Enum):
        ComboBox, LineEdit, SpinBox, Slider, Selector = range(5)

    dataChanged = Signal(str)

    def __init__(self,
                 title,
                 informativeText=None,
                 type: WidgetType = None,
                 parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._title = title
        self._informativeText = informativeText
        self._currentValue = None
        self._defaultValue = None
        self._type = type

    title = Property(str, lambda self: self._title, notify=dataChanged)

    @title.setter
    def title(self, title):
        if self._title != title:
            self._title = title
            self.dataChanged.emit("title")

    informativeText = Property(str,
                               lambda self: self._informativeText,
                               notify=dataChanged)

    @informativeText.setter
    def informativeText(self, informativeText):
        if self._informativeText != informativeText:
            self._informativeText = informativeText
            self.dataChanged.emit("informativeText")

    type = Property(int, lambda self: self._type.value, constant=True)

    @Property("QVariant", notify=dataChanged)
    def currentValue(self):
        if self._currentValue == None:
            self._currentValue = self._defaultValue
        return self._currentValue

    @currentValue.setter
    def currentValue(self, currentValue):
        if self._currentValue != currentValue:
            self._currentValue = currentValue
            self.dataChanged.emit("currentValue")

    defaultValue = Property("QVariant",
                            lambda self: self._defaultValue,
                            notify=dataChanged)

    @defaultValue.setter
    def defaultValue(self, defaultValue):
        if self._defaultValue != defaultValue:
            self._defaultValue = defaultValue
            self.dataChanged.emit("defaultValue")


class ComboBox(AbstractWidget):

    def __init__(self,
                 title,
                 informativeText=None,
                 parent: QObject | None = None) -> None:
        super().__init__(title, informativeText,
                         AbstractWidget.WidgetType.ComboBox, parent)
        self._labelModel = QStandardItemModel(self)

    def append(self, label, tip=None):
        self.insert(self._labelModel.rowCount(), label, tip)

    def insert(self, idx, label, tip=None):
        item = QStandardItem()
        item.setData(label, Qt.DisplayRole)
        if tip:
            item.setData(tip, Qt.ToolTipRole)
        self._labelModel.insertRow(idx, item)

    def remove(self, idx):
        self._labelModel.removeRow(idx)

    @Property(int, constant=True)
    def defaultIndex(self):
        for index in range(self._labelModel.rowCount()):
            if self._labelModel.data(self._labelModel.index(index, 0),
                                     Qt.DisplayRole) == self._defaultValue:
                return index
        return -1

    labelModel = Property(QObject,
                          lambda self: self._labelModel,
                          constant=True)


class Slider(AbstractWidget):

    def __init__(self,
                 title,
                 informativeText=None,
                 parent: QObject | None = None) -> None:
        super().__init__(title, informativeText,
                         AbstractWidget.WidgetType.Slider, parent)
        self._minimum = 0.0
        self._stepSize = 0.0
        self._maximum = 0.0

    minimum = Property(float, lambda self: self._minimum)

    @minimum.setter
    def minimum(self, minimum):
        if self._minimum != minimum:
            self._minimum = minimum
            self.dataChanged.emit("minimum")

    stepSize = Property(float, lambda self: self._step)

    @stepSize.setter
    def stepSize(self, step):
        if self._stepSize != step:
            self._stepSize = step
            self.dataChanged.emit("step")

    maximum = Property(float,
                            lambda self: self._maximum,
                            notify=AbstractWidget.dataChanged)

    @maximum.setter
    def maximum(self, maximum):
        if self._maximum != maximum:
            self._maximum = maximum
            self.dataChanged.emit("maximum")


class LineEdit(AbstractWidget):

    def __init__(self,
                 title,
                 informativeText=None,
                 parent: QObject | None = None) -> None:
        super().__init__(title, informativeText,
                         AbstractWidget.WidgetType.LineEdit, parent)
        self._placeholderText = ""
        self._maximumLength = 0
        self._validator = QValidator()

    placeholderText = Property(str,
                           lambda self: self._placeholderText,
                           notify=AbstractWidget.dataChanged)

    @placeholderText.setter
    def placeholderText(self, placeholderText):
        if self._placeholderText != placeholderText:
            self._placeholderText = placeholderText
            self.dataChanged.emit("placeholderText")

    maximumLength = Property(int,
                         lambda self: self._maximumLength,
                         notify=AbstractWidget.dataChanged)

    @maximumLength.setter
    def maximumLength(self, maximumLength):
        if self._maximumLength != maximumLength:
            self._maximumLength = maximumLength
            self.dataChanged.emit("maximumLength")

    validator = Property(QValidator,
                         lambda self: self._validator,
                         notify=AbstractWidget.dataChanged)

    @validator.setter
    def validator(self, validator):
        if self._validator != validator:
            self._validator = validator
            self.dataChanged.emit("validator")


class SpinBox(AbstractWidget):

    def __init__(self,
                 title,
                 informativeText=None,
                 parent: QObject | None = None) -> None:
        super().__init__(title, informativeText,
                         AbstractWidget.WidgetType.SpinBox, parent)
        self._range = ()
        self._precision = 0

    range = Property(tuple, lambda self: self._range)

    @range.setter
    def range(self, range):
        if self._range != range:
            self._range = range
            self.dataChanged.emit("range")

    precision = Property(float,
                         lambda self: self._precision,
                         notify=AbstractWidget.dataChanged)

    @precision.setter
    def precision(self, precision):
        if self._precision != precision:
            self._precision = precision
            self.dataChanged.emit("precision")


class Selector(AbstractWidget):

    def __init__(self,
                 title,
                 informativeText=None,
                 parent: QObject | None = None) -> None:
        super().__init__(title, informativeText,
                         AbstractWidget.WidgetType.Selector, parent)
