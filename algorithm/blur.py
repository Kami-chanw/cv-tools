from PySide6.QtCore import QObject
from python.algo_model import Algorithm, AlgorithmGroup
from python.algo_widgets import ComboBox, LineEdit
from python.algo_layout import StackLayout
from python.validator import RegularExpressionValidator
import cv2


class Blur(Algorithm):

    def __init__(self, parent: QObject = None) -> None:
        super().__init__("Blur", "Blur a image in Mean, Median etc modes",
                         parent)

        self.blurType = ComboBox("Blur Type")
        self.blurType.extend(["Mean", "Median", "Gaussian"])
        self.blurType.defaultValue = "Mean"
        self.addWidget(self.blurType)

        def switchStackedLayout():
            index = -1
            if self.blurType.currentValue == "Mean":
                index = 0
            elif self.blurType.currentValue == "Gaussian":
                index = 1
            self.stackedLayout.currentIndex = index

        self.blurType.currentValueChanged.connect(switchStackedLayout)

        self.kernelSize = ComboBox("Kernel Size",
                                   "The size of convolution kernel")
        self.kernelSize.extend([f"{n}x{n}" for n in range(1, 10, 2)])
        self.kernelSize.defaultValue = "5x5"
        self.addWidget(self.kernelSize)

        self.borderType = ComboBox(
            "Border Type",
            "Specifies image boundaries while kernel is applied on image borders"
        )
        self.borderType.extend([
            ("Replicate",
             "Fills the border pixels with the copied values of the image border pixels."
             ),
            ("Reflect",
             "Fill border pixels with mirrored values of image border pixels."
             ),
            ("Reflect101",
             "Taking the pixel value of the image border as the axis, mirror and copy the filled border pixels"
             )
        ])
        self.borderType.defaultValue = "Reflect101"
        self.addWidget(self.borderType)

        # Mean
        self.anchor = LineEdit(
            "Anchor",
            "The anchor point position of the convolution kernel, ranging from -1 ~ kernel_size - 1, -1 represents the center of kernel."
        )
        self.anchor.placeholderText = "x,y"
        self.anchor.currentValue = "-1,-1"
        self.anchor.validator = RegularExpressionValidator(
            r"^-?\d+,-?\d+$", "-1,-1", self.anchor)

        # Gaussian
        self.sigma = LineEdit(
            "Standard Deviation",
            "The standard deviation(sigma) of Gaussian blur")
        self.sigma.placeholderText = "x,y"
        self.sigma.currentValue = "0,0"
        self.sigma.validator = RegularExpressionValidator(
            r'^-?\d+(\.\d+)?,-?\d+(\.\d+)?$', "0,0", self.sigma)

        self.stackedLayout = StackLayout()
        self.stackedLayout.addLayout([self.anchor])
        self.stackedLayout.addLayout([self.sigma])

        self.addLayout(self.stackedLayout)

    def apply(self, image):
        ksize = int(self.kernelSize.currentValue[0])
        if self.blurType.currentValue == 'Mean':
            x, y = self.anchor.currentValue.split(",")
            imgBlur = cv2.blur(image, (ksize, ksize), anchor=(int(x), int(y)))
        elif self.blurType.currentValue == 'Median':
            imgBlur = cv2.medianBlur(image, ksize)
        else:
            x, y = self.sigma.currentValue.split(",")
            imgBlur = cv2.GaussianBlur(image, (ksize, ksize),
                                       sigmaX=float(x),
                                       sigmaY=float(y))
        return imgBlur


group = AlgorithmGroup("Basic Image Effects")
group.insert(Blur())

__all__ = ["group"]
