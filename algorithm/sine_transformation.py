from PySide6.QtCore import QObject
from python.algo_model import Algorithm, AlgorithmGroup
from python.algo_widgets import *
import cv2 as cv
import numpy as np
import math


class Sine_transformation(Algorithm):

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self.title = 'Sine transformation'
        self.informativeText = 'Add a sine transformation effect to your image.'
        self.x_scale = Slider('x_scale', 'Transformation magnification in x direction')
        self.x_scale.maximum, self.x_scale.minimum, self.x_scale.stepSize = 200, 1, 1
        self.y_scale = Slider('y_scale', 'Transformation magnification in y direction')
        self.y_scale.maximum, self.y_scale.minimum, self.y_scale.stepSize = 200, 1, 1
        self.x_period = Slider('x_period', 'Transformation period in x direction')
        self.x_period.maximum, self.x_period.minimum, self.x_period.stepSize = 20, 0, 1
        self.y_period = Slider('y_period', 'Transformation period in y direction')
        self.y_period.maximum, self.y_period.minimum, self.y_period.stepSize = 20, 0, 1
        self.addWidget(self.x_scale)
        self.addWidget(self.y_scale)
        self.addWidget(self.x_period)
        self.addWidget(self.y_period)

    @staticmethod
    def transform(input_img, x, y, xx, yy):
        row, col, _ = input_img.shape
        trans_image = input_img.copy()
        alpha = x
        beta = y
        degree_x = xx
        degree_y = yy
        center_x = (col - 1) / 2.0
        center_y = (row - 1) / 2.0
        y_mask, x_mask = np.indices((row, col))
        xx_dif = x_mask - center_x
        yy_dif = center_y - y_mask
        x = degree_x * np.sin(2 * math.pi * yy_dif / alpha) + xx_dif
        y = degree_y * np.cos(2 * math.pi * xx_dif / beta) + yy_dif
        x_new = x + center_x
        y_new = center_y - y
        x_new = x_new.astype(np.float32)
        y_new = y_new.astype(np.float32)
        dst = cv.remap(trans_image, x_new, y_new, cv.INTER_LINEAR)
        return dst

    def apply(self, image):
        image = Sine_transformation.transform(image, self.x_scale._currentValue, self.y_scale._currentValue,
                                              self.x_period._currentValue, self.y_period._currentValue)
        return cv.cvtColor(image, cv.COLOR_BGR2BGRA)
