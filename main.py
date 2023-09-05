# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, QQmlContext

KMCUI_PATH = Path(__file__).resolve().parent / "3rdparty/KmcUI"
QML_PATH = Path(__file__).resolve().parent / "qml"
sys.path.append(str(KMCUI_PATH))
from kmc_resources_rc import *
from resources import *
from PyKmc.models import TreeModel, TreeNode
from python.image_loader import *
from python.bridge import *

print( Path(__file__).resolve().parent)
if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    QGuiApplication.setOrganizationName("seu")
    QGuiApplication.setOrganizationDomain("seu.cvtools")

    imageProvider = ImageProvider(ImageProvider.ProviderType.Image)
    engine = QQmlApplicationEngine()
    engine.addImageProvider(imageProvider.providerId(), imageProvider)
    engine.rootContext().setContextProperty("imageProvider",imageProvider)
    qml_file = QML_PATH / "MainForm.qml"
    engine.addImportPath(KMCUI_PATH / "src/imports")
    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
