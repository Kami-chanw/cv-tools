from typing import Optional
from PySide6.QtCore import Property, QObject, QEnum, Qt
from enum import Enum
@QEnum
class AlgorithmRole(Enum):
    InformativeRole, EnabledRole = range(Qt.UserRole + 1, Qt.UserRole + 3)

    @staticmethod
    def defaultRoleNames():
        return {
            AlgorithmRole.InformativeRole.value: "informativeText",
            AlgorithmRole.EnabledRole.value: "enabled"
        }
    
    @classmethod
    def roleNames(cls):
        return {}

    @classmethod
    def lastRoleValue(cls):
        return AlgorithmRole.EnabledRole.value

print(Qt.UserRole + 1 == AlgorithmRole.InformativeRole.value)