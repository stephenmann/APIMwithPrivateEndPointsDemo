using APIMDemo.Interfaces;
using APIMDemo.Models;
using Microsoft.AspNetCore.Mvc;

namespace APIMDemo.Controllers.v2;

[ApiController]
[Route("api/v2/orders")]
[ApiVersion("2.0")]
public class OrdersController : ControllerBase
{
    private readonly IOrderServiceV2 _orderService;
    private readonly ILogger<OrdersController> _logger;

    public OrdersController(IOrderServiceV2 orderService, ILogger<OrdersController> logger)
    {
        _orderService = orderService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<OrderV2>>> GetOrders()
    {
        _logger.LogInformation("Getting all orders (v2)");
        var orders = await _orderService.GetAllOrdersAsync();
        // Convert to OrderV2 or ensure we return OrderV2 instances
        return Ok(orders.Select(o => o is OrderV2 v2 ? v2 : new OrderV2
        {
            Id = o.Id,
            CustomerName = o.CustomerName,
            OrderDate = o.OrderDate,
            Items = o.Items,
            ShippingAddress = "N/A",
            Status = "Unknown",
            TrackingNumber = string.Empty
        }));
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<OrderV2>> GetOrder(int id)
    {
        _logger.LogInformation("Getting order with ID: {Id} (v2)", id);
        var order = await _orderService.GetOrderByIdAsync(id);
        
        if (order == null)
        {
            _logger.LogWarning("Order with ID: {Id} not found (v2)", id);
            return NotFound();
        }

        if (order is OrderV2 orderV2)
        {
            return Ok(orderV2);
        }
        
        // Convert to V2 if needed
        var convertedOrder = new OrderV2
        {
            Id = order.Id,
            CustomerName = order.CustomerName,
            OrderDate = order.OrderDate,
            Items = order.Items,
            ShippingAddress = "N/A",
            Status = "Unknown",
            TrackingNumber = string.Empty
        };
        
        return Ok(convertedOrder);
    }

    [HttpGet("customer/{customerName}")]
    public async Task<ActionResult<IEnumerable<OrderV2>>> GetOrdersByCustomer(string customerName)
    {
        _logger.LogInformation("Getting orders for customer: {CustomerName} (v2)", customerName);
        var orders = await _orderService.GetOrdersByCustomerAsync(customerName);
        return Ok(orders);
    }

    [HttpPost]
    public async Task<ActionResult<OrderV2>> CreateOrder(OrderV2 order)
    {
        _logger.LogInformation("Creating a new order (v2)");
        var createdOrder = await _orderService.CreateOrderAsync(order);
        return CreatedAtAction(nameof(GetOrder), new { id = createdOrder.Id }, createdOrder);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateOrder(int id, OrderV2 order)
    {
        _logger.LogInformation("Updating order with ID: {Id} (v2)", id);
        var updatedOrder = await _orderService.UpdateOrderAsync(id, order);
        
        if (updatedOrder == null)
        {
            _logger.LogWarning("Order with ID: {Id} not found for update (v2)", id);
            return NotFound();
        }

        return NoContent();
    }

    [HttpPut("{id}/status")]
    public async Task<ActionResult<OrderV2>> UpdateOrderStatus(int id, [FromBody] string status)
    {
        _logger.LogInformation("Updating status for order with ID: {Id} to {Status} (v2)", id, status);
        var updatedOrder = await _orderService.UpdateOrderStatusAsync(id, status);
        
        if (updatedOrder == null)
        {
            _logger.LogWarning("Order with ID: {Id} not found for status update (v2)", id);
            return NotFound();
        }

        return Ok(updatedOrder);
    }

    [HttpPut("{id}/tracking")]
    public async Task<ActionResult<OrderV2>> UpdateTrackingInfo(int id, [FromBody] TrackingInfo trackingInfo)
    {
        _logger.LogInformation("Updating tracking info for order with ID: {Id} (v2)", id);
        var updatedOrder = await _orderService.UpdateTrackingInfoAsync(id, trackingInfo.TrackingNumber, trackingInfo.EstimatedDeliveryDate);
        
        if (updatedOrder == null)
        {
            _logger.LogWarning("Order with ID: {Id} not found for tracking update (v2)", id);
            return NotFound();
        }

        return Ok(updatedOrder);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteOrder(int id)
    {
        _logger.LogInformation("Deleting order with ID: {Id} (v2)", id);
        var result = await _orderService.DeleteOrderAsync(id);
        
        if (!result)
        {
            _logger.LogWarning("Order with ID: {Id} not found for deletion (v2)", id);
            return NotFound();
        }

        return NoContent();
    }
}

public class TrackingInfo
{
    public string TrackingNumber { get; set; } = string.Empty;
    public DateTime EstimatedDeliveryDate { get; set; }
}
