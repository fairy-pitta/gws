# Makefile for generating portree demo GIFs

DEMO_DIR ?= /tmp/portree-demo
INIT_DIR ?= /tmp/portree-init-demo
PORTREE_BIN ?= $(shell pwd)/../portree
OUTPUT_DIR ?= $(shell pwd)

.PHONY: all setup quickstart tui workflow install init clean

all: install init quickstart tui workflow

# Build portree if not exists
../portree:
	cd .. && go build -o portree .

# Setup demo environment (with .portree.toml already configured)
setup: ../portree
	@echo "Setting up demo environment..."
	@chmod +x setup-demo-env.sh
	@./setup-demo-env.sh "$(DEMO_DIR)" "$(PORTREE_BIN)"

# Setup clean environment for init demo (no .portree.toml)
setup-init: ../portree
	@echo "Setting up init demo environment..."
	@rm -rf "$(INIT_DIR)"
	@mkdir -p "$(INIT_DIR)"
	@cd "$(INIT_DIR)" && git init

# Generate install demo GIF (no setup needed, just shows commands)
install: ../portree
	@echo "Generating install demo..."
	@cd "$(DEMO_DIR)" 2>/dev/null || mkdir -p "$(DEMO_DIR)" && cd "$(DEMO_DIR)" && \
		PATH="$(dir $(PORTREE_BIN)):$$PATH" \
		vhs "$(OUTPUT_DIR)/demo-install.tape" -o "$(OUTPUT_DIR)/demo-install.gif"
	@echo "✅ Created: $(OUTPUT_DIR)/demo-install.gif"

# Generate init demo GIF
init: setup-init
	@echo "Generating init demo..."
	@cd "$(INIT_DIR)" && \
		PATH="$(dir $(PORTREE_BIN)):$$PATH" \
		vhs "$(OUTPUT_DIR)/demo-init.tape" -o "$(OUTPUT_DIR)/demo-init.gif"
	@echo "✅ Created: $(OUTPUT_DIR)/demo-init.gif"

# Generate quickstart demo GIF
quickstart: setup
	@echo "Generating quickstart demo..."
	@cd "$(DEMO_DIR)" && \
		PATH="$(dir $(PORTREE_BIN)):$$PATH" \
		vhs "$(OUTPUT_DIR)/demo-quickstart.tape" -o "$(OUTPUT_DIR)/demo-quickstart.gif"
	@echo "✅ Created: $(OUTPUT_DIR)/demo-quickstart.gif"

# Generate TUI demo GIF
tui: setup
	@echo "Generating TUI dashboard demo..."
	@cd "$(DEMO_DIR)" && \
		PATH="$(dir $(PORTREE_BIN)):$$PATH" \
		vhs "$(OUTPUT_DIR)/demo-tui.tape" -o "$(OUTPUT_DIR)/demo-tui.gif"
	@echo "✅ Created: $(OUTPUT_DIR)/demo-tui.gif"

# Generate workflow demo GIF
workflow: setup
	@echo "Generating workflow demo..."
	@cd "$(DEMO_DIR)" && \
		PATH="$(dir $(PORTREE_BIN)):$$PATH" \
		vhs "$(OUTPUT_DIR)/demo-workflow.tape" -o "$(OUTPUT_DIR)/demo-workflow.gif"
	@echo "✅ Created: $(OUTPUT_DIR)/demo-workflow.gif"

# Clean up
clean:
	rm -rf "$(DEMO_DIR)"
	rm -rf "$(INIT_DIR)"
	rm -f *.gif

# Help
help:
	@echo "Usage:"
	@echo "  make all        - Generate all demo GIFs"
	@echo "  make install    - Generate install demo only"
	@echo "  make init       - Generate init/config demo only"
	@echo "  make quickstart - Generate quickstart demo only"
	@echo "  make tui        - Generate TUI demo only"
	@echo "  make workflow   - Generate workflow demo only"
	@echo "  make setup      - Setup demo environment only"
	@echo "  make clean      - Remove generated files"
