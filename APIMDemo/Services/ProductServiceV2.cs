using APIMDemo.Interfaces;
using APIMDemo.Models;

namespace APIMDemo.Services;

public class ProductServiceV2 : ProductService, IProductServiceV2
{
    private static readonly List<ProductV2> _productsV2 = new()
    {
        new ProductV2 { Id = 1, Name = "Laptop", Description = "High-performance laptop", Price = 1299.99m, Category = "Electronics", SKU = "LAP-001", StockQuantity = 15 },
        new ProductV2 { Id = 2, Name = "Smartphone", Description = "Latest smartphone model", Price = 799.99m, Category = "Electronics", SKU = "SPH-002", StockQuantity = 25 },
        new ProductV2 { Id = 3, Name = "Headphones", Description = "Noise-cancelling headphones", Price = 199.99m, Category = "Audio", SKU = "AUD-003", StockQuantity = 40 },
        new ProductV2 { Id = 4, Name = "Monitor", Description = "27-inch 4K monitor", Price = 349.99m, Category = "Electronics", SKU = "MON-004", StockQuantity = 10 },
        new ProductV2 { Id = 5, Name = "Keyboard", Description = "Mechanical keyboard", Price = 129.99m, Category = "Accessories", SKU = "ACC-005", StockQuantity = 30 }
    };

    public Task<IEnumerable<ProductV2>> GetProductsByCategoryAsync(string category)
    {
        var products = _productsV2.Where(p => p.Category.Equals(category, StringComparison.OrdinalIgnoreCase));
        return Task.FromResult(products);
    }

    public Task<ProductV2?> GetProductWithStockAsync(int id)
    {
        var product = _productsV2.FirstOrDefault(p => p.Id == id);
        return Task.FromResult(product);
    }
}
