using APIMDemo.Models;

namespace APIMDemo.Interfaces;

public interface IProductService
{
    Task<IEnumerable<Product>> GetAllProductsAsync();
    Task<Product?> GetProductByIdAsync(int id);
    Task<Product> CreateProductAsync(Product product);
    Task<Product?> UpdateProductAsync(int id, Product product);
    Task<bool> DeleteProductAsync(int id);
}

public interface IProductServiceV2 : IProductService
{
    Task<IEnumerable<ProductV2>> GetProductsByCategoryAsync(string category);
    Task<ProductV2?> GetProductWithStockAsync(int id);
}
