import sys

sys.path.append("..")
from python.algo_model import *
import os
import importlib

algorithmTreeModel = AlgorithmTreeModel()
row = 0
for filename in os.listdir(os.path.dirname(__file__)):
    if filename.endswith(".py") and filename != "__init__.py":
        module_name = filename[:-3]
        module = importlib.import_module(f".{module_name}", __package__)

        if hasattr(module, "__all__"):
            for item_name in module.__all__:
                item = getattr(module, item_name)
                algorithmTreeModel.insertRow(row, QModelIndex())
                algorithmTreeModel.setData(algorithmTreeModel.index(row, 0),
                                           item, Qt.UserRole)
                row += 1

__all__ = ["algorithmTreeModel"]
