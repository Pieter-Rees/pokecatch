# 🐾 Pocket Monster Safari Zone - Terminal Edition

A fun command-line Pocket Monster Safari Zone simulator with a beautiful terminal interface. Explore, encounter wild Pocket Monsters, throw Safari Balls, use bait or mud, and catch 'em all – all from your terminal!

![screenshot](assets/screenshot.png) <!-- optional if you add one -->

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

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Pocket Monster sprites and data from [PokéAPI](https://pokeapi.co/)
- Inspired by the classic Pocket Monster Safari Zone mechanics
