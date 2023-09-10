from PySide6.QtCore import QObject
from python.algo_model import Algorithm, AlgorithmGroup
from python.algo_widgets import ComboBox
import cv2 as cv
import numpy as np


class CvtColor(Algorithm):

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self.title = "Convert Color Space"
        self.informativeText = "Convert color space to a specific one."
        self.combobox = ComboBox()
        self.combobox.labelList = [
            ComboBox.Pair("HSV", "Convert color space from BGR to HSV"),
            ComboBox.Pair("RGB", "Convert color space from BGR to RGB"),
            ComboBox.Pair("Gray",
                          "Convert color space from BGR to gray scale"),
            ComboBox.Pair("None")
        ]
        self.combobox.defaultValue = "None"
        self.addWidget(self.combobox)

    def apply(self, image):
        if self.combobox.currentValue == None:
            return image
        if self.combobox.currentValue == "HSV":
            return cv.cvtColor(image, cv.COLOR_BGR2HSV)
        if self.combobox.currentValue == "RGB":
            return cv.cvtColor(image, cv.COLOR_BGR2RGB)
        if self.combobox.currentValue == "Gray":
            return cv.cvtColor(image, cv.COLOR_BGR2GRAY)


cvtColor = CvtColor()
group = AlgorithmGroup()
group.title = "Image Effects"
group.algorithms.append(cvtColor)
__all__ = ["group"]