using APIMDemo.Interfaces;
using APIMDemo.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Versioning;
using Microsoft.AspNetCore.Mvc.ApiExplorer;
using Microsoft.AspNetCore.Mvc.Controllers;
using Microsoft.Extensions.DependencyInjection;
using Swashbuckle.AspNetCore.SwaggerGen;
using System.Reflection;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();

// Add API versioning
builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.ReportApiVersions = true;
    options.ApiVersionReader = ApiVersionReader.Combine(
        new UrlSegmentApiVersionReader(),
        new HeaderApiVersionReader("X-API-Version"),
        new QueryStringApiVersionReader("api-version")
    );
});

// Add versioned API explorer
builder.Services.AddVersionedApiExplorer(options =>
{
    options.GroupNameFormat = "'v'VVV";  // Format: 'v'major[.minor][-status]
    options.SubstituteApiVersionInUrl = true;
});

// Add Swagger/OpenAPI support with versioning
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    // Define Swagger docs for API versions
    options.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "APIM Demo API v1",
        Version = "1.0",
        Description = "A sample API for demonstrating Azure API Management"
    });

    options.SwaggerDoc("v2", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "APIM Demo API v2",
        Version = "2.0",
        Description = "A sample API for demonstrating Azure API Management with enhanced features"
    });
      // Filter API controllers by version
    options.DocInclusionPredicate((docName, apiDesc) =>
    {        if (!apiDesc.TryGetMethodInfo(out MethodInfo methodInfo)) return false;
        
        // Get controller ApiVersion attributes
        var controllerVersions = methodInfo.DeclaringType?
            .GetCustomAttributes(true)
            .OfType<ApiVersionAttribute>()
            .SelectMany(attr => attr.Versions)
            .ToList() ?? new List<ApiVersion>();
              // Get method ApiVersion attributes that might override controller attributes
        var methodVersions = methodInfo
            .GetCustomAttributes(true)
            .OfType<ApiVersionAttribute>()
            .SelectMany(attr => attr.Versions)
            .ToList() ?? new List<ApiVersion>();
            
        // Use method versions if specified, otherwise use controller versions
        var versions = methodVersions.Any() ? methodVersions : controllerVersions;
            
        // If no explicit version is defined, include in v1
        if (versions == null || !versions.Any())
            return docName == "v1";
            
        // Check if the API version matches the Swagger doc version
        return versions.Any(v => $"v{v.MajorVersion}" == docName);
    });
});

// Register services
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<IProductServiceV2, ProductServiceV2>();
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddScoped<IOrderServiceV2, OrderServiceV2>();

// Configure HTTPS redirection with explicit port
builder.Services.AddHttpsRedirection(options =>
{
    options.HttpsPort = 7026; // This should match the HTTPS port in launchSettings.json
    options.RedirectStatusCode = StatusCodes.Status307TemporaryRedirect;
});

var app = builder.Build();

// Get the API version description provider
var apiVersionDescriptionProvider = app.Services.GetRequiredService<IApiVersionDescriptionProvider>();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        // Build a swagger endpoint for each discovered API version
        foreach (var description in apiVersionDescriptionProvider.ApiVersionDescriptions)
        {
            options.SwaggerEndpoint(
                $"/swagger/{description.GroupName}/swagger.json", 
                $"APIM Demo API {description.GroupName}"
            );
        }
        
        // Enable deep linking for better navigation
        options.EnableDeepLinking();
        
        // Display the API versions in the UI
        options.DisplayOperationId();
        options.DisplayRequestDuration();
        
        // Optional: Set the default version to show when opening Swagger UI
        // options.RoutePrefix = "api-docs";
        // options.DefaultModelsExpandDepth(-1); // Hide models by default
    });
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
