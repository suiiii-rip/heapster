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

    function rotateLeft(Tree storage self, uint256 node) private {
        uint256 child = self.nodes[node].right;
        uint256 parent = self.nodes[node].parent;
        uint256 grandchild = self.nodes[child].left;
        self.nodes[node].right = grandchild;
        if (grandchild != NIL) {
            self.nodes[grandchild].parent = node;
        }
        self.nodes[child].parent = parent;
        if (parent == NIL) {
            self.root = child;
        } else if (node == self.nodes[parent].left) {
            self.nodes[parent].left = child;
        } else {
            self.nodes[parent].right = child;
        }
        self.nodes[child].left = node;
        self.nodes[node].parent = child;
    }

    function rotateRight(Tree storage self, uint256 node) private {
        uint256 child = self.nodes[node].left;
        uint256 parent = self.nodes[node].parent;
        uint256 grandchild = self.nodes[child].right;
        self.nodes[node].left = grandchild;
        if (grandchild != NIL) {
            self.nodes[grandchild].parent = node;
        }
        self.nodes[child].parent = parent;
        if (parent == NIL) {
            self.root = child;
        } else if (node == self.nodes[parent].left) {
            self.nodes[parent].left = child;
        } else {
            self.nodes[parent].right = child;
        }
        self.nodes[child].right = node;
        self.nodes[node].parent = child;
    }

    function replace(
        Tree storage self,
        uint256 _old,
        uint256 _new
    ) private {
        if (self.root == _old) {
            self.root = _new;
            self.nodes[_new].parent = NIL;
        } else {
            uint256 parent = self.nodes[_old].parent;
            self.nodes[_new].parent = parent;
            if (self.nodes[parent].left == _old) {
                self.nodes[parent].left = _new;
            } else {
                self.nodes[parent].right = _new;
            }
        }

        uint256 left = self.nodes[_old].left;
        uint256 right = self.nodes[_old].right;
        self.nodes[_new].left = left;
        self.nodes[left].parent = _new;
        self.nodes[_new].right = right;
        self.nodes[right].parent = _new;

        self.nodes[_new].isRed = self.nodes[_old].isRed;
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
                        rotateLeft(self, parent);

                        // switch parent and current
                        // tmp_ = current;
                        uint256 tmp_ = current;
                        current = parent;
                        parent = tmp_;
                    }
                    // case 6, outer child
                    rotateRight(self, grandparent);

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
                        rotateRight(self, parent);

                        // switch parent and current
                        uint256 tmp_ = current;
                        current = parent;
                        parent = tmp_;
                    }
                    // case 6, outer child
                    rotateLeft(self, grandparent);

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
                return;
            }

            if (self.root == node_) {
                delete self.nodes[node_];
                self.root = NIL;
                return;
            }

            handleRemoveFix(self, node_);

            uint256 parent = self.nodes[node_].parent;
            if (self.nodes[parent].left == node_) {
                self.nodes[parent].left = NIL;
            } else {
                self.nodes[parent].right = NIL;
            }

            delete self.nodes[node_];
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
                return;
            }

            if (self.root == node_) {
                delete self.nodes[node_];
                self.root = NIL;
                return;
            }

            handleRemoveFix(self, node_);

            uint256 parent = self.nodes[node_].parent;
            if (self.nodes[parent].left == node_) {
                self.nodes[parent].left = NIL;
            } else {
                self.nodes[parent].right = NIL;
            }

            delete self.nodes[node_];
        } else {
            // node has two children
            // find the successor, replace it, and do repainting
            uint256 successor = min(self, self.nodes[node_].right);
            _remove(self, successor); // TODO entry is removed and then re-added

            // successor replaces node_
            replace(self, node_, successor);

            delete self.nodes[node_];
        }
    }

    function handleRedDistantNephew(
        Tree storage self,
        uint parent,
        uint sibling,
        uint distantNephew,
        bool isLeft
    ) private {
        if (isLeft) {
            rotateLeft(self, parent);
        } else {
            rotateRight(self, parent);
        }
        self.nodes[sibling].isRed = self.nodes[parent].isRed;
        self.nodes[parent].isRed = false;
        self.nodes[distantNephew].isRed = false;
    }

    function handleRemoveFix(Tree storage self, uint256 current) private {
        uint256 parent = self.nodes[current].parent;

        while (parent != NIL && !self.nodes[current].isRed) {
            if (self.nodes[parent].left == current) {
                uint256 sibling = self.nodes[parent].right;
                uint256 closeNephew = self.nodes[sibling].left;
                uint256 distantNephew = self.nodes[sibling].right;

                if (self.nodes[sibling].isRed) {
                    // case 3: sibling red, parent and nephews are black
                    rotateLeft(self, parent);
                    self.nodes[parent].isRed = true;
                    self.nodes[sibling].isRed = false;
                    sibling = closeNephew;
                    distantNephew = self.nodes[sibling].right;
                    closeNephew = self.nodes[sibling].left;
                }

                if (distantNephew != NIL && self.nodes[distantNephew].isRed) {
                    // case 6: distant nephew is red, sibling is black
                    handleRedDistantNephew(self, parent, sibling, distantNephew, true);
                    return;
                }
                if (closeNephew != NIL && self.nodes[closeNephew].isRed) {
                    // case 5 closeNephew is red, sibling and distantNephew black
                    rotateRight(self, sibling);
                    self.nodes[sibling].isRed = true;
                    self.nodes[closeNephew].isRed = false;

                    distantNephew = sibling;
                    sibling = closeNephew;
                    // go case 6
                    handleRedDistantNephew(self, parent, sibling, distantNephew, true);
                    return;
                }
                if (self.nodes[parent].isRed) {
                    // case 4: parent is red, sibling and nephew are black
                    self.nodes[sibling].isRed = true;
                    self.nodes[parent].isRed = false;
                    return;
                }
                // case 2
                // parent, sibling, and nephews are black
                self.nodes[sibling].isRed = true;
                current = parent;
            } else {
                uint256 sibling = self.nodes[parent].left;
                uint256 closeNephew = self.nodes[sibling].right;
                uint256 distantNephew = self.nodes[sibling].left;

                if (self.nodes[sibling].isRed) {
                    // case 3: sibling red, parent and nephews are black
                    rotateRight(self, parent);
                    self.nodes[parent].isRed = true;
                    self.nodes[sibling].isRed = false;
                    sibling = closeNephew;
                    distantNephew = self.nodes[sibling].left;
                    closeNephew = self.nodes[sibling].right;
                }

                if (distantNephew != NIL && self.nodes[distantNephew].isRed) {
                    // case 6: distant nephew is red, sibling is black
                    handleRedDistantNephew(self, parent, sibling, distantNephew, false);
                    return;
                }
                if (closeNephew != NIL && self.nodes[closeNephew].isRed) {
                    // case 5 closeNephew is red, sibling and distantNephew black
                    rotateLeft(self, sibling);
                    self.nodes[sibling].isRed = true;
                    self.nodes[closeNephew].isRed = false;

                    distantNephew = sibling;
                    sibling = closeNephew;
                    // go case 6
                    handleRedDistantNephew(self, parent, sibling, distantNephew, false);
                    return;
                }
                if (self.nodes[parent].isRed) {
                    // case 4: parent is red, sibling and nephew are black
                    self.nodes[sibling].isRed = true;
                    self.nodes[parent].isRed = false;
                    return;
                }
                // case 2
                // parent, sibling, and nephews are black
                self.nodes[sibling].isRed = true;
                current = parent;
            }
            parent = self.nodes[current].parent;
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
