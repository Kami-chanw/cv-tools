from typing import Optional
from PySide6.QtCore import QObject, Property, Signal, QEnum, Qt, Slot
from PySide6.QtGui import QValidator, QStandardItem, QStandardItemModel
from PySide6.QtQml import QJSValue
from python.validator import *
from enum import Enum
import sys


class AbstractWidget(QObject):

    @QEnum
    class WidgetType(Enum):
        ComboBox, LineEdit, SpinBox, Slider, Selector, CheckBox = range(6)

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

    titleChanged = Signal()
    title = Property(str, lambda self: self._title, notify=titleChanged)

    @classmethod
    def load(cls, data):
        pass
        '''
        widget = cls(data['title'], data['informativeText'], data['type'])
        widget._currentValue = data['currentValue']
        widget._defaultValue = data['defaultValue']
        return widget
        '''

    def toPlainData(self):
        data = dict()
        data['title'] = self._title
        data['informativeText'] = self._informativeText
        data['currentValue'] = self._currentValue
        data['defaultValue'] = self._defaultValue
        data['type'] = self._type
        return data

    @title.setter
    def title(self, title):
        if self._title != title:
            self._title = title
            self.titleChanged.emit()

    informativeTextChanged = Signal()
    informativeText = Property(str,
                               lambda self: self._informativeText,
                               notify=informativeTextChanged)

    @informativeText.setter
    def informativeText(self, informativeText):
        if self._informativeText != informativeText:
            self._informativeText = informativeText
            self.informativeTextChanged.emit()

    type = Property(int, lambda self: self._type.value, constant=True)

    currentValueChanged = Signal()

    @Property("QVariant", notify=currentValueChanged)
    def currentValue(self):
        if type(self._currentValue) is QJSValue:
            return self._currentValue.toVariant()
        if self._currentValue is None:
            self._currentValue = self._defaultValue
        return self._currentValue

    @currentValue.setter
    def currentValue(self, currentValue):
        if self._currentValue != currentValue:
            self._currentValue = currentValue
            self.currentValueChanged.emit()

    defaultValueChanged = Signal()
    defaultValue = Property("QVariant",
                            lambda self: self._defaultValue,
                            notify=defaultValueChanged)

    @defaultValue.setter
    def defaultValue(self, defaultValue):
        if self._defaultValue != defaultValue:
            self._defaultValue = defaultValue
            self.defaultValueChanged.emit()


class ComboBox(AbstractWidget):

    def __init__(self,
                 title,
                 informativeText=None,
                 parent: QObject | None = None) -> None:
        super().__init__(title, informativeText,
                         AbstractWidget.WidgetType.ComboBox, parent)
        self._labelModel = QStandardItemModel(self)

    @classmethod
    def load(cls, data):
        print(data)
        widget = cls(data['title'], data['informativeText'])
        widget._currentValue = data['currentValue']
        widget._defaultValue = data['defaultValue']
        for item in data['labels']:
            # print(item)
            widget.append(item[0], item[1])
        # print(widget._labelModel.item(0, 0).data(Qt.DisplayRole))
        return widget

    def toPlainData(self):
        data = AbstractWidget.toPlainData(self)
        labels = []
        for i in range(self._labelModel.rowCount()):
            item = self._labelModel.item(i, 0)
            # change item to the type can be pickled
            label = item.data(Qt.DisplayRole)
            tip = item.data(Qt.ToolTipRole)
            print([label, tip])
            labels.append([label, tip])
        data['labels'] = labels
        return data

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

    minimumChanged = Signal()
    minimum = Property(float,
                       lambda self: self._minimum,
                       notify=minimumChanged)

    @classmethod
    def load(cls, data):
        widget = cls(data['title'], data['informativeText'])
        widget._minimum = data['minimum']
        widget._maximum = data['maximum']
        widget.stepSize = data['stepSize']
        return widget

    def toPlainData(self):
        data = AbstractWidget.toPlainData(self)
        data['minimum'] = self._minimum
        data['maximum'] = self._maximum
        data['stepSize'] = self._stepSize
        return data

    @minimum.setter
    def minimum(self, minimum):
        if self._minimum != minimum:
            self._minimum = minimum
            self.minimumChanged.emit()

    stepSizeChanged = Signal()
    stepSize = Property(float,
                        lambda self: self._stepSize,
                        notify=stepSizeChanged)

    @stepSize.setter
    def stepSize(self, step):
        if self._stepSize != step:
            self._stepSize = step
            self.stepSizeChanged.emit()

    maximumChanged = Signal()
    maximum = Property(float,
                       lambda self: self._maximum,
                       notify=maximumChanged)

    @maximum.setter
    def maximum(self, maximum):
        if self._maximum != maximum:
            self._maximum = maximum
            self.maximumChanged.emit()


