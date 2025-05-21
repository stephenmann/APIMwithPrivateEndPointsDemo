namespace APIMDemo.Models;

public class Product
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string Category { get; set; } = string.Empty;
}

public class ProductV2 : Product
{
    public string SKU { get; set; } = string.Empty;
    public int StockQuantity { get; set; }
    public bool IsAvailable => StockQuantity > 0;
    public DateTime LastUpdated { get; set; } = DateTime.UtcNow;
}
