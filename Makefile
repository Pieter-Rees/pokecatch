.PHONY: all setup clean test

# Default target
all: setup

# Create data directory and files
setup:
	mkdir -p data
	echo '{"pokedex": [], "monster_stats": {}}' > data/pokedex.json
	echo '{"money": 1000, "inventory": {}, "encounter_stats": {}}' > data/save.json
	chmod 755 data
	chmod 644 data/*.json
	chown -R $(USER):$(USER) data

# Clean build artifacts
clean:
	echo "Cleaning..."
	rm -f *.o *.so *.a
	echo "Clean complete!"

# Run tests
test:
	echo "Running tests..."
	for test in tests/*.sh; do \
		if [ -f "$$test" ]; then \
			sh "$$test"; \
		fi \
	done
	echo "Tests complete!" 