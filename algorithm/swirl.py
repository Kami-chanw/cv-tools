from PySide6.QtCore import QObject
from python.algo_model import Algorithm, AlgorithmGroup
from python.algo_widgets import *
import cv2 as cv
import numpy as np
import math


class Swirl(Algorithm):
    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self.title = "Swirl effect"
        self.informativeText = "Add a swirl effect to your image."
        self.Selector = Selector(Selector.SelectorType['Rectangular'], 'Set center', 'Setting transform center')
        # self.Selector.pointCount = 2
        self.addWidget(self.Selector)
        self.Slider_degree = Slider('degree')
        # Set the range and step_size of parameter degree
        self.Slider_degree.maximum = 200
        self.Slider_degree.minimum = 1
        self.Slider_degree.stepSize = 1
        self.addWidget(self.Slider_degree)

    @staticmethod
    def transform(input_img, x, y, dg):
        row, col, channel = input_img.shape
        trans_img = input_img.copy()
        img_out = input_img * 1.0
        degree = dg
        center_x = x
        center_y = y
        y_mask, x_mask = np.indices((row, col))
        xx_dif = x_mask - center_x
        yy_dif = center_y - y_mask
        r = np.sqrt(xx_dif * xx_dif + yy_dif * yy_dif)
        theta = np.arctan(yy_dif / xx_dif)
        mask_1 = xx_dif < 0
        theta = theta * (1 - mask_1) + (theta + math.pi) * mask_1
        theta = theta + r / degree
        x_new = r * np.cos(theta) + center_x
        y_new = center_y - r * np.sin(theta)
        x_new = x_new.astype(np.float32)
        y_new = y_new.astype(np.float32)
        dst = cv.remap(trans_img, x_new, y_new, cv.INTER_LINEAR)
        return dst

    def apply(self, image):
        degree = self.Slider_degree._currentValue
        if self.Selector._defaultValue:
            print(1)
            center_x, center_y = self.Selector._defaultValue[-1].x, self.Selector._defaultValue[-1].y
            image = Swirl.transform(image, center_x, center_y, degree)
        return cv.cvtColor(image, cv.COLOR_BGR2BGRA)
