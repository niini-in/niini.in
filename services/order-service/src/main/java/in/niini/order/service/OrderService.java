package in.niini.order.service;

import in.niini.order.dto.OrderRequest;
import in.niini.order.dto.OrderResponse;
import in.niini.order.model.Order;
import in.niini.order.model.OrderItem;
import in.niini.order.model.OrderStatus;
import in.niini.order.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    public List<OrderResponse> getAllOrders() {
        return orderRepository.findAll().stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public OrderResponse getOrderById(Long id) {
        return orderRepository.findById(id)
                .map(this::convertToResponse)
                .orElseThrow(() -> new RuntimeException("Order not found"));
    }

    public List<OrderResponse> getOrdersByUserId(Long userId) {
        return orderRepository.findByUserId(userId).stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    public OrderResponse createOrder(OrderRequest orderRequest) {
        Order order = new Order();
        order.setUserId(orderRequest.getUserId());
        order.setTotalAmount(orderRequest.getTotalAmount());
        order.setStatus(OrderStatus.PENDING);

        List<OrderItem> items = orderRequest.getItems().stream()
                .map(itemRequest -> {
                    OrderItem item = new OrderItem();
                    item.setOrder(order);
                    item.setProductId(itemRequest.getProductId());
                    item.setQuantity(itemRequest.getQuantity());
                    item.setPrice(itemRequest.getPrice());
                    return item;
                })
                .collect(Collectors.toList());

        order.setItems(items);
        Order savedOrder = orderRepository.save(order);
        return convertToResponse(savedOrder);
    }

    public OrderResponse updateOrderStatus(Long id, String status) {
        Order order = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Order not found"));
        order.setStatus(OrderStatus.valueOf(status));
        Order updatedOrder = orderRepository.save(order);
        return convertToResponse(updatedOrder);
    }

    public void deleteOrder(Long id) {
        orderRepository.deleteById(id);
    }

    private OrderResponse convertToResponse(Order order) {
        OrderResponse response = new OrderResponse();
        response.setId(order.getId());
        response.setUserId(order.getUserId());
        response.setTotalAmount(order.getTotalAmount());
        response.setStatus(order.getStatus().name());
        response.setCreatedAt(order.getCreatedAt());
        response.setUpdatedAt(order.getUpdatedAt());

        // Map items if needed
        return response;
    }
}