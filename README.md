# Neovim Java Development Setup

A modern Neovim configuration powered by Lazy.nvim for Java and general development.

 

## Features

- Java development using JDTLS
- Fast plugin management with Lazy.nvim
- Telescope fuzzy finder
- NvimTree file explorer
- IntelliSense-like autocompletion
- Transparent UI
- Smear cursor animation
- Lombok support
- Auto organize imports
- VSCode-like workflow

 

## Requirements

Install these packages before proceeding.

### Ubuntu / Debian

```bash
sudo apt update
sudo apt install neovim git openjdk-17-jdk maven unzip curl build-essential wget
```

 

## Create Neovim Config Folder

```bash
mkdir -p ~/.config/nvim
```

Move into the directory:

```bash
cd ~/.config/nvim
```

 

## Create init.lua

```bash
touch init.lua
```

Open the file:

```bash
nvim init.lua
```

Paste your Neovim configuration into `init.lua`.

Save the file:

```vim
:w
```

Exit:

```vim
:q
```

 

## Start Neovim

```bash
nvim
```

Lazy.nvim will automatically install all plugins. Wait until the installation finishes before proceeding.

 

## Install Java JDTLS

Create the JDTLS directory:

```bash
mkdir -p ~/.local/share/jdtls
```

Move into the directory:

```bash
cd ~/.local/share/jdtls
```

Download JDTLS:

```bash
wget https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz
```

Extract the archive:

```bash
tar -xvf jdt-language-server-latest.tar.gz
```

Expected folder structure:

```
~/.local/share/jdtls/
├── config_linux
├── plugins
└── features
```

 

## Install Nerd Font

Recommended fonts:

- JetBrainsMono Nerd Font
- Cascadia Code Nerd Font

After installation:

1. Open terminal settings
2. Navigate to font preferences
3. Select your chosen Nerd Font

 

## Lombok Support (Optional)

Lombok is automatically detected from the Maven repository. Add the following dependency to your Java project:

```xml
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>latest</version>
</dependency>
```

 

## Start a Java Project

Create a new project directory:

```bash
mkdir demo-project
cd demo-project
```

Open it with Neovim:

```bash
nvim .
```

JDTLS will automatically start when a valid Java project is detected.

 

## Keymaps

### General

| Key | Action |
| | |
| `jk` | Exit insert mode |
| `<leader>w` | Save file |
| `<leader>q` | Quit |
| `<leader>h` | Clear search highlight |
| `<leader>e` | Toggle file explorer |

### Telescope

| Key | Action |
| | |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>fr` | Recent files |

### Java (JDTLS)

| Key | Action |
| | |
| `<leader>oi` | Organize imports |
| `<leader>ev` | Extract variable |
| `<leader>ec` | Extract constant |
| `<leader>tm` | Test nearest method |

 

## Plugins

| Plugin | Purpose |
| | |
| lazy.nvim | Plugin manager |
| nvim-lspconfig | LSP configuration |
| nvim-jdtls | Java language server |
| nvim-cmp | Autocompletion engine |
| LuaSnip | Snippet support |
| telescope.nvim | Fuzzy finder |
| nvim-tree.lua | File explorer |
| smear-cursor.nvim | Cursor animation |

 

## Recommended Terminals

- Kitty
- WezTerm
- Alacritty

Enable transparency in your terminal settings for the best visual experience.

 

## Troubleshooting

### JDTLS Not Starting

Check your Java version:

```bash
java --version
```

Ensure the following conditions are met:

- JDK 17 or higher is installed
- The `config_linux` directory exists under `~/.local/share/jdtls/`
- The project root contains at least one of the following:
  - `.git`
  - `pom.xml`
  - `gradlew`
  - `mvnw`

### Telescope FZF Not Working

Build the extension manually:

```bash
cd ~/.local/share/nvim/lazy/telescope-fzf-native.nvim
make
```


## Folder Structure

Current structure:

```
~/.config/nvim/
└── init.lua
```

Recommended future structure:

```
lua/
├── config/
├── plugins/
├── lsp/
├── keymaps/
└── settings/
```
