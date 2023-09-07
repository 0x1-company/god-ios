bootstrap: secrets

open: # Open project in Xcode
	open God.xcworkspace

clean: # Clean all build folders
	rm -rf **/*/.build

secrets: # Set secrets
	echo $(FILE_FIREBASE_STAGING) | base64 -D > App/Multiplatform/Staging/GoogleService-Info.plist
	echo $(FILE_FIREBASE_PRODUCTION) | base64 -D > App/Multiplatform/Production/GoogleService-Info.plist

install-template: # Install template
	@swift build -c release --package-path ./BuildTools/XCTemplateInstallerTool --product XCTemplateInstaller
	./BuildTools/XCTemplateInstallerTool/.build/release/XCTemplateInstaller --xctemplate-path XCTemplates/TCA.xctemplate

gql-schema:
	@cp ../godapp.jp/apps/god-server/schema.gql ./GraphQL/schema.graphqls

apollo-cli-install:
	@swift package --package-path ./BuildTools/ApolloTool --allow-writing-to-package-directory apollo-cli-install

apollo-generate:
	./BuildTools/ApolloTool/apollo-ios-cli generate --ignore-version-mismatch

format:
	@swift build -c release --package-path ./BuildTools/SwiftFormatTool --product swiftformat
	./BuildTools/SwiftFormatTool/.build/release/swiftformat ./
