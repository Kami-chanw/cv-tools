from PySide6.QtCore import QObject
from python.algo_model import Algorithm, AlgorithmGroup
from python.algo_widgets import ComboBox, LineEdit
from python.algo_layout import StackLayout
from python.validator import RegularExpressionValidator
import cv2


class Morph(Algorithm):

    def __init__(self, parent: QObject = None) -> None:
        super().__init__("Morph", "Morphological operations", parent)

        self.operation = ComboBox("Operation")
        self.operation.append(
            "Erosion", "Erodes away the boundaries of the foreground object")
        self.operation.append(
            "Dilation", "Adds pixels to the boundaries of objects in an image")
        self.operation.append("Opening", "An erosion followed by a dilation")
        self.operation.append("Closing", "A dilation followed by an erosion")
        self.operation.append(
            "Gradient",
            "The difference between dilation and erosion of an image")
        self.operation.append(
            "Top-hat",
            "The difference between the input image and its opening")
        self.operation.append(
            "Black-hat",
            "The difference between the closing of the input image and the input image itself"
        )
        self.operation.append("None")
        self.operation.defaultValue = "None"
        self.addWidget(self.operation)

        self.kernelShape = ComboBox(
            "Kernel Shape",
            "Specify a shape used to probe the image at all points")
        self.kernelShape.append("Rectangular", "Scan in square pattern")
        self.kernelShape.append("Cross", "Scan in plus(+) pattern")
        self.kernelShape.append("Ellipse", "Scan in circular pattern")
        self.kernelShape.defaultValue = "Rectangular"
        self.addWidget(self.kernelShape)

        self.kernalSize = ComboBox("Kernel Size",
                                   "The size of convolution kernel")
        self.kernalSize.extend([f"{n}x{n}" for n in range(1, 10, 2)])
        self.kernalSize.defaultValue = "5x5"
        self.addWidget(self.kernalSize)

    def apply(self, img):

        op = self.operation.currentValue
        kshape = self.kernelShape.currentValue
        ksize = int(self.kernalSize.currentValue[0])

        if op == "None":
            return img

        # parse kernal shape
        if kshape == "Rectangular":
            kshape = cv2.MORPH_ELLIPSE
        elif kshape == "Cross":
            kshape = cv2.MORPH_CROSS
        if kshape == "Ellipse":
            kshape = cv2.MORPH_RECT

        # parse operation type
        if op == "Erosion":
            op = cv2.MORPH_ERODE
        elif op == "Dilation":
            op = cv2.MORPH_DILATE
        elif op == "Opening":
            op = cv2.MORPH_OPEN
        elif op == "Closing":
            op = cv2.MORPH_CLOSE
        elif op == "Gradient":
            op = cv2.MORPH_GRADIENT
        elif op == "Top-hat":
            op = cv2.MORPH_TOPHAT
        elif op == "Black-hat":
            op = cv2.MORPH_BLACKHAT

        return cv2.morphologyEx(
            img, op, cv2.getStructuringElement(kshape, (ksize, ksize)))


group = AlgorithmGroup("Basic Image Effects")
group.insert(Morph())

__all__ = ["group"]
