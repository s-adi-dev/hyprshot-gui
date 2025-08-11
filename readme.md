<h1 align="center">HyprShot GUI</h1>

A simple GTK4-based application for taking screenshots, utilizing **HyprShot** under the hood. The design is inspired by **GNOME Screenshot**.

## Features
- Sleek easy-to-use GTK4 interface
- Uses **HyprShot** for capturing screenshots
- Lightweight and fast

## Interface Preview
![Main Interface](assets/interface.png)

## Installation  
The install script supports the following distributions:  
- **Arch Linux**  
- **Debian/Ubuntu**  
- **Fedora**  

#### Arch (via AUR)

If you're using an AUR helper (like `yay`, `paru`, etc.), install it with:

```bash
yay -Sy hyprshot-gui
````

#### Install Script (For all supported distributions)

Run the install script based on your distribution:

```bash
curl -fsSL https://raw.githubusercontent.com/s-adi-dev/hyprshot-gui/main/install.sh | bash
``` 
---

**If your distribution is not listed or an error occurs during installation, please install the dependencies manually:**
### Dependencies  
- **Python 3** (minimum required version)  
- **python-gobject**  
- **GTK4**  
- **HyprShot**  

Then run the generic install command:  
```bash
curl -sL https://raw.githubusercontent.com/s-adi-dev/hyprshot-gui/refs/heads/main/src/hyprshot-gui | sudo tee /usr/bin/hyprshot-gui > /dev/null
sudo chmod +x /usr/bin/hyprshot-gui
curl -sL https://raw.githubusercontent.com/s-adi-dev/hyprshot-gui/refs/heads/main/src/hyprshot.desktop | sudo tee /usr/share/applications/hyprshot.desktop > /dev/null
```

---

## Usage
Once installed, you can launch the app from your applications menu (r/t/wofi, walker, nwg-menu, bemenu, fuzzel, anyrun, ...) or via the terminal:

```
hyprshot-gui
```

## Configurations
HyprShot GUI provides two ways to configure its behavior: **configuration file** and **command-line flags**.
The configuration file is generated with the install script at `~/.config/hypr/hyprshot.conf`

#### Available Settings
| Setting        | Type    | Description                                      | Default Value  |
|----------------|---------|--------------------------------------------------|----------------|
| `OutputDir`    | String  | Directory where screenshots are saved            | `~/Pictures`   |
| `Delay`        | Integer | Delay before taking a screenshot (in seconds)    | `0`            |
| `NotifyTimeout`| Integer | Notification timeout duration (in milliseconds)  | `5000`         |
| `ClipboardOnly`| Boolean | Save screenshot only to clipboard                | `False`        |
| `Silent`       | Boolean | Suppress notifications when saving a screenshot  | `False`        |

- Example Configuration File
```ini
[Settings]
OutputDir=~/Pictures
Delay=0
NotifyTimeout=5000
ClipboardOnly=False
Silent=False
```

#### Notes:
- `Boolean` values accept `True`, `False`, `1`, or `0`.
- `OutputDir` supports `~` expansion.

#### Command Line Options

| Flag | Alias | Description |
|------|-------|-------------|
| `-h` | `--help` | Show help message and exit |
| `-v` | `--version` | Show version information and exit |
| `-o <path>` | `--output-folder <path>` | Set directory to save screenshots |
| `-d <seconds>` | `--delay <seconds>` | Set delay before taking a screenshot |
| `--clipboard-only` | | Save only to clipboard |
| `-s` | `--silent` | Do not send notification when a screenshot is saved |
| `-t <ms>` | `--notify-timeout <ms>` | Set notification timeout in milliseconds |

- Example `CLI` Usage
```
hyprshot-gui -o ~/Screenshots -d 3 --clipboard-only
```

## Additional Configuration  
To enhance the user experience, you can configure Hyprland to launch the application in floating mode by adding the following window rule to your Hyprland configuration:  
For Hyprland until 0.47.2
```bash
windowrulev2 = float, title:^(.*Hyprshot.*)$
```
From Hyprland from 0.48.0
```bash
windowrule = float, title:^(.*Hyprshot.*)$
```
- **Note:** The Install script tries to add this rule is automatically if it finds only one file containing window rules like `~/.config/hypr/hyprland.conf` or a modular approach `~/.config/hypr/conf/rules.conf`. Finding more than one file with window rules, it won't try to add the rule.

## Contributing
If you'd like to contribute, feel free to submit pull requests or report issues.

## License
This project is licensed under the [MIT License](./LICENSE).

