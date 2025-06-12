using Microsoft.EntityFrameworkCore;
using MojeAuto.Model.Common;
using MojeAuto.Model.Requests;
using MojeAuto.Services.Database;

public class OrderService : BaseCrudService<Order, OrderSearchRequest, OrderInsertRequest, OrderUpdateRequest>
{
    public OrderService(MojeAutoContext context) : base(context)
    {
    }

    public override async Task<ServiceResult<IEnumerable<Order>>> Get(OrderSearchRequest search, int? id = null)
    {
        var query = _context.Orders
            .Include(o => o.User)
            .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Part)
            .Include(o => o.PaymentMethod)
            .Include(o => o.OrderStatus)
            .Include(o => o.Delivery).ThenInclude(d => d.DeliveryStatus)
            .OrderByDescending(o => o.OrderDate)
            .AsQueryable();

        if (id.HasValue)
        {
            var entity = await query.FirstOrDefaultAsync(x => x.OrderId == id.Value);
            if (entity == null)
                return ServiceResult<IEnumerable<Order>>.Fail("Order not found.");

            return ServiceResult<IEnumerable<Order>>.Ok(new List<Order> { entity });
        }

        if (search != null)
        {
            if (!string.IsNullOrWhiteSpace(search.User))
            {
                var term = search.User.ToLower();
                query = query.Where(o =>
                    o.User.FirstName.ToLower().Contains(term) ||
                    o.User.LastName.ToLower().Contains(term));
            }

            if (search.UserId.HasValue)
                query = query.Where(o => o.UserId == search.UserId.Value);

            if (search.OrderStatusId.HasValue)
                query = query.Where(o => o.OrderStatusId == search.OrderStatusId.Value);

            if (search.FromDate.HasValue)
                query = query.Where(o => o.OrderDate >= search.FromDate.Value);

            if (search.ToDate.HasValue)
                query = query.Where(o => o.OrderDate <= search.ToDate.Value);
        }

        if (search is BaseSearchRequest pagination && pagination.Page > 0 && pagination.PageSize > 0)
        {
            int skip = (pagination.Page - 1) * pagination.PageSize;
            query = query.Skip(skip).Take(pagination.PageSize + 1);
        }

        var list = await query.ToListAsync();

        if (!list.Any())
            return ServiceResult<IEnumerable<Order>>.Fail("No orders found.");

        return ServiceResult<IEnumerable<Order>>.Ok(list);
    }

    public override async Task<ServiceResult<Order>> Update(int id, OrderUpdateRequest request)
    {
        var order = await _context.Orders
            .Include(o => o.Delivery)
            .FirstOrDefaultAsync(o => o.OrderId == id);

        if (order == null)
            return ServiceResult<Order>.Fail("Order not found.");

        order.OrderStatusId = request.OrderStatusId;

        if (request.PaymentMethodId.HasValue)
            order.PaymentMethodId = request.PaymentMethodId.Value;

        if (request.Delivery != null)
        {
            if (order.Delivery == null)
                return ServiceResult<Order>.Fail("Associated delivery not found.");

            if (request.Delivery.DeliveryMethodId.HasValue)
                order.Delivery.DeliveryMethodId = request.Delivery.DeliveryMethodId.Value;

            if (request.Delivery.DeliveryStatusId.HasValue)
                order.Delivery.DeliveryStatusId = request.Delivery.DeliveryStatusId.Value;

            if (request.Delivery.DeliveryDate.HasValue)
                order.Delivery.DeliveryDate = request.Delivery.DeliveryDate.Value;
        }

        await _context.SaveChangesAsync();

        return ServiceResult<Order>.Ok(order);
    }

    public override async Task<ServiceResult<Order>> Insert(OrderInsertRequest insertRequest)
    {
        var partIds = insertRequest.OrderItems.Select(x => x.PartId).ToList();
        var parts = await _context.Parts
            .Where(p => partIds.Contains(p.PartId))
            .ToDictionaryAsync(p => p.PartId);

        // Validate all parts exist and quantities are available
        foreach (var item in insertRequest.OrderItems)
        {
            if (!parts.TryGetValue(item.PartId, out var part))
                return ServiceResult<Order>.Fail($"Dio sa IDom {item.PartId} nije pronađen.");

            if (part.Quantity < item.Quantity)
                return ServiceResult<Order>.Fail($"Nema na stanju dijela '{part.Name}'. Zatraženo: {item.Quantity}, Dostupno: {part.Quantity}");
        }

        // Calculate total amount based on current part prices (not client-provided)
        decimal totalAmount = insertRequest.OrderItems
            .Sum(x => x.Quantity * parts[x.PartId].Price);

        // Find initial order status
        var pendingStatus = await _context.OrderStatuses
            .FirstOrDefaultAsync(x => x.Name == "Naručeno");

        if (pendingStatus == null)
        {
            pendingStatus = await _context.OrderStatuses
                .OrderBy(x => x.OrderStatusId)
                .FirstOrDefaultAsync();

            if (pendingStatus == null)
                return ServiceResult<Order>.Fail("Nije pronađen nijedan status narudžbe.");
        }

        // Calculate estimated delivery date based on slowest part, to front on Part will be attached estimatedarrivaldays
        int maxEta = insertRequest.OrderItems
            .Max(x => parts[x.PartId].EstimatedArrivalDays);

        var deliveryStatus = await _context.DeliveryStatuses
    .FirstOrDefaultAsync(x => x.Name == "U pripremi");

        if (deliveryStatus == null)
        {
            deliveryStatus = await _context.DeliveryStatuses
                .OrderBy(x => x.DeliveryStatusId)
                .FirstOrDefaultAsync();

            if (deliveryStatus == null)
                return ServiceResult<Order>.Fail("Nije pronađen nijedan status isporuke.");
        }

        var delivery = new Delivery
        {
            DeliveryMethodId = insertRequest.Delivery.DeliveryMethodId,
            DeliveryStatusId = deliveryStatus.DeliveryStatusId,
            DeliveryDate = insertRequest.Delivery.DeliveryDate ?? DateTime.UtcNow.AddDays(maxEta)
        };

        _context.Deliveries.Add(delivery);
        await _context.SaveChangesAsync();

        var order = new Order
        {
            UserId = insertRequest.UserId,
            OrderDate = DateTime.UtcNow,
            PaymentMethodId = insertRequest.PaymentMethodId,
            OrderStatusId = pendingStatus.OrderStatusId,
            TotalAmount = totalAmount,
            DeliveryId = delivery.DeliveryId,
        };

        _context.Orders.Add(order);
        await _context.SaveChangesAsync();

        var orderItems = new List<OrderItem>();

        foreach (var item in insertRequest.OrderItems)
        {
            var part = parts[item.PartId];

            orderItems.Add(new OrderItem
            {
                OrderId = order.OrderId,
                PartId = part.PartId,
                Quantity = item.Quantity,
                UnitPrice = part.Price
            });

            part.Quantity -= item.Quantity;
            part.TotalSold += item.Quantity;
        }

        _context.OrderItems.AddRange(orderItems);
        await _context.SaveChangesAsync();

        order.OrderItems = orderItems;
        order.Delivery = delivery;

        return ServiceResult<Order>.Ok(order);
    }
}