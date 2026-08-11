using Store.Components;
using Store.Services;

var builder = WebApplication.CreateBuilder(args);

// add aspire service defaults
builder.AddServiceDefaults();

builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<ICartService, CartService>();
builder.Services.AddScoped<ICheckoutService, CheckoutService>();

var productServiceBaseAddress = builder.Configuration["ProductService:BaseAddress"]
    ?? builder.Configuration["ProductEndpoint"]
    ?? string.Empty;

if (string.IsNullOrWhiteSpace(productServiceBaseAddress))
{
    throw new InvalidOperationException(
        "Product service base address is missing. Configure ProductService:BaseAddress (or ProductEndpoint)."
    );
}

builder.Services.AddHttpClient<IProductService, ProductService>(
    client => client.BaseAddress = new Uri(productServiceBaseAddress));

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

var app = builder.Build();

// aspire map default endpoints
app.MapDefaultEndpoints();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();
app.MapStaticAssets();
app.UseAntiforgery();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();
