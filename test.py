from typing import Optional
from PySide6.QtCore import Property, QObject, QEnum, Qt
from enum import Enum

class A(QObject):

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._pp = ""
        self.pp.notify.emit()

    @Property(str)
    def pp(self):
        return self._pp
    
    @pp.setter
    def pp(self, s):
        self._pp = s

a = A()

