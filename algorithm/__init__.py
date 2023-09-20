import sys

sys.path.append("..")
from python.algo_model import *
import os
import importlib

_algorithms = {}
_algorithmTree = AlgorithmGroup("",
                                itemOrder=AlgorithmGroup.ItemOrder.KeepOrder)

for filename in os.listdir(os.path.dirname(__file__)):
    if filename.endswith(".py") and filename != "__init__.py":
        module_name = filename[:-3]
        module = importlib.import_module(f".{module_name}", __package__)

        if hasattr(module, "__all__"):
            for item_name in module.__all__:

                def mergeAlgoTree(item, targetGroup: AlgorithmGroup):
                    inserter = targetGroup.append if targetGroup.itemOrder == AlgorithmGroup.ItemOrder.KeepOrder else targetGroup.insert
                    if issubclass(type(item), Algorithm):
                        if item.title in _algorithms:
                            raise ValueError(
                                f"Duplicate algorithm {item.title} in {filename} and {_algorithms[item.title]}"
                            )
                        else:
                            _algorithms[item.title] = filename
                            inserter(item)
                    elif issubclass(type(item), AlgorithmGroup):

                        def searchGroup(group):
                            for algo in group:
                                if issubclass(type(algo), AlgorithmGroup):
                                    if algo.title == item.title:
                                        if algo.itemOrder != item.itemOrder:
                                            raise ValueError(
                                                f"Same title but different itemOrder for {item.title} in {filename}"
                                            )
                                        return algo
                                    searchGroup(algo)
                            return None

                        result = searchGroup(targetGroup)
                        if result is None:
                            _algorithms[item.title] = filename
                            inserter(item)
                        else:
                            for algo in item:
                                mergeAlgoTree(algo, result)

                mergeAlgoTree(getattr(module, item_name), _algorithmTree)

algorithmTreeModel = AlgorithmTreeModel()
algorithmTreeModel._rootItem = _algorithmTree
algorithmTreeModel.data(algorithmTreeModel.index(0,0,algorithmTreeModel.index(0,0)), Qt.DisplayRole)
__all__ = ["algorithmTreeModel"]
