from python.algo_model import Algorithm, AlgorithmGroup
from PySide6.QtCore import QObject, QPoint
from python.algo_widgets import Selector
import cv2
import numpy as np


class GrabCut(Algorithm):

    def __init__(self, parent: QObject = None) -> None:
        super().__init__('Select Foregound', 'Select foreground', parent)
        self.selector = Selector(Selector.SelectorType.Auto,
                                 "Selector ROI")
        self.selector.currentValue = []
        self.addWidget(self.selector)

    def apply(self, image):
        if len(self.selector.currentValue) == 0:
            return image
        left_top_point = QPoint(
            min(point.x() for point in self.selector.currentValue),
            min(point.y() for point in self.selector.currentValue))
        right_bottom_point = QPoint(
            max(point.x() for point in self.selector.currentValue),
            max(point.y() for point in self.selector.currentValue))

        width = right_bottom_point.x() - left_top_point.x()
        height = right_bottom_point.y() - left_top_point.y()
        roi = [left_top_point.x(), left_top_point.y(), width, height]
        mask = np.zeros(image.shape[:2], np.uint8)

        bgdModel = np.zeros((1, 65), np.float64)
        fgdModel = np.zeros((1, 65), np.float64)
        image = cv2.cvtColor(image, cv2.COLOR_BGRA2BGR)

        cv2.grabCut(image, mask, roi, bgdModel, fgdModel, 5,
                    cv2.GC_INIT_WITH_RECT)

        mask2 = np.where((mask == 2) | (mask == 0), 0, 1).astype('uint8')

        result = image * mask2[:, :, np.newaxis]

        rgba_image = np.zeros((image.shape[0], image.shape[1], 4),
                              dtype=np.uint8)
        rgba_image[:, :, :3] = result

        black_pixels = np.all(rgba_image[:, :, :3] != [0, 0, 0], axis=2)
        rgba_image[black_pixels, 3] = 255

        return rgba_image


group = AlgorithmGroup("Basic Image Effects")
group.insert(GrabCut())

__all__ = ["group"]