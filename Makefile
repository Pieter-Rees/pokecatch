.PHONY: all install clean test

# Default target
all: install

# Install the game and its dependencies
install:
	@echo "Installing pokecatch..."
	@mkdir -p $(DESTDIR)/usr/local/bin
	@mkdir -p $(DESTDIR)/usr/local/lib/pokecatch
	@mkdir -p $(DESTDIR)/usr/local/share/pokecatch
	@mkdir -p data
	@echo '{"pokedex": [], "monster_stats": {}}' > data/pokedex.json
	@echo '{"money": 1000, "inventory": {}, "encounter_stats": {}}' > data/save.json
	@chmod 755 data
	@chmod 644 data/*.json
	@cp bin/pokecatch $(DESTDIR)/usr/local/bin/
	@cp lib/*.sh $(DESTDIR)/usr/local/lib/pokecatch/
	@cp data/*.json $(DESTDIR)/usr/local/share/pokecatch/
	@chmod +x $(DESTDIR)/usr/local/bin/pokecatch
	@echo "Installation complete!"

# Clean build artifacts
clean:
	@echo "Cleaning..."
	@rm -f *.o *.so *.a
	@echo "Clean complete!"

# Run tests
test:
	@echo "Running tests..."
	@for test in tests/*.sh; do \
		if [ -f "$$test" ]; then \
			sh "$$test"; \
		fi \
	done
	@echo "Tests complete!" 