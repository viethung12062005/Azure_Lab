using Azure.AI.OpenAI;
using Azure.Identity;
using Azure.Storage.Blobs;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.AI;
using Products.Endpoints;
using Products.Memory;
using Products.Models;
using System.ClientModel;

var builder = WebApplication.CreateBuilder(args);

// Disable Globalization Invariant Mode
Environment.SetEnvironmentVariable("DOTNET_SYSTEM_GLOBALIZATION_INVARIANT", "false");

// add aspire service defaults
builder.AddServiceDefaults();
builder.Services.AddProblemDetails();

var connectionString = builder.Configuration.GetConnectionString("ProductsContext");
if (string.IsNullOrWhiteSpace(connectionString))
{
    if (builder.Environment.IsDevelopment())
    {
        connectionString = "Server=(localdb)\\MSSQLLocalDB;Database=Products;Trusted_Connection=True;MultipleActiveResultSets=True;TrustServerCertificate=True";
    }
    else
    {
        throw new InvalidOperationException("Connection string 'ProductsContext' not found.");
    }
}

// Add DbContext service (SQL Server for production; localdb fallback only for development)
builder.Services.AddDbContext<Context>(options =>
    options.UseSqlServer(connectionString, sqlOptions => sqlOptions.EnableRetryOnFailure()));

// Read explicit Azure OpenAI parameters wired from AppHost.
// In run mode these come from the Aspire parameters (user-secrets in eShopAppHost).
// In publish mode they come from the provisioned Azure OpenAI resource via azd.
var endpoint = builder.Configuration["AzureOpenAI:Endpoint"]
    ?? builder.Configuration["AzureOpenAIEndpoint"]
    ?? string.Empty;
var apiKey = builder.Configuration["AzureOpenAI:ApiKey"]
    ?? builder.Configuration["AzureOpenAIApiKey"]
    ?? string.Empty;
var chatDeploymentName = builder.Configuration["AzureOpenAI:ChatDeploymentName"]
    ?? builder.Configuration["AzureOpenAIDeploymentName"]
    ?? "gpt-4.1-mini";
var embeddingsDeploymentName = builder.Configuration["AzureOpenAI:EmbeddingsDeploymentName"]
    ?? builder.Configuration["AzureOpenAIEmbeddingsDeploymentName"]
    ?? "text-embedding-ada-002";

if (string.IsNullOrWhiteSpace(endpoint))
{
    throw new InvalidOperationException(
        "Azure OpenAI endpoint is missing. Configure AzureOpenAI:Endpoint (or AzureOpenAIEndpoint)."
    );
}

// Build client: use ApiKeyCredential when a key is present; fall back to DefaultAzureCredential
// for managed-identity scenarios (publish/azd mode).
AzureOpenAIClient aoaiClient = string.IsNullOrWhiteSpace(apiKey)
    ? new AzureOpenAIClient(new Uri(endpoint), new DefaultAzureCredential())
    : new AzureOpenAIClient(new Uri(endpoint), new ApiKeyCredential(apiKey));

builder.Services.AddSingleton(aoaiClient);
builder.Services.AddChatClient(aoaiClient.GetChatClient(chatDeploymentName).AsIChatClient());
builder.Services.AddEmbeddingGenerator(
    aoaiClient.GetEmbeddingClient(embeddingsDeploymentName).AsIEmbeddingGenerator());

builder.Services.AddSingleton<IConfiguration>(sp =>
{
    return builder.Configuration;
});

// add memory context
builder.Services.AddSingleton(sp =>
{
    var logger = sp.GetService<ILogger<Program>>();
    logger.LogInformation("Creating memory context");
    return new MemoryContext(logger, sp.GetService<IChatClient>(), sp.GetService<IEmbeddingGenerator<string, Embedding<float>>>());
});

builder.Services.AddSingleton(sp =>
{
    string blobServiceEndpoint = builder.Configuration["AzureBlobStorage:Endpoint"]
        ?? builder.Configuration["AzureBlobStorageEndpoint"]
        ?? builder.Configuration["StorageAccountEndpoint"]
        ?? string.Empty;

    if (string.IsNullOrWhiteSpace(blobServiceEndpoint))
    {
        throw new InvalidOperationException(
            "Blob endpoint is missing. Configure AzureBlobStorage:Endpoint (or AzureBlobStorageEndpoint/StorageAccountEndpoint)."
        );
    }

    return new BlobServiceClient(new Uri(blobServiceEndpoint), new DefaultAzureCredential());
});

// Add services to the container.
var app = builder.Build();

// aspire map default endpoints
app.MapDefaultEndpoints();

// Configure the HTTP request pipeline.
app.UseHttpsRedirection();

app.MapProductEndpoints();

app.UseStaticFiles();

// log Azure OpenAI resources
app.Logger.LogInformation($"Azure OpenAI resources\n >> Endpoint: {endpoint}\n >> Chat deployment: {chatDeploymentName}\n >> Embeddings deployment: {embeddingsDeploymentName}");
AppContext.SetSwitch("OpenAI.Experimental.EnableOpenTelemetry", true);

// manage db
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<Context>();
    try
    {
        app.Logger.LogInformation("Apply database migrations");
        context.Database.Migrate();
    }
    catch (Exception exc)
    {
        app.Logger.LogError(exc, "Error creating database");
    }
    DbInitializer.Initialize(context);

    app.Logger.LogInformation("Start fill products in vector db");
    var memoryContext = app.Services.GetRequiredService<MemoryContext>();
    await memoryContext.InitMemoryContextAsync(context);
    app.Logger.LogInformation("Done fill products in vector db");
}

app.Run();