# GodPackage

A description of this package.

## Package Dependencies
```mermaid
graph TD;
    AppFeature-->NavigationFeature;
    NavigationFeature-->AboutFeature;
    NavigationFeature-->ActivityFeature;
    NavigationFeature-->GodFeature;
    NavigationFeature-->InboxFeature;
    NavigationFeature-->ProfileFeature;
    ProfileEditFeature-->ManageAccountFeature;
    ProfileFeature-->ProfileEditFeature;
```