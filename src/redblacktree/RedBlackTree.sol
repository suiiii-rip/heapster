// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {RedBlackTreeLib} from "./RedBlackTreeLib.sol";

import "forge-std/console.sol";

contract RedBlackTree {
    using RedBlackTreeLib for RedBlackTreeLib.Tree;

    RedBlackTreeLib.Tree tree;

    function print() external view {
      console.log("#########################################################");
      console.log("TREE");
      console.log("length: %s", tree.size);
      _printNode(tree.root);
    }

    function _printNode(uint node) private view {
      if (node == 0) {
        return;
      }
      console.log("---------------------------------------------------------");
      console.log("     parent: %s", tree.nodes[node].parent);
      console.log("      value: %s    red: %s", node, tree.nodes[node].isRed);
      console.log("left: %s              right: %s", tree.nodes[node].left, tree.nodes[node].right);

      _printNode(tree.nodes[node].left);
      _printNode(tree.nodes[node].right);
    }

    function length() external view returns (uint256) {
        return tree.length();
    }

    function contains(uint256 value) external view returns (bool) {
        return tree.contains(value);
    }

    function first() external view returns (uint256) {
        return tree.first();
    }

    function last() external view returns (uint256) {
        return tree.last();
    }

    function next(uint256 node) external view returns (uint256) {
        return tree.next(node);
    }

    function nextUnchecked(uint256 node) external view returns (uint256) {
        return tree.nextUnchecked(node);
    }

    function previous(uint256 node) external view returns (uint256) {
        return tree.previous(node);
    }

    function previousUnchecked(uint256 node) external view returns (uint256) {
        return tree.previousUnchecked(node);
    }

    function insert(uint256 value) external {
        tree.insert(value);
    }

    function remove(uint256 value) external {
        tree.remove(value);
    }
}
