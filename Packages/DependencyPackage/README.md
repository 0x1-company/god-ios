# DependencyPackage

A description of this package.

## Package Dependencies
```mermaid
graph TD;
    FirestoreClientTests-->FirestoreClient;
    GodClient-->God;
    GodClient-->ApolloConcurrency;
    GodTestMock-->God;
    ShareLinkBuilderTests-->ShareLinkBuilder;
    ShareLinkClientLive-->God;
    ShareLinkClientLive-->ShareLinkClient;
    StringHelpersTests-->StringHelpers;
```
