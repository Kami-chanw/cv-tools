# How to extend algorithms for cv-tools?
1. Create a new `.py` file in `./algorithms`.
2. Create your own class and subclass `Algorithm` in `python.algo_model`.
3. Add widgets in `python.algo_widgets` for you algorithm, and call `addWidget(widget)` to register widgets.
4. Reimplement `apply(image)` that accept a opencv mat BGRA image and return a opencv mat BGRA (call `cv2.cvtColor()` to ensure it).
5. You can add your algorithm to an `AlgorithmGroup`, this is optional.
6. Register algorithm/algorithm group to `__all__`, then it will be automatically register to cv-tools. If there is already an `AlgorithmGroup` with the same `title`, algorithms in the same group will be automatically merged. If there is already an `Algorithm` with the same name, an exception will be thrown when importing.

Here is a full example.
```python
class CvtColor(Algorithm):

    def __init__(self, parent: QObject = None) -> None:
        super().__init__(parent)
        self.title = "Convert Color Space"
        self.informativeText = "Convert color space to a specific one."
        self.combobox = ComboBox("Target Color Space")
        self.combobox.append("HSV", "Convert color space from BGR to HSV")
        self.combobox.append("RGB", "Convert color space from BGR to RGB")
        self.combobox.append("Gray", "Convert color space from BGR to gray scale")
        self.combobox.append("None")
        self.combobox.defaultValue = "None"
        self.addWidget(self.combobox)

    def apply(self, image):
        if self.combobox.currentValue == "None":
            return image
        if self.combobox.currentValue == "HSV":
            return cv.cvtColor(image, cv.COLOR_BGR2HSV)
        if self.combobox.currentValue == "RGB":
            return cv.cvtColor(image, cv.COLOR_BGR2RGB)
        if self.combobox.currentValue == "Gray":
            return cv.cvtColor(image, cv.COLOR_BGR2GRAY)

cvtColor = CvtColor()
group = AlgorithmGroup()
group.algorithms.append(cvtColor)

__all__ = ["group"]
```

Then you can see you algorithm at menu *Edit -> \<Your algorithm group name\> -> \<Your sub ablgorithm group name\> -> ... -> \<Your algorithm\>*.

# How to use controls?
## LineEdit
TODO..
## ComboBox
TODO..
## Selector
TODO..
## Slider
TODO..
## CheckBox
TODO..
