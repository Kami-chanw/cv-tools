import PySide6
from pathlib import Path
import subprocess
import platform

rcc_path = Path(PySide6.__path__[0]) / "../../Scripts/pyside6-rcc"

if platform.system() == 'Windows':
    rcc_path  = rcc_path.with_suffix(".exe")

result = subprocess.run([rcc_path, "./resources.qrc", "-o", "./rc_resources.py"], text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

if result.returncode == 0:
    print("Convert successfully")
else:
    print(result.stdout)
