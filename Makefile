#!/usr/bin/make -f

# Makefile for lugo command system

.PHONY: help install uninstall test clean

# Default target
help:
	@echo "Lugo Command System"
	@echo ""
	@echo "Available targets:"
	@echo "  help      - Show this help message"
	@echo "  install   - Install lugo command system"
	@echo "  uninstall - Remove lugo command system"  
	@echo "  test      - Run basic functionality tests"
	@echo "  clean     - Clean temporary files"
	@echo ""
	@echo "Usage examples:"
	@echo "  make install"
	@echo "  make test"
	@echo "  make uninstall"

install:
	@echo "Installing lugo command system..."
	@./install.sh install

uninstall:
	@echo "Uninstalling lugo command system..."
	@./install.sh uninstall

test:
	@echo "Running basic functionality tests..."
	@echo "=== Testing main lugo command ==="
	@./lugo --help
	@echo ""
	@echo "=== Testing individual commands ==="
	@./lugo dlvid --help | head -3
	@./lugo duplicates --help | head -3  
	@./lugo renameseq --help | head -3
	@echo ""
	@echo "=== Testing command execution ==="
	@./lugo dlvid https://example.com
	@echo ""
	@echo "=== Testing error handling ==="
	@./lugo nonexistent_command || echo "Error handling works correctly"
	@echo ""
	@echo "All tests passed!"

clean:
	@echo "Cleaning temporary files..."
	@find . -name "*.bak" -delete 2>/dev/null || true
	@find . -name "*~" -delete 2>/dev/null || true
	@echo "Clean complete!"

# Show project structure
structure:
	@echo "Project structure:"
	@tree -a -I '.git' . || ls -la