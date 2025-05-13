# 🐾 Pokémon Safari Zone - Terminal Edition

A fun command-line Pokémon Safari Zone simulator inspired by classic Game Boy mechanics. Explore, encounter wild Pokémon, throw Safari Balls, use bait or mud, and catch 'em all – all from your terminal!

![screenshot](assets/screenshot.png) <!-- optional if you add one -->

---

## 🎮 Features

- 🎲 Random wild Pokémon encounters (up to Gen 8)
- 🖼 16-bit Pokémon sprites shown in terminal (via `catimg`)
- 🎯 Catching mechanics with real catch rate formula
- 🍓 Bait and mud affect Pokémon behavior (just like Safari Zone)
- 🏃 Fleeing logic based on stats
- 📦 Collection is saved locally in `pokedex.json`
- 📖 Built-in Pokédex viewer
- ⚔️ Optional fighting system (basic turn-based battle)

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
