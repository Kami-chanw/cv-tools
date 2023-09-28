# pip install git+https://github.com/facebookresearch/segment-anything.git
import numpy as np
import torch
import cv2 as cv
from segment_anything import sam_model_registry, SamPredictor
import sys
from PySide6.QtCore import QObject
from python.algo_model import Algorithm, AlgorithmGroup
from python.algo_widgets import ComboBox, Selector, LineEdit


def get_mask(mask, random_color=False):
    if random_color:
        color = np.concatenate([np.random.random(3), np.array([0.6])], axis=0)
    else:
        color = np.array([1])
    h, w = mask.shape[-2:]
    mask_image = mask.reshape(h, w) * color.reshape(1, 1)
    return mask_image


class SAM_point(Algorithm):

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self.title = "Split by point"
        self.informativeText = "Split the target by clicking."
        self.combobox = ComboBox("Effect selection")
        self.combobox.append("Mask 1")
        self.combobox.append("Mask 2")
        self.combobox.append("Mask 3")
        self.combobox.append("None")
        self.combobox.defaultValue = "None"
        self.addWidget(self.combobox)
        self.selector = Selector(Selector.SelectorType['Rectangular'], 'Choose object', 'Choose the target object',
                                 pointCount=1)
        self.addWidget(self.selector)
        sam_checkpoint = './model/sam_vit_b_01ec64.pth'
        model_type = 'vit_b'
        if torch.cuda.is_available():
            device = 'cuda'
        else:
            device = 'cpu'
        sam = sam_model_registry[model_type](checkpoint=sam_checkpoint)
        sam.to(device=device)
        self.predictor = SamPredictor(sam)

    def apply(self, image):
        image = cv.cvtColor(image, cv.COLOR_BGRA2BGR)
        self.predictor.set_image(image)
        if self.selector.currentValue:
            value = self.selector.currentValue[-1]
            input_point = np.array([[value.x(), value.y()]])
            input_label = np.array([1])
            masks, scores, logits = self.predictor.predict(
                point_coords=input_point,
                point_labels=input_label,
                multimask_output=True,
            )
            result_image = np.zeros(image.shape, np.uint8)
            if self.combobox.currentValue == 'Mask 1':
                mask = masks[0]
                mask = get_mask(mask)
                result_image[mask > 0] = image[mask > 0]
            elif self.combobox.currentValue == 'Mask 2':
                mask = masks[1]
                mask = get_mask(mask)
                result_image[mask > 0] = image[mask > 0]
            elif self.combobox.currentValue == 'Mask 3':
                mask = masks[2]
                mask = get_mask(mask)
                result_image[mask > 0] = image[mask > 0]
            else:
                result_image = image
            return cv.cvtColor(result_image, cv.COLOR_BGR2BGRA)
        else:
            return cv.cvtColor(image, cv.COLOR_BGR2BGRA)


class SAM_rectangle(Algorithm):
    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self.title = "Split by rectangular selection"
        self.informativeText = "Split the target by dragging the marquee."
        self.selector = Selector(Selector.SelectorType['Rectangular'], 'Choose object', 'Choose the target object',
                                 pointCount=4)
        self.addWidget(self.selector)
        sam_checkpoint = './model/sam_vit_b_01ec64.pth'
        model_type = 'vit_b'
        if torch.cuda.is_available():
            device = 'cuda'
        else:
            device = 'cpu'
        sam = sam_model_registry[model_type](checkpoint=sam_checkpoint)
        sam.to(device=device)
        self.predictor = SamPredictor(sam)

    def apply(self, image):
        image = cv.cvtColor(image, cv.COLOR_BGRA2BGR)
        self.predictor.set_image(image)
        if self.selector.currentValue:
            upper_left_point = self.selector.currentValue[0]
            lower_right_point = self.selector.currentValue[-1]
            input_box = np.array(
                [upper_left_point.x(), upper_left_point.y(), lower_right_point.x(), lower_right_point.y()])
            masks, _, _ = self.predictor.predict(
                point_coords=None,
                point_labels=None,
                box=input_box,
                multimask_output=False,
            )
            result_image = np.zeros(image.shape, dtype=np.uint8)
            mask = masks[0]
            mask = get_mask(mask)
            result_image[mask > 0] = image[mask > 0]
            return cv.cvtColor(result_image, cv.COLOR_BGR2BGRA)
        else:
            return cv.cvtColor(image, cv.COLOR_BGR2BGRA)
