// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {MinHeapLib} from "./MinHeapLib.sol";

contract MinHeap {
    using MinHeapLib for MinHeapLib.Heap;

    MinHeapLib.Heap heap;

    function push(uint256 value) external {
        heap.push(value);
    }

    function pop() external returns (uint256) {
        return heap.pop();
    }

    function peek() external view returns (uint256) {
        return heap.peek();
    }

    function length() external view returns (uint256) {
        return heap.length();
    }
}
