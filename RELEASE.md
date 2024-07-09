
# Releasing this library

To release this library, you must complete 3 steps:

1. Update the changelog
2. Release to SPM
3. Release to CocoaPods

## Releasing to SPM

The release to SPM requires you to create a new tag in git. This will be done as part of releasing to CocoaPods.

## Releasing to CocoaPods

To release to CocoaPods you must:

1. Update the `StylableSwiftUI.podspec` version to the new version number
2. Lint the podspec via `bundle exec pod lib lint`
3. Commit these changes
4. Tag the commit with the version number (do not add any prefix or suffix to the tag so it works with SPM too)
5. Push the changes and tags to the remote repo
6. Run `bundle exec pod repo push` to release to CocoaPods trunk 
