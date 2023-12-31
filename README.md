# cv-tools
This repository is for the SEU 2023/8 Summer Junior Course. It contains some computer vision based tools. The GUI is based on PySide6 and Qt Quick. 

Generally, this is a meta cv algorithm system that provide VS-Code like GUI. You can easily extent your algorithm to this app without writing annoying ui code (see [How to extend new algorithm](docs/README.md)), because there are plenty of controls here.

## ⚽ Get start
+ Install PySide6 by `pip install PySide6`
+ Clone this repo.
  ```
  git clone --recursive https://github.com/Kami-chanw/cv-tools
  ```
+ Generate `rc_resource.py` by running `compile_qrc.py`. `compile_qrc.py` will look up `pyside6-rcc` in your `PySide6` install path and convert `.qrc` file to `.py`.
+ Run python with `python main.py`

## Supported controls
|Name|Description|Preview
|:----:|:----:|:----:|
|LineEdit|A text field that allows one line of text to be entered|![lineedit](docs/preview/lineedit.gif)
|ComboBox|A control that allows user to select value from list|![combobox](docs/preview/combobox.gif)
|Slider|A control that used to select value in a contiguous range|![slider](docs/preview/slider.gif)
|Selector|A set of buttons that control user to select region in image|![selector](docs/preview/selector.gif)
|CheckBox|A control that allow user to make binary choice|![checkbox](docs/preview/checkbox.gif)
|Tracer|A set of buttons that control tracking of mouse movement| Work in progress...🚀
|Color Picker|A popup that enable to pick a specific color| Work in progress...🚀
|Stack Layout|A stack of items where only one item is visible at a time|

## 📸 Screen Shot

![screenshot1](docs/preview/screen_shot1.png)

## License

This cv-tools currently licensed under [MIT License](./LICENSE)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=Kami-chanw/cv-tools&type=Date)](https://star-history.com/#Kami-chanw/cv-tools&Date)

## ⚡ Visitor count
![](https://profile-counter.glitch.me/cv-tools/count.svg)


