from typing import Optional
from PySide6.QtCore import QObject, Property, Signal, QEnum
from PySide6.QtGui import QValidator
from enum import Enum


class AbstractWidget(QObject):

    @QEnum
    class WidgetType(Enum):
        ComboBox, LineEdit, SpinBox, Slider, Selector = range(5)

    dataChanged = Signal(str)

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._title = None
        self._informativeText = None
        self._currentValue = None
        self._defaultValue = None
        self._type = None

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

    type = Property(WidgetType, lambda self: self._type, constant=True)

    @Property("QVariant")
    def currentValue(self):
        if self._currentValue == None:
            self._currentValue = self._defaultValue
        return self._currentValue

    @currentValue.setter
    def currentValue(self, currentValue):
        if self._currentValue != currentValue:
            self._currentValue = currentValue
            self.dataChanged.emit("currentValue")

    defaultValue = Property("QVariant", lambda self: self._defaultValue)

    @defaultValue.setter
    def defaultValue(self, defaultValue):
        if self._defaultValue != defaultValue:
            self._defaultValue = defaultValue
            self.dataChanged.emit("defaultValue")


class ComboBox(AbstractWidget):

    class Pair(QObject):

        def __init__(self,
                     label,
                     tip=None,
                     parent: QObject | None = None) -> None:
            super().__init__(parent)
            self._label = label
            self._tip = tip

        labelChanged = Signal()
        label = Property(str, lambda self: self._label)

        @label.setter
        def label(self, lable):
            if self._label != lable:
                self._label = lable
                self.labelChanged()

        tipChanged = Signal()
        tip = Property(str, lambda self: self._tip)

        @tip.setter
        def tip(self, lable):
            if self._tip != lable:
                self._tip = lable
                self.tipChanged()

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._labelList = []
        self._type = AbstractWidget.WidgetType.ComboBox.value

    labelList = Property(list, lambda self: self._labelList)

    @labelList.setter
    def labelList(self, labelList):
        if self._labelList != labelList:
            self._labelList = labelList
            self.dataChanged.emit("labelList")


class Slider(AbstractWidget):

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._range = ()
        self._step = 0
        self._tickInterval = 0
        self._type = AbstractWidget.WidgetType.Slider.value

    range = Property(tuple, lambda self: self._range)

    @range.setter
    def range(self, range):
        if self._range != range:
            self._range = range
            self.dataChanged.emit("range")

    step = Property(float, lambda self: self._step)

    @step.setter
    def step(self, step):
        if self._step != step:
            self._step = step
            self.dataChanged.emit("step")

    tickIntweval = Property(float, lambda self: self._tickInterval)

    @tickIntweval.setter
    def tickIntweval(self, tickIntweval):
        if self._tickInterval != tickIntweval:
            self._tickInterval = tickIntweval
            self.dataChanged.emit("tickIntweval")


class LineEdit(AbstractWidget):

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._placeholder = ""
        self._maxLength = 0
        self._validator = QValidator()
        self._type = AbstractWidget.WidgetType.LineEdit.value

    placeholder = Property(str, lambda self: self._placeholder)

    @placeholder.setter
    def placeholder(self, placeholder):
        if self._placeholder != placeholder:
            self._placeholder = placeholder
            self.dataChanged.emit("placeholder")

    maxLength = Property(int, lambda self: self._maxLength)

    @maxLength.setter
    def maxLength(self, maxLength):
        if self._maxLength != maxLength:
            self._maxLength = maxLength
            self.dataChanged.emit("maxLength")

    validator = Property(QValidator, lambda self: self._validator)

    @validator.setter
    def validator(self, validator):
        if self._validator != validator:
            self._validator = validator
            self.dataChanged.emit("validator")


class SpinBox(AbstractWidget):

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._range = ()
        self._precision = 0
        self._type = AbstractWidget.WidgetType.SpinBox.value

    range = Property(tuple, lambda self: self._range)

    @range.setter
    def range(self, range):
        if self._range != range:
            self._range = range
            self.dataChanged.emit("range")

    precision = Property(float, lambda self: self._precision)

    @precision.setter
    def precision(self, precision):
        if self._precision != precision:
            self._precision = precision
            self.dataChanged.emit("precision")


class Selector(AbstractWidget):

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._type = AbstractWidget.WidgetType.Selector.value