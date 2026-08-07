# Store UI

## Overview

The Store UI is the frontend web application for browsing and searching products.

## Registration

```csharp
var store = builder.AddProject<Projects.Store>("store")
    .WithReference(products)
    .WaitFor(products)
    .WithHttpHealthCheck("/health")
    .WithExternalHttpEndpoints();
```

## Configuration

- Depends on Products API.
- Exposes HTTP endpoints for user access.
- Health check endpoint: `/health`

## External Dependencies

- Products API
- Azure App Service
