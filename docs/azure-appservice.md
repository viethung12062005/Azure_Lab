# Azure App Service Environment

## Overview

Azure App Service Environment is used to host and manage the web applications (Products and Store) in a scalable, secure, and managed Azure environment.

## Registration

```csharp
var appsvc = builder.AddAzureAppServiceEnvironment("appsvc");
```

## Configuration

- Managed by Aspire and Azure.
- No manual config needed for local dev.

## External Dependencies

- Azure App Service Environment
