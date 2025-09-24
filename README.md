# Lugo Scripts

A collection of utility scripts that can be installed as individual commands on macOS and Linux systems.

## Overview

The lugo command system provides a modular approach to managing utility scripts. You can either use the main `lugo` command as a dispatcher or access individual scripts directly.

### Available Commands

- **dlvid** - Download videos from internet
- **duplicates** - Find duplicated files in directories  
- **renameseq** - Rename files sequentially with customizable patterns
- **update** - Update lugo to the latest version from GitHub

## Installation

### Quick Install

```bash
curl -sSL https://raw.githubusercontent.com/CarlosLugones/scripts/main/install.sh | bash
```

Or clone and install locally:

```bash
git clone https://github.com/CarlosLugones/scripts.git
cd scripts
./install.sh
```

This will install all commands to `~/.local/bin/` and create both the main `lugo` command and individual command symlinks.

### Manual Installation

1. Copy the `lugo` script and `commands/` directory to a directory in your PATH
2. Make all scripts executable: `chmod +x lugo commands/*`
3. Update the `COMMANDS_DIR` variable in the `lugo` script to point to your commands directory

### Uninstall

```bash
./install.sh uninstall
```

## Usage

### Using the main lugo command

```bash
# Show help and available commands
lugo --help

# Show version information  
lugo --version

# Use individual commands through lugo
lugo dlvid --help
lugo duplicates /path/to/search
lugo renameseq *.jpg

# Update to latest version
lugo update
```

### Using individual commands directly

After installation, you can also use commands directly:

```bash
dlvid --help
duplicates --recursive ~/Documents
renameseq --prefix photo *.png
update --check-only  # Check for updates
```

## Command Details

### dlvid - Download Videos

```bash
lugo dlvid [--help] [options] <url>
```

**Options:**
- `--help` - Show help message
- `--output` - Output directory (default: current directory)
- `--format` - Video format preference

**Examples:**
```bash
lugo dlvid https://example.com/video
lugo dlvid --output ~/Downloads https://example.com/video
```

### duplicates - Find Duplicate Files

```bash
lugo duplicates [--help] [options] <directory>
```

**Options:**
- `--help` - Show help message
- `--recursive` - Search recursively in subdirectories
- `--size` - Only check files of similar size first
- `--hash` - Use hash comparison for accurate results

**Examples:**
```bash
lugo duplicates ~/Documents
lugo duplicates --recursive --hash ~/Pictures
```

### renameseq - Sequential File Renaming

```bash
lugo renameseq [--help] [options] <files...>
```

**Options:**
- `--help` - Show help message
- `--prefix` - Prefix for renamed files (default: file)
- `--start` - Starting number (default: 1)
- `--digits` - Number of digits for numbering (default: 3)

**Examples:**
```bash
lugo renameseq *.jpg
lugo renameseq --prefix photo --start 10 *.png
lugo renameseq --digits 4 --prefix img *.gif
```

### update - Update Lugo System

```bash
lugo update [--help] [--check-only] [--force]
```

**Options:**
- `--help` - Show help message
- `--check-only` - Only check for updates without installing
- `--force` - Force update even if versions are the same

**Examples:**
```bash
lugo update                    # Update to latest version
lugo update --check-only       # Check if updates are available
lugo update --force            # Force reinstall current version
```

## Development

### Adding New Commands

1. Create a new executable script in the `commands/` directory
2. Add the command name to the `AVAILABLE_COMMANDS` array in the main `lugo` script
3. Follow the existing pattern for help messages and argument handling
4. Update documentation

### Project Structure

```
.
├── lugo                    # Main command dispatcher
├── VERSION                 # Version file
├── commands/               # Individual command scripts  
│   ├── dlvid              # Video download command
│   ├── duplicates         # Duplicate file finder
│   ├── renameseq          # Sequential file renamer
│   └── update             # Update command
├── install.sh             # Installation script
├── Makefile               # Build and test targets
├── .github/workflows/     # GitHub Actions
│   └── version-bump.yml  # Automatic versioning
└── README.md              # This documentation
```

## Requirements

- Bash 4.0+ (available by default on macOS and most Linux distributions)
- POSIX-compatible system (macOS, Linux, WSL)
- `git` and `curl` (for update functionality)

## Versioning

This project uses semantic versioning (MAJOR.MINOR.PATCH). Versions are automatically bumped using GitHub Actions:

- **Major** (X.0.0): Breaking changes (commit message contains "breaking" or "major")
- **Minor** (0.X.0): New features (commit message contains "feat", "feature", or "minor")  
- **Patch** (0.0.X): Bug fixes and other changes (default)

To skip automatic version bumping, include `[skip-version]` in your commit message.

## Platform Support

- ✅ macOS (tested on Big Sur+)
- ✅ Linux (tested on Ubuntu, CentOS, Alpine)
- ✅ Windows WSL

## License

This project is open source. See individual script headers for specific licensing information.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Add your command script to the `commands/` directory
4. Update the `AVAILABLE_COMMANDS` array in `lugo`
5. Add documentation for your command
6. Submit a pull request

## Notes

- All command implementations are currently placeholders
- Actual functionality would be implemented in each individual command script  
- The system is designed to be modular and easily extensible
- Commands can be written in any language as long as they're executable and follow the help message conventions