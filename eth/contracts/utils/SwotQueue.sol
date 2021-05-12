// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SwotQueue
{
    struct Queue {
        bytes32[] data;
        uint cursorPosition;
        mapping(bytes32 => Order) hashToOrder;
    }

    enum OrderType { Bid, Ask }

    struct Order {
      address account;
      uint256 amount;
      OrderType orderType;
    }

    function getOrderId(address account, uint256 amount) internal pure returns (bytes32)
    {
      return keccak256(abi.encode(account, amount));
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
        require(q.data.length + 1 >= q.data.length, 'Array boundaries are exceeded'); // exceeded 2^256 push requests
        q.data.push(requestData);
    }

    function pop(Queue storage q) 
        internal
        returns(bytes32)
    {
        require(q.data.length!=0, 'Cannot pop an empty queue');
        require(q.data.length - 1 >= q.cursorPosition, 'q.data.length - 1 < q.cursorPosition');
        q.cursorPosition += 1;
        return q.data[q.cursorPosition -1];
    }
    function pick(Queue storage q) internal returns (bytes32 r)
    {
        require(q.data.length!=0, 'Cannot pick an empty queue');
        require(q.data.length - 1 >= q.cursorPosition, 'q.data.length - 1 < q.cursorPosition');
        return q.data[q.cursorPosition];
    }
    function pushToQueue(Queue storage q, uint256 amount, address account, OrderType orderType) internal {
        bytes32 orderId = getOrderId(account, amount);
        q.hashToOrder[orderId].amount = amount;
        q.hashToOrder[orderId].account = account;
        q.hashToOrder[orderId].orderType = orderType;
        push(q, orderId);
    }
    function pickFromQueue(Queue storage q) internal returns (Order storage) {
        bytes32 orderId = pick(q);
        return q.hashToOrder[orderId];
    }
    function popFromQueue(Queue storage q) internal returns (Order storage order) {
        bytes32 orderId = pop(q);
        order = q.hashToOrder[orderId];
        q.hashToOrder[orderId] = Order(address(0), 0, OrderType(0));
    }
}

