// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "forge-std/Test.sol";
import "../../src/redblacktree/RedBlackTree.sol";

contract RedBlackTreeTest is Test {

  RedBlackTree tree;

  function setUp() public {
    tree = new RedBlackTree();
  }

  function testEmptySize() public {
    assertEq(tree.length(), 0, "tree empty");
  }

  function testInsertOne() public {
    uint val = 1;
    tree.insert(val);
    assertEq(tree.first(), val);
    assertEq(tree.last(), val);
    assertEq(tree.length(), 1);
  }

  function testInsertTwo() public {
    tree.insert(2);
    tree.insert(1);
    assertEq(tree.first(), 1);
    assertEq(tree.last(), 2);
    assertEq(tree.length(), 2);
  }

  function checkOrdering(uint count) private {
    assertEq(tree.length(), count, "not all elements inserted");

    if (count == 0) {
      return;
    }

    uint res = tree.first();
    for (uint i = 0; i < count - 1; i++) {
      uint tmp = tree.next(res);
      assertLt(res, tmp, "next is not greater");
      res = tmp;
    }


    res = tree.last();
    for (uint i = 0; i < count - 1; i++) {
      uint tmp = tree.previous(res);
      assertGt(res, tmp, "previous is not smaller");
      res = tmp;
    }
  }

  function testInsertMultiple_1() public {
    uint[10] memory inputs = [uint(10), 11, 2, 4, 5, 1, 8,7, 9, 3];
    // uint[29] memory inputs = [uint(1000), 10000, 99, 98, 97, 91, 11, 2, 4, 5, 1, 8, 7, 9, 12, 13, 14, 22, 18, 3, 200, 300, 100, 70, 60, 50, 30, 15, 111];

    for (uint i = 0; i < inputs.length; i++) {
      tree.insert(inputs[i]);
      // tree.print();
    }

    checkOrdering(inputs.length);
  }

  function testInsertMultiple_seq() public {

    uint count = 10000;
    for (uint i = 1; i <= count; i++) {
      tree.insert(i);
    }

    checkOrdering(count);
  }

  function testInsertMultiple_invseq() public {

    uint count = 10000;
    for (uint i = count; i > 0; i--) {
      tree.insert(i);
    }

    checkOrdering(count);
  }

  function testInsertMultiple_fuzz(uint[] memory inputs) public {

    uint count = 0;
    for (uint i = 0; i < inputs.length; i++) {
      if (inputs[i] > 0 && !tree.contains(inputs[i])) {
        tree.insert(inputs[i]);
        count++;
      }
    }

    checkOrdering(count);
  }
}
