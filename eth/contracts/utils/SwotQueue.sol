// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SwotQueue
{
    struct Queue {
        bytes32[] data;
        uint cursorPosition;
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
    function queueDepth(Queue storage q) 
        internal
        returns(uint)
    {
        return q.data.length - q.cursorPosition;
    }

    function push(Queue storage q, bytes32 requestData) 
        internal
    {
        if(q.data.length + 1 < q.data.length) revert(); // exceeded 2^256 push requests
        q.data.push(requestData);
    }

    function pop(Queue storage q) 
        internal
        returns(bytes32)
    {
        if(q.data.length==0) revert();
        if(q.data.length - 1 < q.cursorPosition) revert();
        q.cursorPosition += 1;
        return q.data[q.cursorPosition -1];
    }
    function pick(Queue storage q) internal returns (bytes32 r)
    {
        if(q.data.length==0) revert();
        if(q.data.length - 1 < q.cursorPosition) revert();
        return q.data[q.cursorPosition];
    }
    function pushToQueue(Queue storage q, Order memory order) internal {
        bytes32 orderId = getOrderId(order);
        q.hashToOrder[orderId].amount = order.amount;
        q.hashToOrder[orderId].account = order.account;
        push(q, orderId);
    }
    function pickFromQueue(Queue storage q) internal returns (Order storage) {
        bytes32 orderId = pick(q);
        return q.hashToOrder[orderId];
    }
    function popFromQueue(Queue storage q) internal returns (Order storage order) {
        bytes32 orderId = pop(q);
        order = q.hashToOrder[orderId];
        q.hashToOrder[orderId] = Order(address(0), 0);
    }
}

