# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path
from PySide6.QtCore import Qt
from PySide6.QtGui import QGuiApplication, QIcon
from PySide6.QtQml import QQmlApplicationEngine

KMCUI_PATH = Path(__file__).resolve().parent / "3rdparty/KmcUI"
QML_PATH = Path(__file__).resolve().parent / "qml"
sys.path.append(str(KMCUI_PATH.parent))
from KmcUI import *
from KmcUI.PyKmc.models import TreeModel, TreeNode
from rc_resources import *
from python.image_loader import *
from python.bridge import *
from python.validator import IntValidator
from algorithm import algorithmTreeModel, blur
from python.algo_widgets import *

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    QGuiApplication.setOrganizationName("seu")
    QGuiApplication.setOrganizationDomain("seu.cvtools")
    app.setWindowIcon(QIcon("assets/logo.svg"))
    imageProvider = ImageProvider()
#    b = blur.Blur()
    engine = QQmlApplicationEngine()
    engine.addImageProvider(imageProvider.providerId(), imageProvider)

#    sessionData = SessionData(Path(r"C:\Users\ASUS\Pictures\Saved Pictures\418f33056a268843700fe3d605d5a2e84ff0f3ed.jpg@1320w_1036h.jpg"))
#    for i in range(10):
#        sessionData.algoModel[0].append(b.newInstance())
#     engine = QQmlApplicationEngine()
#     engine.addImageProvider(imageProvider.providerId(), imageProvider)
#    engine.rootContext().setContextProperty("fakeModel", sessionData.algoModel[0])
    engine.rootContext().setContextProperty("imageProvider", imageProvider)

    engine.rootContext().setContextProperty("algorithmTreeModel", algorithmTreeModel)
    qml_file = QML_PATH / "MainForm.qml"
    engine.addImportPath(KMCUI_PATH / "src/imports")
    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
