using APIMDemo.Models;

namespace APIMDemo.Interfaces;

public interface IOrderService
{
    Task<IEnumerable<Order>> GetAllOrdersAsync();
    Task<Order?> GetOrderByIdAsync(int id);
    Task<Order> CreateOrderAsync(Order order);
    Task<Order?> UpdateOrderAsync(int id, Order order);
    Task<bool> DeleteOrderAsync(int id);
}

public interface IOrderServiceV2 : IOrderService
{
    Task<IEnumerable<OrderV2>> GetOrdersByCustomerAsync(string customerName);
    Task<OrderV2?> UpdateOrderStatusAsync(int id, string status);
    Task<OrderV2?> UpdateTrackingInfoAsync(int id, string trackingNumber, DateTime estimatedDelivery);
}
