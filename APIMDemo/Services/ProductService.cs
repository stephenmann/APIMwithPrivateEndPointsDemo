using APIMDemo.Interfaces;
using APIMDemo.Models;

namespace APIMDemo.Services;

public class ProductService : IProductService
{
    private static readonly List<Product> _products = new()
    {
        new Product { Id = 1, Name = "Laptop", Description = "High-performance laptop", Price = 1299.99m, Category = "Electronics" },
        new Product { Id = 2, Name = "Smartphone", Description = "Latest smartphone model", Price = 799.99m, Category = "Electronics" },
        new Product { Id = 3, Name = "Headphones", Description = "Noise-cancelling headphones", Price = 199.99m, Category = "Audio" },
        new Product { Id = 4, Name = "Monitor", Description = "27-inch 4K monitor", Price = 349.99m, Category = "Electronics" },
        new Product { Id = 5, Name = "Keyboard", Description = "Mechanical keyboard", Price = 129.99m, Category = "Accessories" }
    };

    private static int _nextId = _products.Count + 1;

    public Task<IEnumerable<Product>> GetAllProductsAsync()
    {
        return Task.FromResult<IEnumerable<Product>>(_products);
    }

    public Task<Product?> GetProductByIdAsync(int id)
    {
        var product = _products.FirstOrDefault(p => p.Id == id);
        return Task.FromResult(product);
    }

    public Task<Product> CreateProductAsync(Product product)
    {
        product.Id = _nextId++;
        _products.Add(product);
        return Task.FromResult(product);
    }

    public Task<Product?> UpdateProductAsync(int id, Product product)
    {
        var existingProduct = _products.FirstOrDefault(p => p.Id == id);
        if (existingProduct == null) return Task.FromResult<Product?>(null);

        existingProduct.Name = product.Name;
        existingProduct.Description = product.Description;
        existingProduct.Price = product.Price;
        existingProduct.Category = product.Category;

        return Task.FromResult<Product?>(existingProduct);
    }

    public Task<bool> DeleteProductAsync(int id)
    {
        var product = _products.FirstOrDefault(p => p.Id == id);
        if (product == null) return Task.FromResult(false);

        _products.Remove(product);
        return Task.FromResult(true);
    }
}
