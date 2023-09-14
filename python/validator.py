from PySide6.QtGui import QIntValidator, QDoubleValidator, QRegularExpressionValidator, QValidator
from PySide6.QtCore import QObject, Signal, Property, QEnum, Slot
from typing import overload
from enum import Enum
import sys


class ValidatorExtend:

    def __init__(self, parent=None):
        # super().__init__(parent)
        self._defaultValue = None
        self._errorString = None

    errorStringChanged = Signal()
    errorString = Property(str,
                           lambda self: self._errorString,
                           notify=errorStringChanged)

    @errorString.setter
    def errorString(self, string):
        if self._errorString != string:
            self._errorString = string
            self.errorStringChanged.emit()

    defaultValueChanged = Signal()
    defaultValue = Property(str,
                            lambda self: self._defaultValue,
                            notify=defaultValueChanged)

    @defaultValue.setter
    def defaultValue(self, string):
        if self._defaultValue != string:
            self._defaultValue = string
            self.defaultValueChanged.emit()


class IntValidator(QIntValidator, ValidatorExtend):

    def __init__(self,
                 bottom: int = -sys.maxsize - 1,
                 top: int = sys.maxsize,
                 defaultValue=None,
                 parent: QObject = None):
        super().__init__(parent)
        self.setBottom(bottom)
        self.setTop(top)
        self._defaultValue = defaultValue

    @Slot(str, int, result=object)
    def validate(self, input: str, pos: int) -> object:
        if not input.isdigit():
            self.errorString = "The input value must be an integer."
            return QValidator.State.Invalid
        if super().validate(input, pos) == QValidator.State.Invalid:
            self.errorString = f"The input value must be in range {self.bottom()}~{self.top()}."
        return super().validate(input, pos)

    @Slot(str,result=str)
    def fixup(self, input: str) -> str:
        if not self._defaultValue is None:
            return str(self._defaultValue)
        if not input.isdigit():
            return ""
        if int(input) < self.bottom():
            return str(self.bottom())
        if int(input) > self.top():
            return str(self.top())
        return super().fixup(input)


class DoubleValidator(QDoubleValidator, ValidatorExtend):

    def __init__(self,
                 bottom: float = float("-inf"),
                 top: float = float("inf"),
                 decimals: int = -1,
                 defaultValue=None,
                 parent: QObject = None):
        super().__init__(bottom=bottom,
                         top=top,
                         decimals=decimals,
                         parent=parent)
        self._defaultValue = defaultValue

    def validate(self, input: str, pos: int) -> object:
        if not input.isdecimal():
            self.errorString = "The input value must be a decimal."
            return QValidator.State.Invalid
        if super().validate(input, pos) == QValidator.State.Invalid:
            self.errorString = f"The input value must be in range {self.bottom()}~{self.top()}."
        return super().validate(input, pos)

    def fixup(self, input: str) -> str:
        if not self._defaultValue is None:
            return str(self._defaultValue)
        if not input.isdigit():
            return ""
        if float(input) < self.bottom():
            return str(self.bottom())
        if float(input) > self.top():
            return str(self.top())
        return super().fixup(input)


class RegularExpressionValidator(QRegularExpressionValidator, ValidatorExtend):

    def __init__(self,
                 re: str = "",
                 defaultValue=None,
                 parent: QObject = None):
        super().__init__(re=re, parent=parent)
        self._defaultValue = defaultValue

    def validate(self, input: str, pos: int) -> object:
        if super().validate(input, pos) == QValidator.State.Invalid:
            self._errorString = "Unmatch the requirements."
        return super().validate(input, pos)

    def fixup(self, input: str) -> str:
        if not self._defaultValue is None:
            return str(self._defaultValue)
        return super().fixup(input)