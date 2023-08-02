.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?# .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":[^#]*? #| #"}; {printf "%-36s%s\n", $$1 $$3, $$2}'

.PHONY: open
open: # Open project in Xcode
	open God.xcworkspace

.PHONY: clean
clean: # Clean all build folders
	rm -rf **/*/.build
