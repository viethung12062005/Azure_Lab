# Azure OpenAI

## Overview

Azure OpenAI provides AI-powered chat and semantic search capabilities for the scenario.

## Registration

```csharp
if (builder.ExecutionContext.IsPublishMode)
{
    var chatDeploymentName = "gpt-41-mini";
    var embeddingsDeploymentName = "text-embedding-ada-002";
    var aoai = builder.AddAzureOpenAI("openai");

    var gpt41mini = aoai.AddDeployment(name: chatDeploymentName,
            modelName: "gpt-4.1-mini",
            modelVersion: "2025-04-14");
    gpt41mini.Resource.SkuCapacity = 10;
    gpt41mini.Resource.SkuName = "GlobalStandard";

    var embeddingsDeployment = aoai.AddDeployment(name: embeddingsDeploymentName,
        modelName: "text-embedding-ada-002",
        modelVersion: "2");

    products.WithReference(aoai)
        .WithEnvironment("AI_ChatDeploymentName", chatDeploymentName)
        .WithEnvironment("AI_embeddingsDeploymentName", embeddingsDeploymentName);

    store.WithExternalHttpEndpoints();
}
```

## Configuration

- Deployment names and model versions are set in code.
- Keys and endpoints are injected via Aspire or user-secrets.

## External Dependencies

- Azure OpenAI resource (with GPT-4.1-mini and text-embedding-ada-002 deployments)