class LineEdit(AbstractWidget):

    def __init__(self,
                 title,
                 informativeText=None,
                 parent: QObject | None = None) -> None:
        super().__init__(title, informativeText,
                         AbstractWidget.WidgetType.LineEdit, parent)
        self._placeholderText = ""
        self._maximumLength = -1
        self._validator = None

    @classmethod
    def load(cls, data):
        widget = cls(data['title'], data['informativeText'])
        widget._placeholderText = data['placeholderText']
        widget._maximumLength = data['maximumLength']
        # to load self._validator
        # TODO
        return widget

    def toPlainData(self):
        data = AbstractWidget.toPlainData(self)
        data['placeholderText'] = self._placeholderText
        data['maximumLength'] = self._maximumLength
        # to save self._validator
        # TODO
        return data

    placeholderTextChanged = Signal()
    placeholderText = Property(str,
                               lambda self: self._placeholderText,
                               notify=placeholderTextChanged)

    @placeholderText.setter
    def placeholderText(self, placeholderText):
        if self._placeholderText != placeholderText:
            self._placeholderText = placeholderText
            self.placeholderTextChanged.emit()

    maximumLengthChanged = Signal()
    maximumLength = Property(int,
                             lambda self: self._maximumLength,
                             notify=maximumLengthChanged)

    @maximumLength.setter
    def maximumLength(self, maximumLength):
        if self._maximumLength != maximumLength:
            self._maximumLength = maximumLength
            self.maximumLengthChanged.emit()

    validatorChanged = Signal()
    validator = Property(QObject,
                         lambda self: self._validator,
                         notify=validatorChanged)

    @validator.setter
    def validator(self, validator):
        if self._validator != validator:
            self._validator = validator
            self.validatorChanged.emit()


class CheckBox(AbstractWidget):

    def __init__(self,
                 title,
                 informativeText=None,
                 parent: QObject | None = None) -> None:
        super().__init__(title, informativeText,
                         AbstractWidget.WidgetType.CheckBox, parent)
        self._text = None

    textChanged = Signal()
    text = Property(str, lambda self: self._text, notify=textChanged)

    @text.setter
    def text(self, text):
        if self._text != text:
            self._text = text
            self.textChanged.emit()

    @classmethod
    def load(cls, data):
        widget = cls(data['title'], data['informativeText'])
        widget._text = data['text']
        return widget

    def toPlainData(self):
        data = AbstractWidget.toPlainData(self)
        data['text'] = self._text
        return data


class Selector(AbstractWidget):

    class SelectorType(Enum):
        Rectangular, Polygon, Auto = range(3)

    def __init__(self,
                 selectorType: SelectorType,
                 title,
                 informativeText=None,
                 pointCount=None,
                 parent: QObject | None = None) -> None:
        super().__init__(title, informativeText,
                         AbstractWidget.WidgetType.Selector, parent)
        self._selectorType = selectorType
        self._defaultValue = []
        if selectorType == Selector.SelectorType.Rectangular:
            self._pointCount = 4
        elif selectorType == Selector.SelectorType.Polygon:
            self._pointCount = pointCount
        else:
            self._selectorType = None

    @classmethod
    def load(cls, data):
        widget = cls(Selector.SelectorType(data['selector_type']),
                     data['title'], data['informativeText'])
        widget._defaultValue = data['default_value']
        widget._pointCount = data['point_count']
        return widget

    def toPlainData(self):
        data = AbstractWidget.toPlainData(self)
        data['point_count'] = self._pointCount
        data['default_value'] = self._defaultValue
        data['selector_type'] = self._selectorType.value
        return data

    selectorType = Property(int,
                            lambda self: self._selectorType.value,
                            constant=True)

    pointCountChanged = Signal()

    @Property(int, notify=pointCountChanged)
    def pointCount(self):
        if self._selectorType == Selector.SelectorType.Rectangular:
            return 4
        return self._pointCount

    @pointCount.setter
    def pointCount(self, count):
        if self._selectorType == Selector.SelectorType.Polygon and self._pointCount != count:
            self._pointCount = count
            self.pointCountChanged.emit()
