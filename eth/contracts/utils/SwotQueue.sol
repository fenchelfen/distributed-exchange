// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SwotQueue
{
    struct Queue {
        bytes32[] data;
        uint front;
        uint back;
        mapping(bytes32 => Order) hashToOrder;
    }

    struct Order {
      address account;
      uint256 amount;
    }

    function getOrderId(Order memory order) internal pure returns (bytes32)
    {
      return keccak256(abi.encode(order.account, order.amount));
    }
    /// @dev the number of elements stored in the queue.
    function length(Queue storage q) internal returns (uint) {
        return q.back - q.front;
    }
    /// @dev the number of elements this queue can hold
    function capacity(Queue storage q) internal returns (uint) {
        return q.data.length - 1;
    }
    /// @dev push a new element to the back of the queue
    function push(Queue storage q, bytes32 data) internal
    {
        if ((q.back + 1) % q.data.length == q.front)
            return; // throw;
        q.data[q.back] = data;
        q.back = (q.back + 1) % q.data.length;
    }
    /// @dev remove and return the element at the front of the queue
    function pop(Queue storage q) internal returns (bytes32 r)
    {
        if (q.back == q.front)
            revert(); // throw;
        r = q.data[q.front];
        delete q.data[q.front];
        q.front = (q.front + 1) % q.data.length;
    }
    /// @dev pick a value at the front of the queue 
    function pick(Queue storage q) internal returns (bytes32 r)
    {
        if (q.back == q.front)
            revert(); // throw;
        return q.data[q.front];
    }
    function pushToQueue(Queue storage q, Order memory order) internal {
        bytes32 orderId = getOrderId(order);
        q.hashToOrder[orderId] = order;
        push(q, orderId);
    }
    function pickFromQueue(Queue storage q) internal returns (Order memory) {
        bytes32 orderId = pick(q);
        return q.hashToOrder[orderId];
    }
    function popFromQueue(Queue storage q) internal returns (Order memory order) {
        bytes32 orderId = pop(q);
        order = q.hashToOrder[orderId];
        q.hashToOrder[orderId] = Order(address(0), 0);
    }
}

