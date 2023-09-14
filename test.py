from algorithm import cvt_color
from python.algo_model import *
from python.bridge import *
from pathlib import Path
from PySide6.QtGui import QIntValidator, QDoubleValidator
from python.validator import *

validator = IntValidator(0, 255, 0)
print(validator.validate("-3", 3))
