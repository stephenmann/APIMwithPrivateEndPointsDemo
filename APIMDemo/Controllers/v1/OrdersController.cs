using APIMDemo.Interfaces;
using APIMDemo.Models;
using Microsoft.AspNetCore.Mvc;

namespace APIMDemo.Controllers.v1;

[ApiController]
[Route("api/orders")]
[ApiVersion("1.0")]
public class OrdersController : ControllerBase
{
    private readonly IOrderService _orderService;
    private readonly ILogger<OrdersController> _logger;

    public OrdersController(IOrderService orderService, ILogger<OrdersController> logger)
    {
        _orderService = orderService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Order>>> GetOrders()
    {
        _logger.LogInformation("Getting all orders (v1)");
        var orders = await _orderService.GetAllOrdersAsync();
        return Ok(orders);
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<Order>> GetOrder(int id)
    {
        _logger.LogInformation("Getting order with ID: {Id} (v1)", id);
        var order = await _orderService.GetOrderByIdAsync(id);
        
        if (order == null)
        {
            _logger.LogWarning("Order with ID: {Id} not found (v1)", id);
            return NotFound();
        }

        return Ok(order);
    }

    [HttpPost]
    public async Task<ActionResult<Order>> CreateOrder(Order order)
    {
        _logger.LogInformation("Creating a new order (v1)");
        var createdOrder = await _orderService.CreateOrderAsync(order);
        return CreatedAtAction(nameof(GetOrder), new { id = createdOrder.Id }, createdOrder);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateOrder(int id, Order order)
    {
        _logger.LogInformation("Updating order with ID: {Id} (v1)", id);
        var updatedOrder = await _orderService.UpdateOrderAsync(id, order);
        
        if (updatedOrder == null)
        {
            _logger.LogWarning("Order with ID: {Id} not found for update (v1)", id);
            return NotFound();
        }

        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteOrder(int id)
    {
        _logger.LogInformation("Deleting order with ID: {Id} (v1)", id);
        var result = await _orderService.DeleteOrderAsync(id);
        
        if (!result)
        {
            _logger.LogWarning("Order with ID: {Id} not found for deletion (v1)", id);
            return NotFound();
        }

        return NoContent();
    }
}
