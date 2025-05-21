using APIMDemo.Interfaces;
using APIMDemo.Models;
using Microsoft.AspNetCore.Mvc;

namespace APIMDemo.Controllers.v1;

[ApiController]
[Route("api/v1/products")]
[ApiVersion("1.0")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(IProductService productService, ILogger<ProductsController> logger)
    {
        _productService = productService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Product>>> GetProducts()
    {
        _logger.LogInformation("Getting all products (v1)");
        var products = await _productService.GetAllProductsAsync();
        return Ok(products);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Product>> GetProduct(int id)
    {
        _logger.LogInformation("Getting product with ID: {Id} (v1)", id);
        var product = await _productService.GetProductByIdAsync(id);
        
        if (product == null)
        {
            _logger.LogWarning("Product with ID: {Id} not found (v1)", id);
            return NotFound();
        }

        return Ok(product);
    }

    [HttpPost]
    public async Task<ActionResult<Product>> CreateProduct(Product product)
    {
        _logger.LogInformation("Creating a new product (v1)");
        var createdProduct = await _productService.CreateProductAsync(product);
        return CreatedAtAction(nameof(GetProduct), new { id = createdProduct.Id }, createdProduct);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateProduct(int id, Product product)
    {
        _logger.LogInformation("Updating product with ID: {Id} (v1)", id);
        var updatedProduct = await _productService.UpdateProductAsync(id, product);
        
        if (updatedProduct == null)
        {
            _logger.LogWarning("Product with ID: {Id} not found for update (v1)", id);
            return NotFound();
        }

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteProduct(int id)
    {
        _logger.LogInformation("Deleting product with ID: {Id} (v1)", id);
        var result = await _productService.DeleteProductAsync(id);
        
        if (!result)
        {
            _logger.LogWarning("Product with ID: {Id} not found for deletion (v1)", id);
            return NotFound();
        }

        return NoContent();
    }
}
