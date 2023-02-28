// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

library RedBlackTreeLib {
    struct Node {
        uint256 parent;
        uint256 left;
        uint256 right;
        bool isRed;
    }
    struct Tree {
        mapping(uint256 => Node) nodes;
        uint256 size;
        uint256 root;
    }

    // 0 is also the 'default' value
    uint256 private constant NIL = 0;

    function length(Tree storage self) internal view returns (uint256) {
        return self.size;
    }

    function contains(Tree storage self, uint256 value)
        internal
        view
        returns (bool)
    {
        // either the node exists and has a parent or it is the root node
        return self.nodes[value].parent != NIL || self.root == value;
    }

    function first(Tree storage self) internal view returns (uint256) {
        uint256 value = self.root;
        require(value != NIL, "RBT: Tree is empty");

        // min node from the root
        return min(self, value);
    }

    function min(Tree storage self, uint256 node_)
        private
        view
        returns (uint256)
    {
        uint256 node = node_;
        while (self.nodes[node].left != NIL) {
            node = self.nodes[node].left;
        }

        return node;
    }

    function last(Tree storage self) internal view returns (uint256) {
        uint256 value = self.root;
        require(value != NIL, "RBT: Tree is empty");

        // max node from the root
        return max(self, value);
    }

    function max(Tree storage self, uint256 node_)
        private
        view
        returns (uint256)
    {
        uint256 node = node_;
        while (self.nodes[node].right != NIL) {
            node = self.nodes[node].right;
        }

        return node;
    }

    function next(Tree storage self, uint256 node)
        internal
        view
        returns (uint256)
    {
        require(contains(self, node), "RBT: value unknown");
        return nextUnchecked(self, node);
    }

    function nextUnchecked(Tree storage self, uint256 node)
        internal
        view
        returns (uint256)
    {
        // find next as right branch
        uint256 value = self.nodes[node].right;
        if (value != NIL) {
            return min(self, value);
        }

        // find next as parent
        value = node;
        uint256 parent = self.nodes[node].parent;
        /// TODO NIL -> handle?
        while (value == self.nodes[parent].right && parent != NIL) {
            value = parent;
            parent = self.nodes[parent].parent;
        }

        return parent;
    }

    function previous(Tree storage self, uint256 node)
        internal
        view
        returns (uint256)
    {
        require(contains(self, node), "RBT: value unknown");
        return previousUnchecked(self, node);
    }

    function previousUnchecked(Tree storage self, uint256 node)
        internal
        view
        returns (uint256)
    {
        uint256 value = self.nodes[node].left;
        if (value != NIL) {
            return max(self, value);
        }

        value = node;
        uint256 parent = self.nodes[node].parent;
        /// TODO NIL -> handle?
        while (value == self.nodes[parent].left && parent != NIL) {
            value = parent;
            parent = self.nodes[parent].parent;
        }

        return parent;
    }

    function insert(Tree storage self, uint256 value) internal {
        require(value > 0, "RBT: value must be larger than 0");
        require(!contains(self, value), "RBT: Tree contains value");

        self.size++;
        uint256 cursor = self.root;
        if (cursor == NIL) {
            // the first node
            self.root = value;
            // self.nodes[value] exists implicitly
            return;
        }
        // find position
        uint256 parent;

        while (cursor != NIL) {
            parent = cursor;
            if (value > parent) {
                cursor = self.nodes[parent].right;
            } else {
                cursor = self.nodes[parent].left;
            }
        }
        // insert new RED node at position
        self.nodes[value].parent = parent;
        self.nodes[value].isRed = true;
        if (value > parent) {
            self.nodes[parent].right = value;
        } else {
            self.nodes[parent].left = value;
        }

        /// TODO Loop
        /// TODO use or drop cursor var
        uint256 current = value;

        while (parent != NIL && self.nodes[parent].isRed) {
            // case 1 handled implicitly

            // parent is red, we need to shift
            //////////////////////////////////
            uint256 grandparent = self.nodes[parent].parent;

            if (grandparent == NIL) {
                // case 4
                // there is not grandparent
                // just switch parent to black and thus increase height
                self.nodes[parent].isRed = false;
                return;
            }

            if (parent == self.nodes[grandparent].left) {
                // parent is left child
                uint256 uncle = self.nodes[grandparent].right;

                if (uncle == NIL || !self.nodes[uncle].isRed) {
                    // case 5,6
                    if (current == self.nodes[parent].right) {
                        // case 5, inner child
                        // rotate parent and current
                        self.nodes[grandparent].left = current;
                        self.nodes[current].parent = grandparent;
                        uint256 tmp_ = self.nodes[current].left;
                        self.nodes[current].left = parent;
                        self.nodes[parent].parent = current;
                        self.nodes[parent].right = tmp_;
                        if (tmp_ != NIL) {
                            self.nodes[tmp_].parent = parent;
                        }

                        // switch parent and current
                        tmp_ = current;
                        current = parent;
                        parent = tmp_;
                    }
                    // case 6, outer child
                    if (self.root == grandparent) {
                        self.root = parent;
                    }
                    uint256 grandgrandparent = self.nodes[grandparent].parent;
                    uint256 tmp = self.nodes[parent].right;
                    self.nodes[grandparent].left = tmp;
                    if (tmp != NIL) {
                        self.nodes[tmp].parent = grandparent;
                    }
                    self.nodes[parent].parent = grandgrandparent;
                    if (self.nodes[grandgrandparent].left == grandparent) {
                        self.nodes[grandgrandparent].left = parent;
                    } else {
                        self.nodes[grandgrandparent].right = parent;
                    }
                    self.nodes[parent].right = grandparent;
                    self.nodes[grandparent].parent = parent;

                    self.nodes[parent].isRed = false;
                    self.nodes[grandparent].isRed = true;
                    return;
                }

                // case 2
                // grandparent must be black if parent and uncle are red =>
                // flip parent and uncle to black
                // set grandparent to red
                self.nodes[grandparent].isRed = true;
                self.nodes[parent].isRed = false;
                self.nodes[uncle].isRed = false;

                current = grandparent;
                parent = self.nodes[current].parent;
            } else {
                //parent is right child
                uint256 uncle = self.nodes[grandparent].left;

                if (uncle == NIL || !self.nodes[uncle].isRed) {
                    // case 5,6
                    if (current == self.nodes[parent].left) {
                        // case 5, inner child
                        // rotate parent and current
                        self.nodes[grandparent].right = current;
                        self.nodes[current].parent = grandparent;
                        uint256 tmp_ = self.nodes[current].right;
                        self.nodes[current].right = parent;
                        self.nodes[parent].parent = current;
                        self.nodes[parent].left = tmp_;
                        if (tmp_ != NIL) {
                            self.nodes[tmp_].parent = parent;
                        }

                        // switch parent and current
                        tmp_ = current;
                        current = parent;
                        parent = tmp_;
                    }
                    // case 6, outer child
                    if (self.root == grandparent) {
                        self.root = parent;
                    }
                    uint256 grandgrandparent = self.nodes[grandparent].parent;
                    uint256 tmp = self.nodes[parent].left;
                    self.nodes[grandparent].right = tmp;
                    if (tmp != NIL) {
                        self.nodes[tmp].parent = grandparent;
                    }
                    self.nodes[parent].parent = grandgrandparent;
                    if (self.nodes[grandgrandparent].left == grandparent) {
                        self.nodes[grandgrandparent].left = parent;
                    } else {
                        self.nodes[grandgrandparent].right = parent;
                    }
                    self.nodes[parent].left = grandparent;
                    self.nodes[grandparent].parent = parent;

                    self.nodes[parent].isRed = false;
                    self.nodes[grandparent].isRed = true;
                    return;
                }

                // case 2
                // grandparent must be black if parent and uncle are red =>
                // flip parent and uncle to black
                // set grandparent to red
                self.nodes[grandparent].isRed = true;
                self.nodes[parent].isRed = false;
                self.nodes[uncle].isRed = false;

                current = grandparent;
                parent = self.nodes[current].parent;
            }
        }
    }

    function remove(Tree storage self, uint256 node_) internal {
        require(contains(self, node_), "RBT: Tree does not contain node_");
        self.size--;

        _remove(self, node_);
    }

    function _remove(Tree storage self, uint256 node_) private {
        // TODO node_ is root

        if (self.nodes[node_].left == NIL) {
            // move right branch in its place
            if (self.nodes[node_].isRed) {
                // a red node cannot have just one child, thus it has no children
                removeRedSingle(self, node_);
                return;
            }
            // node_ has max one child, thus node_ is black and the child is red
            uint256 child = self.nodes[node_].right;
            if (child != NIL) {
                removeSingleParent(self, node_, child);
            }

            // TODO no children
        } else if (self.nodes[node_].right == NIL) {
            // move left branch in its place
            if (self.nodes[node_].isRed) {
                // a red node cannot have just one child, thus it has no children
                removeRedSingle(self, node_);
                return;
            }
            // node_ has max one child, thus node_ is black and the child is red
            uint256 child = self.nodes[node_].left;
            if (child != NIL) {
                removeSingleParent(self, node_, child);
            }

            // TODO no children
        } else {
            // node has two children
            // find the successor, replace it, and do repainting
            uint256 successor = min(self, self.nodes[node_].right);
            _remove(self, successor); // TODO entry is removed and then re-added

            // TODO extract replace?
            // successor replaces node_
            if (self.root == node_) {
                self.root = successor;
                self.nodes[successor].parent = NIL;
            } else {
                self.nodes[successor].parent = self.nodes[node_].parent;
                if (self.nodes[self.nodes[node_].parent].left == node_) {
                    self.nodes[self.nodes[node_].parent].left = successor;
                } else {
                    self.nodes[self.nodes[node_].parent].right = successor;
                }
            }
            self.nodes[successor].left = self.nodes[node_].left;
            self.nodes[self.nodes[node_].left].parent = successor;
            self.nodes[successor].right = self.nodes[node_].right;
            self.nodes[self.nodes[node_].right].parent = successor;

            self.nodes[successor].isRed = self.nodes[node_].isRed;

            delete self.nodes[node_];
        }
    }

    function removeRedSingle(Tree storage self, uint256 node_) private {
        if (self.root == node_) {
            // a single red node is the root (can only occur through rotations)
            self.root = NIL;
        } else {
            // TODO similar drop from parent
            uint256 parent = self.nodes[node_].parent;
            if (self.nodes[parent].left == node_) {
                self.nodes[parent].left = NIL;
            } else {
                self.nodes[parent].right = NIL;
            }
        }
        delete self.nodes[node_];
    }

    function removeSingleParent(
        Tree storage self,
        uint256 node_,
        uint256 child
    ) private {
        if (self.root == node_) {
            self.root = child;
            self.nodes[child].parent = NIL;
        } else {
            // TODO similar drop from parent
            uint256 parent = self.nodes[node_].parent;
            if (self.nodes[parent].left == node_) {
                self.nodes[parent].left = child;
            } else {
                self.nodes[parent].right = child;
            }
            self.nodes[child].parent = parent;
        }
        // the red child must be painted black
        self.nodes[child].isRed = false;
        // drop the node struct
        delete self.nodes[node_];
    }
}
