# Products API

## Overview

The Products API provides product catalog and search capabilities. It is a core service in the scenario.

## Registration

```csharp
var products = builder.AddProject<Projects.Products>("products")
    .WithHttpHealthCheck("/health")
    .WithExternalHttpEndpoints();
```

## Configuration

- Exposes HTTP endpoints for user access.
- Health check endpoint: `/health`
- Receives AI/OpenAI config via environment variables.

## External Dependencies

- Azure App Service
- Azure OpenAI (in publish mode)
