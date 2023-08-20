.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?# .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":[^#]*? #| #"}; {printf "%-36s%s\n", $$1 $$3, $$2}'

bootstrap: secrets

.PHONY: open
open: # Open project in Xcode
	open God.xcworkspace

.PHONY: clean
clean: # Clean all build folders
	rm -rf **/*/.build

.PHONY: secrets
secrets: # Set secrets
	echo $(FILE_FIREBASE_STAGING) | base64 -D > App/Multiplatform/Staging/GoogleService-Info.plist
	echo $(FILE_FIREBASE_PRODUCTION) | base64 -D > App/Multiplatform/Production/GoogleService-Info.plist

.PHONY: install-template
install-template: # Install template
	@swift build -c release --package-path ./BuildTools/XCTemplateInstallerTool --product XCTemplateInstaller
	./BuildTools/XCTemplateInstallerTool/.build/release/XCTemplateInstaller --xctemplate-path XCTemplates/TCA.xctemplate

apollo-cli-install:
	@swift package --package-path ./Packages/DependencyPackage --allow-writing-to-package-directory apollo-cli-install

apollo-generate:
	./Packages/DependencyPackage/apollo-ios-cli generate --ignore-version-mismatch