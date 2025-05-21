namespace APIMDemo.Models;

public class Order
{
    public int Id { get; set; }
    public DateTime OrderDate { get; set; } = DateTime.UtcNow;
    public string CustomerName { get; set; } = string.Empty;
    public List<OrderItem> Items { get; set; } = new List<OrderItem>();
    public decimal TotalAmount => Items.Sum(i => i.Quantity * i.UnitPrice);
}

public class OrderItem
{
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
}

public class OrderV2 : Order
{
    public string ShippingAddress { get; set; } = string.Empty;
    public string Status { get; set; } = "Pending";
    public string TrackingNumber { get; set; } = string.Empty;
    public DateTime? EstimatedDeliveryDate { get; set; }
}
