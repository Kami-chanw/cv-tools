from PySide6.QtCore import QObject
from python.algo_model import Algorithm, AlgorithmGroup
import cv2 as cv
import numpy as np

class CvtColor(Algorithm):
    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self.title = "Convert Color Space"
        self.informativeText = "Convert color space to HSV, RGB, BGR..."
    
    def apply(self, image):
        # cv.cvtColor(image,)
        pass

cvtColor = CvtColor()
group = AlgorithmGroup()
group.title = "Image Effects"
group.algorithms.append(cvtColor)
__all__ = ["group"]