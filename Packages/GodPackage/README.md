# GodPackage

A description of this package.

## Package Dependencies
```mermaid
graph TD;
    AboutFeature-->Constants;
    AboutFeature-->HowItWorksFeature;
    AppFeature-->OnboardFeature;
    AppFeature-->NavigationFeature;
    AppFeature-->ForceUpdateFeature;
    AppFeature-->MaintenanceFeature;
    ForceUpdateFeature-->Constants;
    InboxFeature-->GodModeFeature;
    InboxFeature-->ShareScreenshotFeature;
    NavigationFeature-->AboutFeature;
    NavigationFeature-->ActivityFeature;
    NavigationFeature-->AddFeature;
    NavigationFeature-->GodFeature;
    NavigationFeature-->InboxFeature;
    NavigationFeature-->ProfileFeature;
    OnboardFeature-->HowItWorksFeature;
    OnboardFeature-->GenderSettingFeature;
    ProfileEditFeature-->ManageAccountFeature;
    ProfileFeature-->ShopFeature;
    ProfileFeature-->ProfileEditFeature;
    ProfileFeature-->ProfileShareFeature;
```