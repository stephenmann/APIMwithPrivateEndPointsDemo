using APIMDemo.Interfaces;
using APIMDemo.Models;
using Microsoft.AspNetCore.Mvc;

namespace APIMDemo.Controllers.v2;

[ApiController]
[Route("api/v2/products")]
[ApiVersion("2.0")]
public class ProductsController : ControllerBase
{
    private readonly IProductServiceV2 _productService;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(IProductServiceV2 productService, ILogger<ProductsController> logger)
    {
        _productService = productService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<ProductV2>>> GetProducts()
    {
        _logger.LogInformation("Getting all products (v2)");
        var products = await _productService.GetAllProductsAsync();
        // Convert to ProductV2 or ensure we return ProductV2 instances
        return Ok(products.Select(p => p is ProductV2 v2 ? v2 : new ProductV2
        {
            Id = p.Id,
            Name = p.Name,
            Description = p.Description,
            Price = p.Price,
            Category = p.Category,
            SKU = $"SKU-{p.Id}",
            StockQuantity = 0
        }));
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<ProductV2>> GetProduct(int id)
    {
        _logger.LogInformation("Getting product with ID: {Id} (v2)", id);
        var product = await _productService.GetProductWithStockAsync(id);
        
        if (product == null)
        {
            _logger.LogWarning("Product with ID: {Id} not found (v2)", id);
            return NotFound();
        }

        return Ok(product);
    }

    [HttpGet("category/{category}")]
    public async Task<ActionResult<IEnumerable<ProductV2>>> GetProductsByCategory(string category)
    {
        _logger.LogInformation("Getting products by category: {Category} (v2)", category);
        var products = await _productService.GetProductsByCategoryAsync(category);
        return Ok(products);
    }

    [HttpPost]
    public async Task<ActionResult<ProductV2>> CreateProduct(ProductV2 product)
    {
        _logger.LogInformation("Creating a new product (v2)");
        var createdProduct = await _productService.CreateProductAsync(product);
        return CreatedAtAction(nameof(GetProduct), new { id = createdProduct.Id }, createdProduct);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateProduct(int id, ProductV2 product)
    {
        _logger.LogInformation("Updating product with ID: {Id} (v2)", id);
        var updatedProduct = await _productService.UpdateProductAsync(id, product);
        
        if (updatedProduct == null)
        {
            _logger.LogWarning("Product with ID: {Id} not found for update (v2)", id);
            return NotFound();
        }

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteProduct(int id)
    {
        _logger.LogInformation("Deleting product with ID: {Id} (v2)", id);
        var result = await _productService.DeleteProductAsync(id);
        
        if (!result)
        {
            _logger.LogWarning("Product with ID: {Id} not found for deletion (v2)", id);
            return NotFound();
        }

        return NoContent();
    }
}
