from PySide6.QtCore import QObject
from python.algo_model import Algorithm, AlgorithmGroup
from python.algo_widgets import ComboBox, LineEdit
from PySide6.QtGui import QIntValidator
from .cvt_color import CvtColor
from .sine_transformation import Sine_transformation
from .swirl import Swirl
import cv2
import numpy as np
from python.validator import IntValidator

# 第x个函数

group = AlgorithmGroup()
group.title = 'Image Effects'


# 第15个函数
class Gray_Picture(Algorithm):
    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self.title = 'Gray Picture'
        self.informativeText = 'Change the picture to gray picture'

    def apply(self, image):
        image = cv2.cvtColor(image, cv2.COLOR_BGRA2GRAY)
        image = cv2.cvtColor(image, cv2.COLOR_GRAY2BGRA)
        return image


gray_picture = Gray_Picture()
group.algorithms.append(gray_picture)


# 第16个函数
class Mean_blur(Algorithm):
    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self.combobox = ComboBox("Kernel size", "Set the kernel size of the blur algorithm")
        self.combobox.append("1", "")
        self.combobox.append("3", "")
        self.combobox.append("5", "")
        self.combobox.append("7", "")
        self.combobox.append("9", "")
        self.title = 'Mean Blur'
        self.informativeText = 'mean blur'
        self.combobox.defaultValue = "5"
        self.addWidget(self.combobox)

    def apply(self, image):
        kernel_size = int(self.combobox.currentValue)
        img_blur = cv2.blur(image, (kernel_size, kernel_size))
        return img_blur  # 参数名


mean_blur = Mean_blur()
group.algorithms.append(mean_blur)


# 第17个函数
class Median_blur(Algorithm):
    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self.combobox = ComboBox("Kernel size", "Set the kernel size of the blur algorithm")
        self.combobox.append("1", "")
        self.combobox.append("3", "")
        self.combobox.append("5", "")
        self.combobox.append("7", "")
        self.combobox.append("9", "")
        self.title = 'Median Blur'
        self.informativeText = 'median blur'
        self.combobox.defaultValue = "5"
        self.addWidget(self.combobox)

    def apply(self, image):
        kernel_size = int(self.combobox.currentValue)
        img = cv2.medianBlur(image, kernel_size)
        return img


median_blur = Median_blur()
group.algorithms.append(median_blur)


# 第18个函数
class Gaussian_blur(Algorithm):
    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self.combobox = ComboBox("Kernel size", "Set the kernel size of the blur algorithm")
        self.combobox.append("1", "")
        self.combobox.append("3", "")
        self.combobox.append("5", "")
        self.combobox.append("7", "")
        self.combobox.append("9", "")
        self.title = 'Gaussian Blur'
        self.informativeText = 'Gaussian blur'
        self.combobox.defaultValue = "5"
        self.addWidget(self.combobox)

    def apply(self, image):
        kernel_size = int(self.combobox.currentValue)
        img = cv2.GaussianBlur(image, (kernel_size, kernel_size), 0)
        return img


gaussian_blur = Gaussian_blur()
group.algorithms.append(gaussian_blur)


# 19
class Threshold(Algorithm):
    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)

        # 名称
        self.title = 'Threshold'
        self.informativeText = 'Set Threshold to the image'

        self.combobox = ComboBox("Thresh type")
        self.combobox.append("Binary", "")
        self.combobox.append("Binary Inv", "")
        self.combobox.append("Trunc", "")
        self.combobox.append("To Zero", "")
        self.combobox.append("To Zero Inv", "")
        self.combobox.append("None")
        self.combobox.defaultValue = "None"
        

        self.lineEdit = LineEdit("Thresh", "0-255")
        self.lineEdit.defaultValue = 0
        self.lineEdit.validator = IntValidator(0, 255, 0)
        self.lineEdit.maximumLength = 3

        self.addWidget(self.lineEdit)
        self.addWidget(self.combobox)

    def apply(self, img):  # 注意图片的名称

        # 获得参数
        thresh_type = self.combobox.currentValue
        if thresh_type == "None":
            return img
        if thresh_type == "Binary":
            thresh_type = cv2.THRESH_BINARY
        if thresh_type == "Binary Inv":
            thresh_type = cv2.THRESH_BINARY_INV
        if thresh_type == "Trunc":
            thresh_type = cv2.THRESH_TRUNC
        if thresh_type == "To Zero":
            thresh_type = cv2.THRESH_TOZERO
        if thresh_type == "To Zero Inv":
            thresh_type = cv2.THRESH_TOZERO_INV
        thresh = int(self.lineEdit.currentValue)
        # 代码位置
        thre_img = cv2.cvtColor(img, cv2.COLOR_BGRA2GRAY)
        thre_img = cv2.threshold(thre_img, thresh, 255, thresh_type)[1]
        thre_img = cv2.cvtColor(thre_img, cv2.COLOR_GRAY2BGRA)
        return thre_img


threshold = Threshold()
group.algorithms.append(threshold)


