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

  function testInsertMultiple_1() public {
    uint[10] memory inputs = [uint(10), 11, 2, 4, 5, 1, 8,7, 9, 3];
    // uint[9] memory inputs = [uint(10), 11, 2, 4, 5, 1, 8, 7, 9];

    for (uint i = 0; i < inputs.length; i++) {
      tree.insert(inputs[i]);
      tree.print();
    }


    assertEq(tree.length(), inputs.length, "not all elements inserted");

    uint res = tree.first();
    emit log_named_uint("first", res);
    for (uint i = 0; i < inputs.length - 1; i++) {
      uint tmp = tree.next(res);
      emit log_named_uint("next", tmp);
      assertLt(res, tmp, "next is not greater");
      res = tmp;
    }


    res = tree.last();
    emit log_named_uint("last", res);
    for (uint i = 0; i < inputs.length - 1; i++) {
      uint tmp = tree.previous(res);
      emit log_named_uint("previous", tmp);
      assertGt(res, tmp, "previous is not smaller");
      res = tmp;
    }
  }
}
