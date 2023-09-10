from algorithm import cvt_color
from python.algo_model import *
from python.bridge import *
from pathlib import Path
sessionData = SessionData(Path(r"C:\Users\ASUS\Pictures\Saved Pictures\418f33056a268843700fe3d605d5a2e84ff0f3ed.jpg@1320w_1036h.jpg"))
sessionData.algoModel[0].append(cvt_color.CvtColor())
