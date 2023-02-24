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

        while (self.nodes[value].left != NIL) {
            value = self.nodes[value].left;
        }

        return value;
    }

    function last(Tree storage self) internal view returns (uint256) {
        uint256 value = self.root;
        require(value != NIL, "RBT: Tree is empty");

        while (self.nodes[value].right != NIL) {
            value = self.nodes[value].right;
        }

        return value;
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
            uint256 next_ = self.nodes[value].left;
            while (next_ != NIL) {
                value = next_;
                next_ = self.nodes[value].left;
            }
            return value;
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
            uint256 next_ = self.nodes[value].right;
            while (next_ != NIL) {
                value = next_;
                next_ = self.nodes[value].right;
            }
            return value;
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

    function remove(Tree storage self, uint256 value) internal {
        require(contains(self, value), "RBT: Tree does not contain value");
        self.size--;
    }
}
