<h1 align="center">Hyprshot GUI</h1>

<p>A simple GTK4-based application for taking screenshots, utilizing <b>Hyprshot</b> under the hood. The design is inspired by <b>GNOME Screenshot</b>.</p>

## Features
- Easy-to-use GTK4 interface
- Uses **Hyprshot** for capturing screenshots
- Lightweight and fast

## interface Preview
![Main Interface](assets/interface.png)

## Dependencies
Ensure you have the following dependencies installed before running the application:

- **Python 3** (minimum required version)
- **python-gobject**
- **GTK4**
- **Hyprshot**

## Installation
Run the provided installation script to install all the dependencies and set up the application:

```bash
git clone https://github.com/s-adi-dev/hyprshot-gui.git
cd hyprshot-gui
./install.sh
```

## Usage
Once installed, you can launch the app from your applications menu or via the terminal:

```bash
hyprshot-gui
```

## Additional Configuration
For a better user experience, you can configure Hyprland to launch the application in floating mode by adding the following window rule to your Hyprland configuration:
```bash
windowrulev2 = float, title:^(.*Hyprshot.*)$
```
## Contributing
If you'd like to contribute, feel free to submit pull requests or report issues.

## License
This project is licensed under the MIT License.

