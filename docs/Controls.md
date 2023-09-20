# Controls
## General
All controls inherit from `AbstractWidget`. A control contains following properties

1. `title`: The name of algorithm which will display at tool box in uppercase and algorithm menu. Once created it can't be changed.
2. `informativeText`: A short text describing what the algorithm is intended to do.
3. `currentValue`: Current value of controls. You can specify a default value by setting this property at initialization, then it will be updated in frontend.
## LineEdit
The LineEdit control is a specialized input widget for single-line text input.

### Properties

1. `placeholderText`: The placeholder text displayed in the LineEdit when it is empty.
   - Type: `str`
   - Signal: `placeholderTextChanged`

2. `maximumLength`: The maximum length of the text that can be entered in the `LineEdit`.
   - Type: `int`
   - Signal: `maximumLengthChanged`

3. `validator`: The validator object used to enforce input constraints on the `LineEdit`. See more about `Validator` in [qt offical document](https://doc.qt.io/qt-6/qvalidator.html).
   - Type: `IntValidator`, `DoubleValidator` or `RegularExpressionValidator` from `python.validator`
   - Signal: `validatorChanged`
## ComboBox
The ComboBox control is a specialized widget for selecting items from a drop-down list.

### Properties

1. `labelModel`: The model containing the labels and tooltips for the combo box items.
   - Type: `QObject`
   - Constant Property

2. `defaultValue`: The default value selected in the combo box.
   - Type: `QVariant`
   - Signal: `defaultValueChanged`

3. `defaultIndex`: The index of the default value in the combo box.
   - Type: `int`

### Methods

#### `append(self, label, tip=None)`
- Appends a new item to the combo box.
- Parameters:
  - `label` (str): The label text of the item.
  - `tip` (str, optional): The tooltip text for the item.

#### `extend(self, labelList: List[str] | List[Tuple[str, str | None]])`
- Extends the combo box with multiple items.
- Parameters:
  - `labelList` (List[str] | List[Tuple[str, str | None]]): A list of label strings or label-tooltip pairs.


#### `insert(self, idx, label, tip=None)`
- Inserts a new item at the specified index in the combo box.
- Parameters:
  - `idx` (int): The index at which to insert the item.
  - `label` (str): The label text of the item.
  - `tip` (str, optional): The tooltip text for the item.


#### `remove(self, idx)`
- Removes an item from the combo box at the specified index.
- Parameters:
  - `idx` (int): The index of the item to remove.

## Selector
The Selector control is a specialized widget for selecting regions or shapes in an interface.

### Properties

1. `selectorType`: The type of selector, which can be one of the following:
   - `Selector.SelectorType.Rectangular`: A rectangular selector.
   - `Selector.SelectorType.Polygon`: A polygonal selector.
   - `Selector.SelectorType.Auto`: An automatic selector type determined by user. The user can select as many points as desired, and the selection ends when the path is closed, and the `pointCount` will be set.

Once created it can't be changed.

1. `pointCount`: The number of points or vertices in the selector shape. The value depends on the selector type.
   - Type: `int`
   - Signal: `pointCountChanged`
 
## Slider
The Slider control is a specialized widget for selecting a numeric value within a specified range using a sliding mechanism.

### Properties

1. `minimum`: The minimum value that the slider can represent.
   - Type: `float`
   - Signal: `minimumChanged`

2. `stepSize`: The step size or increment by which the slider value changes.
   - Type: `float`
   - Signal: `stepSizeChanged`

3. `maximum`: The maximum value that the slider can represent.
   - Type: `float`
   - Signal: `maximumChanged`
## CheckBox
The CheckBox control is a specialized widget for toggling a binary state (checked or unchecked).

### Properties

1. `text`: The text displayed next to the checkbox, describing its purpose or label.
   - Type: `str`
   - Signal: `textChanged`