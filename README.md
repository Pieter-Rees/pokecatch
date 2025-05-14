# 🐾 Pocket Monster Safari Zone - Terminal Edition

A fun command-line Pocket Monster Safari Zone simulator with a beautiful terminal interface. Explore, encounter wild Pocket Monsters, throw Safari Balls, use bait or mud, and catch 'em all – all from your terminal!

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/yourusername/pokecatch/actions)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](https://github.com/yourusername/pokecatch/releases)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

![screenshot](assets/screenshot.png)

---

## 🎮 Features

- 🎲 Random wild Pocket Monster encounters (up to Gen 8)
- 🖼 16-bit Pocket Monster sprites shown in terminal (via `catimg`)
- 🎯 Catching mechanics with real catch rate formula
- 🍓 Bait and mud affect Pocket Monster behavior (just like Safari Zone)
- 🏃 Fleeing logic based on stats
- 📦 Collection is saved locally in `data/pokedex.json`
- 📖 Built-in Pocket Monster viewer
- 🎨 Beautiful terminal UI with:
  - Colorful headers and borders
  - Pocket Monster-themed icons and emojis
  - Loading animations
  - Clear visual hierarchy
  - Status indicators
  - Inventory management

---

## 🛠 Requirements

Make sure you have the following installed:

- `bash`
- `curl`
- `jq`
- `catimg` (for displaying images)
- `shuf` (usually included with `coreutils`)

To install `catimg`:
```bash
brew install catimg         # macOS (via Homebrew)
sudo apt install catimg     # Debian/Ubuntu
```

## 🚀 Getting Started

1. Clone the repository:
```bash
git clone https://github.com/yourusername/pokecatch.git
cd pokecatch
```

2. Install the game:
```bash
sudo make install
```

3. Run the game:
```bash
pokecatch
```

## 📁 Project Structure

```
pokecatch/
├── bin/            # Executable scripts
│   └── pokecatch   # Main game script
├── lib/            # Library functions
│   ├── monster.sh  # Pocket Monster-related functions
│   ├── items.sh    # Item management
│   ├── shop.sh     # Shop functionality
│   ├── status.sh   # Status display
│   └── style.sh    # UI styling
├── data/           # Data files
│   ├── pokedex.json
│   └── save.json
├── config/         # Configuration files
├── tests/          # Test files
├── Makefile        # Build and installation
└── README.md
```

## 🎯 How to Play

1. Enter the Safari Zone to look for wild Pocket Monsters
2. When you encounter a Pocket Monster, you can:
   - Throw a Safari Ball to catch it
   - Throw a Berry to make it easier to catch
   - Throw Mud to make it harder to catch
   - Run away
3. Visit the shop to buy more items
4. Check your Pocket Monster dex to see your collection
5. Monitor your status to track your progress

## 🎨 Terminal Requirements

The game uses ANSI colors and Unicode characters for its interface. Make sure your terminal:
- Supports ANSI color codes
- Uses UTF-8 encoding
- Can display Unicode characters (for icons and emojis)

## 🧪 Testing

Run the test suite:
```bash
make test
```

The tests cover:
- Core game mechanics
- Pocket Monster encounter rates
- Catch rate calculations
- Item effects
- Save/load functionality

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please ensure your code follows the project's style guidelines and includes appropriate tests.

## 🔧 Troubleshooting

Common issues and solutions:

### Image Display Issues
- If Pocket Monster sprites aren't displaying:
  - Ensure `catimg` is properly installed
  - Check terminal color support: `echo -e "\e[31mRed Text\e[0m"`
  - Verify terminal size is sufficient

### Game Won't Start
- Check all dependencies are installed
- Verify file permissions: `chmod +x bin/pokecatch`
- Ensure data directory exists: `mkdir -p data`

### Save File Issues
- If save data is corrupted:
  - Backup and remove `data/save.json`
  - Restart the game to create a new save file

## 📚 Documentation

For detailed documentation about game mechanics and development:
- [Game Mechanics](docs/mechanics.md)
- [Development Guide](docs/development.md)
- [API Reference](docs/api.md)

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Pocket Monster sprites and data from [PokéAPI](https://pokeapi.co/)
- Inspired by the classic Pocket Monster Safari Zone mechanics
