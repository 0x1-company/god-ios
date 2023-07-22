.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?# .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":[^#]*? #| #"}; {printf "%-36s%s\n", $$1 $$3, $$2}'

.PHONY: open
open: # Open project in Xcode
	open god.xcworkspace

.PHONY: clean
clean: # Clean all build folders
	rm -rf **/*/.build

.PHONY: dgraph
dgraph: # Generate dependencies graph
	@swift build -c release --package-path ./BuildTools/DependenciesGraph --product dgraph
	./BuildTools/DependenciesGraph/.build/release/dgraph --add-to-readme ./Packages/CupertinoPackage
	./BuildTools/DependenciesGraph/.build/release/dgraph --add-to-readme ./Packages/FirebasePackage
	./BuildTools/DependenciesGraph/.build/release/dgraph --add-to-readme ./Packages/GodPackage

.PHONY: format
format: # Format swift files
	@swift build -c release --package-path ./BuildTools/SwiftFormatTool --product swiftformat
	./BuildTools/SwiftFormatTool/.build/release/swiftformat ./
