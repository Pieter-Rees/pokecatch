# 🐾 Pocket Monster Safari Zone - Terminal Edition

A fun command-line Pocket Monster Safari Zone simulator with a beautiful terminal interface. Explore, encounter wild Pocket Monsters, throw Safari Balls, use bait or mud, and catch 'em all – all from your terminal!

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/yourusername/pokecatch/actions)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](https://github.com/yourusername/pokecatch/releases)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

![screenshot](assets/screenshot.png)

---

## 🎮 Features

### Core Gameplay
- 🎲 Random wild Pocket Monster encounters (up to Gen 8)
- 🖼 16-bit Pocket Monster sprites shown in terminal (via `catimg`)
- 🎯 Advanced catching mechanics with real catch rate formula
- 🍓 Bait and mud affect Pocket Monster behavior (just like Safari Zone)
- 🏃 Intelligent fleeing logic based on stats and conditions
- 📦 Persistent collection saved locally in `data/pokedex.json`
- 📖 Comprehensive Pocket Monster viewer with detailed stats

### Game Mechanics
- 🎯 Multiple catching strategies:
  - Safari Balls for direct capture attempts
  - Rocks to make Pocket Monsters angry (easier to catch but more likely to flee)
  - Bait to make Pocket Monsters eat (harder to catch but less likely to flee)
- 💰 In-game economy with:
  - Currency earned from successful captures
  - Shop system for purchasing items
  - Item inventory management
- 📊 Detailed status tracking:
  - Capture statistics
  - Collection progress
  - Current inventory
  - Financial status

### User Interface
- 🎨 Beautiful terminal UI featuring:
  - Colorful headers and borders
  - Pocket Monster-themed icons and emojis
  - Smooth loading animations
  - Clear visual hierarchy
  - Real-time status indicators
  - Intuitive inventory management
  - Progress bars and statistics
  - Helpful tooltips and instructions

---

## 🛠 Requirements

Make sure you have the following installed:

- `bash` (version 4.0 or higher)
- `curl` (for API requests)
- `jq` (for JSON processing)
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

2. Initialize the game data:
```bash
make setup
```

3. Make sure all scripts are executable:
```bash
chmod +x bin/* lib/*.sh
```

4. Run the game:
```bash
./bin/pokecatch
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

### Basic Commands
- `./bin/pokecatch` - Start the game
- `make test` - Run the test suite
- `make clean` - Clean up build artifacts

### Gameplay Flow
1. Enter the Safari Zone to look for wild Pocket Monsters
2. When you encounter a Pocket Monster, you can:
   - Throw a Safari Ball to catch it
   - Throw a Rock to make it angry (easier to catch but more likely to flee)
   - Throw Bait to make it eat (harder to catch but less likely to flee)
   - Run away
3. Visit the shop to:
   - Buy Safari Balls
   - Purchase Rocks
   - Stock up on Bait
   - Check your balance
4. Check your Pocket Monster dex to:
   - View your collection
   - See detailed stats
   - Track completion progress
5. Monitor your status to:
   - Track capture statistics
   - View inventory
   - Check financial status
   - See game progress

### Advanced Strategies
- Use Rocks before throwing Safari Balls for better catch rates
- Apply Bait when encountering rare Pocket Monsters to prevent fleeing
- Balance your inventory between different item types
- Save your currency for important purchases
- Track which Pocket Monsters you still need to catch

## 🎨 Terminal Requirements

The game uses ANSI colors and Unicode characters for its interface. Make sure your terminal:
- Supports ANSI color codes
- Uses UTF-8 encoding
- Can display Unicode characters (for icons and emojis)
- Has a minimum width of 80 characters
- Has a minimum height of 24 lines

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
- UI rendering
- Shop transactions
- Inventory management

## 🔧 Troubleshooting

### Common Issues

#### Game Won't Start
- Check all dependencies are installed:
  ```bash
  which bash curl jq catimg shuf
  ```
- Verify file permissions: `chmod +x bin/* lib/*.sh`
- Ensure data directory exists: `make setup`
- Check if game data is initialized: `ls -l data/`

#### Save File Issues
- If save data is corrupted:
  - Backup and remove `data/save.json`
  - Restart the game to create a new save file
- If items are missing:
  - Check `data/pokedex.json` for corruption
  - Verify file permissions
  - Ensure proper JSON formatting

#### Performance Issues
- If the game runs slowly:
  - Check system resources
  - Verify network connection (for API calls)
  - Ensure sufficient disk space
  - Check for background processes

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
- Terminal UI design inspired by various CLI games and tools
