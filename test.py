from algorithm import cvt_color
from python.algo_model import *
from python.bridge import *
from pathlib import Path
from PySide6.QtGui import QIntValidator, QDoubleValidator
from python.validator import *

validator = IntValidator(10, 255)
print(QIntValidator.State.Intermediate.value)
