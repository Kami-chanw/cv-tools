from algorithm import blur, cvt_color
from python.algo_model import *
from python.bridge import *
from pathlib import Path
from PySide6.QtGui import QIntValidator, QDoubleValidator
from python.validator import *
from pathlib import Path
from algorithm import algorithmTreeModel
import cv2
s :SessionData= SessionData(Path(r"C:\Users\ASUS\Pictures\Saved Pictures\4273308f6a6c68d5adfc0e8ceb1c2a2c15f9785a.jpg@1320w_934h.jpg"))
b = algorithmTreeModel.data(algorithmTreeModel.index(0,0,algorithmTreeModel.index(0,0)), Qt.UserRole)
s.algoModel[0].append(b.newInstance())
s.algoModel[0].append(algorithmTreeModel.data(algorithmTreeModel.index(0,0,algorithmTreeModel.index(0,0)), Qt.UserRole).newInstance())
s.algoModel[0].append(algorithmTreeModel.data(algorithmTreeModel.index(0,0,algorithmTreeModel.index(0,0)), Qt.UserRole).newInstance())
s.algoModel[0].append(algorithmTreeModel.data(algorithmTreeModel.index(0,0,algorithmTreeModel.index(0,0)), Qt.UserRole).newInstance())
s.algoModel[0].append(algorithmTreeModel.data(algorithmTreeModel.index(0,0,algorithmTreeModel.index(0,0)), Qt.UserRole).newInstance())
s.applyAlgorithms(0)
cv2.imshow("asd", s._qt2cv(s.frame[0]))
cv2.waitKey(0)