# 20
class Edge(Algorithm):
    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)

        # 名称
        self.title = 'Edge'
        self.informativeText = 'Find edge information in the image'

        self.combobox = ComboBox("Enable")
        self.combobox.append("Yes")
        self.combobox.append("No")
        self.combobox.defaultValue = 'No'
        self.addWidget(self.combobox)

        self.lineEdit1 = LineEdit("Thresh1", "0-255")
        self.lineEdit1.defaultValue = 0
        self.lineEdit1.validator = IntValidator(0, 255, 0)

        self.addWidget(self.lineEdit1)

        self.lineEdit2 = LineEdit("Thresh2", "0-255")
        self.lineEdit2.defaultValue = 0
        self.lineEdit2.validator = IntValidator(0, 255, 0)

        self.addWidget(self.lineEdit2)

    def apply(self, img):  # 注意图片的名称

        if self.combobox.currentValue == 'No':
            return img

        # 获得参数
        thresh1 = int(self.lineEdit1.currentValue)
        thresh2 = int(self.lineEdit2.currentValue)
        # 代码位置
        img = cv2.cvtColor(img, cv2.COLOR_BGRA2GRAY)
        img = cv2.Canny(img, thresh1, thresh2)
        img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGRA)
        return img


edge = Edge()
group.algorithms.append(edge)


class Morph(Algorithm):
    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)

        # 名称
        self.title = 'Morph'
        self.informativeText = 'Morph'

        # 一个参数
        self.combobox1 = ComboBox("Operate", "Choose which operate you want to use")
        self.combobox1.append("Erode", "")
        self.combobox1.append("Dilate", "")
        self.combobox1.append("Open", "")
        self.combobox1.append("Close", "")
        self.combobox1.append("Gradient", "")
        self.combobox1.append("Top hat", "")
        self.combobox1.append("Black hat", "")
        self.combobox1.append("None")
        self.combobox1.defaultValue = "None"
        self.addWidget(self.combobox1)

        # 一个参数
        self.combobox2 = ComboBox("Kernel shape", "Choose the shape of kernel")
        self.combobox2.append("Rect", "")
        self.combobox2.append("Cross", "")
        self.combobox2.append("Ellipse", "")
        self.combobox2.defaultValue = "Rect"
        self.addWidget(self.combobox2)

        # 一个参数
        self.combobox3 = ComboBox("Kernel size", "Choose the size of kernel")
        self.combobox3.append("1", "")
        self.combobox3.append("3", "")
        self.combobox3.append("5", "")
        self.combobox3.append("7", "")
        self.combobox3.append("9", "")
        self.combobox3.defaultValue = "5"
        self.addWidget(self.combobox3)

    def apply(self, img):  # 注意图片的名称

        # 获得参数
        op = self.combobox1.currentValue
        kshape = self.combobox2.currentValue
        ksize = int(self.combobox3.currentValue)
        # 代码位置
        shape = cv2.MORPH_ELLIPSE
        cvop = cv2.MORPH_ERODE
        if op == "None": return img
        if kshape == "rect":
            shape = cv2.MORPH_ELLIPSE
        if kshape == "cross":
            shape = cv2.MORPH_CROSS
        if kshape == "ellipse":
            shape = cv2.MORPH_RECT
        if op == "erode":
            cvop = cv2.MORPH_ERODE
        if op == "dilate":
            cvop = cv2.MORPH_DILATE
        if op == "open":
            cvop = cv2.MORPH_OPEN
        if op == "close":
            cvop = cv2.MORPH_CLOSE
        if op == "gradient":
            cvop = cv2.MORPH_GRADIENT
        if op == "top hat":
            cvop = cv2.MORPH_TOPHAT
        if op == "black hat":
            cvop = cv2.MORPH_BLACKHAT
        kernal = cv2.getStructuringElement(shape, (ksize, ksize))

        Morph_img = cv2.morphologyEx(img, cvop, kernal)
        return Morph_img


morph = Morph()
group.algorithms.append(morph)


# 第23个函数
class Equalize(Algorithm):
    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)

        # 名称
        self.title = 'Equalize'
        self.informativeText = 'Equalize'

        # 一个参数
        self.combobox1 = ComboBox("Kind", "Choose which Channel you want to equalize")
        self.combobox1.append("B", "Blue Channel")
        self.combobox1.append("G", "Green Channel")
        self.combobox1.append("R", "Red Channel")
        self.combobox1.append("None")
        self.combobox1.defaultValue = "None"
        self.addWidget(self.combobox1)

    def apply(self, img):  # 注意图片的名称

        # 获得参数
        kind = self.combobox1.currentValue

        if kind == 'None': 
            return img

        # 代码位置
        b, g, r, a = cv2.split(img)
        if kind == 'B':
            b = cv2.equalizeHist(b)
        if kind == 'G':
            g = cv2.equalizeHist(g)
        if kind == 'R':
            r = cv2.equalizeHist(r)
        return cv2.merge((b, g, r, a))


equalize = Equalize()
group.algorithms.append(equalize)


# 第26个函数
class Flip_picture(Algorithm):
    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)

        # 名称
        self.title = 'Flip Picture'
        self.informativeText = 'Picture flip'

        # 一个参数
        self.combobox1 = ComboBox("direction")
        self.combobox1.append("horizontal", "")
        self.combobox1.append("vertical", "")
        self.combobox1.append("horizontal & vertical", "")
        self.combobox1.append("None")
        self.combobox1.defaultValue = "None"
        self.addWidget(self.combobox1)

    def apply(self, image):  # 注意图片的名称

        # 获得参数
        x = self.combobox1.currentValue
        if (x == 'None'): return image
        if (x == "horizontal"): x = 1
        if (x == "vertical"): x = 0
        if (x == "horizontal & vertical"): x = -1

        # 代码位置
        image = cv2.flip(image, x)
        return image


flip_picture = Flip_picture()
group.algorithms.append(flip_picture)

cvtColor = CvtColor()
group.algorithms.append(cvtColor)

swirl = Swirl()
group.algorithms.append(swirl)

sine_transformation = Sine_transformation()
group.algorithms.append(sine_transformation)

__all__ = ["group"]
