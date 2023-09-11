from algorithm import cvt_color
from python.algo_model import *
from python.bridge import *
from pathlib import Path
import cv2 as cv
sessionData = SessionData(Path(r"C:\Users\ASUS\Pictures\Saved Pictures\418f33056a268843700fe3d605d5a2e84ff0f3ed.jpg@1320w_1036h.jpg"))
current = sessionData.algoModel[0]
current.append(cvt_color.CvtColor())
current.get(0).widgets.item(0).data(Qt.UserRole).currentValue = "HSV"
current.append(cvt_color.CvtColor())
print(current.get(0).widgets.item(0).data(Qt.UserRole).currentValue)
cv.imshow("asd", sessionData._qt2cv(sessionData.frame[0]))
cv.waitKey(0)