# GodPackage

A description of this package.

## Package Dependencies
```mermaid
graph TD;
    AboutFeature-->Constants;
    AppFeature-->Constants;
    AppFeature-->NavigationFeature;
    NavigationFeature-->AboutFeature;
    NavigationFeature-->ActivityFeature;
    NavigationFeature-->AddFeature;
    NavigationFeature-->GodFeature;
    NavigationFeature-->InboxFeature;
    NavigationFeature-->ProfileFeature;
    ProfileEditFeature-->ManageAccountFeature;
    ProfileFeature-->ProfileEditFeature;
```