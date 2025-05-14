# 🐾 Pokémon Safari Zone - Terminal Edition

A fun command-line Pokémon Safari Zone simulator with a beautiful terminal interface. Explore, encounter wild Pokémon, throw Safari Balls, use bait or mud, and catch 'em all – all from your terminal!

![screenshot](assets/screenshot.png) <!-- optional if you add one -->

---

## 🎮 Features

- 🎲 Random wild Pokémon encounters (up to Gen 8)
- 🖼 16-bit Pokémon sprites shown in terminal (via `catimg`)
- 🎯 Catching mechanics with real catch rate formula
- 🍓 Bait and mud affect Pokémon behavior (just like Safari Zone)
- 🏃 Fleeing logic based on stats
- 📦 Collection is saved locally in `data/pokedex.json`
- 📖 Built-in Pokédex viewer
- 🎨 Beautiful terminal UI with:
  - Colorful headers and borders
  - Pokémon-themed icons and emojis
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
│   ├── monster.sh  # Pokémon-related functions
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

1. Enter the Safari Zone to look for wild Pokémon
2. When you encounter a Pokémon, you can:
   - Throw a Safari Ball to catch it
   - Throw a Berry to make it easier to catch
   - Throw Mud to make it harder to catch
   - Run away
3. Visit the shop to buy more items
4. Check your Pokédex to see your collection
5. Monitor your status to track your progress

## 🎨 Terminal Requirements

The game uses ANSI colors and Unicode characters for its interface. Make sure your terminal:
- Supports ANSI color codes
- Uses UTF-8 encoding
- Can display Unicode characters (for icons and emojis)

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Pokémon sprites and data from [PokéAPI](https://pokeapi.co/)
- Inspired by the classic Pokémon Safari Zone mechanics
