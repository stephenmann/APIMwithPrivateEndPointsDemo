using APIMDemo.Interfaces;
using APIMDemo.Models;

namespace APIMDemo.Services;

public class OrderServiceV2 : OrderService, IOrderServiceV2
{
    private static readonly List<OrderV2> _ordersV2 = new()
    {
        new OrderV2
        {
            Id = 1,
            OrderDate = DateTime.UtcNow.AddDays(-5),
            CustomerName = "John Doe",
            Items = new List<OrderItem>
            {
                new OrderItem { ProductId = 1, ProductName = "Laptop", Quantity = 1, UnitPrice = 1299.99m },
                new OrderItem { ProductId = 3, ProductName = "Headphones", Quantity = 1, UnitPrice = 199.99m }
            },
            ShippingAddress = "123 Main St, Anytown, USA",
            Status = "Shipped",
            TrackingNumber = "TRK123456789",
            EstimatedDeliveryDate = DateTime.UtcNow.AddDays(2)
        },
        new OrderV2
        {
            Id = 2,
            OrderDate = DateTime.UtcNow.AddDays(-3),
            CustomerName = "Jane Smith",
            Items = new List<OrderItem>
            {
                new OrderItem { ProductId = 2, ProductName = "Smartphone", Quantity = 1, UnitPrice = 799.99m }
            },
            ShippingAddress = "456 Oak Ave, Somewhere, USA",
            Status = "Processing",
            TrackingNumber = "",
            EstimatedDeliveryDate = null
        }
    };

    public Task<IEnumerable<OrderV2>> GetOrdersByCustomerAsync(string customerName)
    {
        var orders = _ordersV2.Where(o => o.CustomerName.Contains(customerName, StringComparison.OrdinalIgnoreCase));
        return Task.FromResult(orders);
    }

    public Task<OrderV2?> UpdateOrderStatusAsync(int id, string status)
    {
        var order = _ordersV2.FirstOrDefault(o => o.Id == id);
        if (order == null) return Task.FromResult<OrderV2?>(null);

        order.Status = status;
        return Task.FromResult<OrderV2?>(order);
    }

    public Task<OrderV2?> UpdateTrackingInfoAsync(int id, string trackingNumber, DateTime estimatedDelivery)
    {
        var order = _ordersV2.FirstOrDefault(o => o.Id == id);
        if (order == null) return Task.FromResult<OrderV2?>(null);

        order.TrackingNumber = trackingNumber;
        order.EstimatedDeliveryDate = estimatedDelivery;
        order.Status = "Shipped";
        
        return Task.FromResult<OrderV2?>(order);
    }
}
