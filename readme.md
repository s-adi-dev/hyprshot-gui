<h1 align="center">Hyprshot GUI</h1>

A simple GTK4-based application for taking screenshots, utilizing **Hyprshot** under the hood. The design is inspired by **GNOME Screenshot**.

## Features
- Sleek easy-to-use GTK4 interface
- Uses **Hyprshot** for capturing screenshots
- Lightweight and fast

## Interface Preview
![Main Interface](assets/interface.png)

## Installation
**On Arch Linux** run this command to run the install script:

`curl -sL https://raw.githubusercontent.com/s-adi-dev/hyprshot-gui/refs/heads/main/install.sh | sh -s arch`

---

**If you are not on arch install these dependencies**

### Dependencies
- **Python 3** (minimum required version)
- **python-gobject**
- **GTK4**
- **Hyprshot**

Then run this command
`curl -sL https://raw.githubusercontent.com/s-adi-dev/hyprshot-gui/refs/heads/main/install.sh | sh -s other`

## Usage
Once installed, you can launch the app from your applications menu (r/t/wofi, walker, nwg-menu, bemenu, fuzzel, anyrun, ...) or via the terminal:

```
hyprshot-gui
```

## Configurations
Hyprshot GUI provides two ways to configure its behavior: **configuration file** and **command-line flags**.
The configuration file is generated with the install script at `~/.config/hypr/hyprshot.conf`

#### Available Settings
| Setting        | Type    | Description                                      | Default Value  |
|----------------|---------|--------------------------------------------------|----------------|
| `OutputDir`    | String  | Directory where screenshots are saved            | `~/Pictures`   |
| `Delay`        | Integer | Delay before taking a screenshot (in seconds)    | `0`            |
| `NotifyTimeout`| Integer | Notification timeout duration (in milliseconds)  | `5000`         |
| `ClipboardOnly`| Boolean | Save screenshot only to clipboard                | `False`        |
| `Freeze`       | Boolean | Freeze the screen on initialization              | `False`        |
| `Silent`       | Boolean | Suppress notifications when saving a screenshot  | `False`        |

#### Notes:
- `Boolean` values accept `True`, `False`, `1`, or `0`.
- `OutputDir` supports `~` expansion.

#### Command Line Options

| Flag | Alias | Description |
|------|-------|-------------|
| `-h` | `--help` | Show help message and exit |
| `-v` | `--version` | Show version information and exit |
| `-o <path>` | `--output-folder <path>` | Set directory to save screenshots |
| `-z` | `--freeze` | Freeze the screen on initialization |
| `-d <seconds>` | `--delay <seconds>` | Set delay before taking a screenshot |
| `--clipboard-only` | | Save only to clipboard |
| `-s` | `--silent` | Do not send notification when a screenshot is saved |
| `-t <ms>` | `--notify-timeout <ms>` | Set notification timeout in milliseconds |

- Example `CLI` Usage
```
hyprshot-gui -o ~/Screenshots -d 3 --clipboard-only
```
## Contributing
If you'd like to contribute, feel free to submit pull requests or report issues.

## License
This project is licensed under the [MIT License](./LICENSE).

