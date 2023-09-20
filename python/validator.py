from PySide6.QtGui import QIntValidator, QDoubleValidator, QRegularExpressionValidator, QValidator
from PySide6.QtCore import QObject, Signal, Property, QEnum, Slot
from typing import overload
from enum import Enum
import sys
import copy


class ValidatorExtend:

    def __init__(self):
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
        super().__init__()
        self.setParent(parent)
        self.setBottom(bottom)
        self.setTop(top)
        self._defaultValue = defaultValue

    @Slot(str, int, result=QValidator.State)
    def validate(self, input: str, pos: int):
        if not (input.isdigit() or
                (input.startswith('-') and input[1:].isdigit())):
            self.errorString = "The input value must be an integer."
            return QValidator.State.Invalid
        result = super().validate(input, pos)[0]
        if result != QValidator.State.Acceptable:
            self.errorString = f"The input value must be in range {self.bottom()}~{self.top()}."
        return result

    @Slot(str, result=str)
    def fixup(self, input: str) -> str:
        if not input.isdigit():
            return ""
        if int(input) < self.bottom():
            return str(self.bottom())
        if int(input) > self.top():
            return str(self.top())
        return super().fixup(input)

    def __deepcopy__(self, memo):
        if memo is None:
            memo = {}
        validator = self.__class__.__new__(self.__class__)
        validator.__init__()
        memo[id(self)] = validator
        validator.setBottom(self.bottom())
        validator.setTop(self.top())
        validator._defaultValue = self._defaultValue
        return validator


class DoubleValidator(QDoubleValidator, ValidatorExtend):

    def __init__(self,
                 bottom: float = float("-inf"),
                 top: float = float("inf"),
                 decimals: int = -1,
                 defaultValue=None,
                 parent: QObject = None):
        super().__init__()
        self.setParent(parent)
        self.setTop(top)
        self.setBottom(bottom)
        self.setDecimals(decimals)
        self._defaultValue = defaultValue

    @Slot(str, int, result=QValidator.State)
    def validate(self, input: str, pos: int):
        if not (input.isdecimal() or
                (input.startswith('-') and input[1:].isdecimal())):
            self.errorString = "The input value must be a decimal."
            return QValidator.State.Invalid
        result = super().validate(input, pos)[0]
        if result != QValidator.State.Acceptable:
            self.errorString = f"The input value must be in range {self.bottom()}~{self.top()}."
        return result

    @Slot(str, result=str)
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

    def __deepcopy__(self, memo):
        if memo is None:
            memo = {}
        validator = self.__class__.__new__(self.__class__)
        validator.__init__()
        memo[id(self)] = validator
        validator.setBottom(self.bottom())
        validator.setTop(self.top())
        validator.setDecimals(self.decimals())
        validator._defaultValue = self._defaultValue
        return validator


class RegularExpressionValidator(QRegularExpressionValidator, ValidatorExtend):

    def __init__(self,
                 re: str = "",
                 defaultValue=None,
                 parent: QObject = None):
        super().__init__()
        self.setParent(parent)
        self.setRegularExpression(re)
        self._defaultValue = defaultValue

    @Slot(str, int, result=QValidator.State)
    def validate(self, input: str, pos: int):
        result = super().validate(input, pos)[0]
        if result != QValidator.State.Acceptable:
            self._errorString = "Mismatch the requirements."
        return result

    @Slot(str, result=str)
    def fixup(self, input: str) -> str:
        if not self._defaultValue is None:
            return str(self._defaultValue)
        return super().fixup(input)

    def __deepcopy__(self, memo):
        if memo is None:
            memo = {}
        validator = self.__class__.__new__(self.__class__)
        validator.__init__()
        memo[id(self)] = validator
        validator.setRegularExpression(self.regularExpression())
        validator._defaultValue = self._defaultValue
        return validator
