// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Test.sol";
import "../../src/heap/MinHeap.sol";

contract MinHeapTest is Test {
    MinHeap heap;

    function setUp() public {
        heap = new MinHeap();
    }

    function testLength() public {
        uint256 len = heap.length();

        assertEq(len, 0);
    }

    function testInsertOne() public {
        uint256 val = 1;
        heap.push(val);

        uint256 res = heap.peek();

        assertEq(res, val);
    }

    function testInsertTwo() public {
        heap.push(2);
        heap.push(1);

        uint256 res = heap.peek();

        assertEq(res, 1);
    }

    function testInsertAndPop() public {
        uint256 val = 1;
        heap.push(val);

        uint256 res = heap.pop();

        assertEq(res, val);
        assertEq(heap.length(), 0);
    }

    function testInsertAndPopSome() public {
        heap.push(2);
        heap.push(4);
        heap.push(1);
        heap.push(3);

        uint256 res = heap.pop();

        assertEq(res, 1, "head was 1");
        assertEq(heap.length(), 3, "three entries left in heap");

        res = heap.pop();

        assertEq(res, 2, "head was 2");
        assertEq(heap.length(), 2, "two entries left in heap");

        res = heap.pop();

        assertEq(res, 3, "head was 3");
        assertEq(heap.length(), 1, "one entry left in heap");

        res = heap.pop();

        assertEq(res, 4, "head was 4");
        assertEq(heap.length(), 0, "heap empty");
    }

    function testInsertAndPopArray() public {
        uint256[10] memory input = [uint256(10), 4, 7, 9, 9, 3, 1, 2, 8, 4];

        for (uint256 i = 0; i < input.length; i++) {
            heap.push(input[i]);
        }

        uint256 prev = 0;
        for (uint256 i = 0; i < input.length; i++) {
            uint256 res = heap.pop();
            assertGe(res, prev);
            prev = res;
        }
        assertEq(heap.length(), 0, "heap empty");
    }

    function testPushPop(uint256[] calldata input) public {
        for (uint256 i = 0; i < input.length; i++) {
            heap.push(input[i]);
        }

        uint256 prev = 0;
        for (uint256 i = 0; i < input.length; i++) {
            uint256 res = heap.pop();
            emit log_named_uint("popped ", res);
            assertGe(res, prev);
            prev = res;
        }
        assertEq(heap.length(), 0, "heap empty");
    }
}
