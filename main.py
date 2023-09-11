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
from resources import *
from python.image_loader import *
from python.bridge import *
from algorithm import algorithmTreeModel, cvt_color
from python.algo_widgets import *


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    QGuiApplication.setOrganizationName("seu")
    QGuiApplication.setOrganizationDomain("seu.cvtools")
    app.setWindowIcon(QIcon("assets/logo.svg"))
    imageProvider = ImageProvider()
    sessionData = SessionData(Path(r"C:\Users\ASUS\Pictures\Saved Pictures\418f33056a268843700fe3d605d5a2e84ff0f3ed.jpg@1320w_1036h.jpg"))
    sessionData.algoModel[0].append(algorithmTreeModel.data(algorithmTreeModel.index(0,0,algorithmTreeModel.index(0,0)), Qt.UserRole))
    engine = QQmlApplicationEngine()
    engine.addImageProvider(imageProvider.providerId(), imageProvider)
    engine.rootContext().setContextProperty("widget",sessionData.algoModel[0].get(0).widgets.item(0).data(Qt.UserRole))
    engine.rootContext().setContextProperty("imageProvider",imageProvider)
    engine.rootContext().setContextProperty("algorithmTreeModel", algorithmTreeModel)
    qml_file = QML_PATH / "Test.qml"
    engine.addImportPath(KMCUI_PATH / "src/imports")
    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
