using APIMDemo.Interfaces;
using APIMDemo.Models;

namespace APIMDemo.Services;

public class OrderService : IOrderService
{
    private static readonly List<Order> _orders = new()
    {
        new Order
        {
            Id = 1,
            OrderDate = DateTime.UtcNow.AddDays(-5),
            CustomerName = "John Doe",
            Items = new List<OrderItem>
            {
                new OrderItem { ProductId = 1, ProductName = "Laptop", Quantity = 1, UnitPrice = 1299.99m },
                new OrderItem { ProductId = 3, ProductName = "Headphones", Quantity = 1, UnitPrice = 199.99m }
            }
        },
        new Order
        {
            Id = 2,
            OrderDate = DateTime.UtcNow.AddDays(-3),
            CustomerName = "Jane Smith",
            Items = new List<OrderItem>
            {
                new OrderItem { ProductId = 2, ProductName = "Smartphone", Quantity = 1, UnitPrice = 799.99m }
            }
        }
    };

    private static int _nextId = _orders.Count + 1;

    public Task<IEnumerable<Order>> GetAllOrdersAsync()
    {
        return Task.FromResult<IEnumerable<Order>>(_orders);
    }

    public Task<Order?> GetOrderByIdAsync(int id)
    {
        var order = _orders.FirstOrDefault(o => o.Id == id);
        return Task.FromResult(order);
    }

    public Task<Order> CreateOrderAsync(Order order)
    {
        order.Id = _nextId++;
        _orders.Add(order);
        return Task.FromResult(order);
    }

    public Task<Order?> UpdateOrderAsync(int id, Order order)
    {
        var existingOrder = _orders.FirstOrDefault(o => o.Id == id);
        if (existingOrder == null) return Task.FromResult<Order?>(null);

        existingOrder.CustomerName = order.CustomerName;
        existingOrder.Items = order.Items;

        return Task.FromResult<Order?>(existingOrder);
    }

    public Task<bool> DeleteOrderAsync(int id)
    {
        var order = _orders.FirstOrDefault(o => o.Id == id);
        if (order == null) return Task.FromResult(false);

        _orders.Remove(order);
        return Task.FromResult(true);
    }
}
