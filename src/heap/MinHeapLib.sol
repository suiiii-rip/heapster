// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

library MinHeapLib {
    struct Heap {
        uint256[] arr;
    }

    function push(Heap storage self, uint256 value) internal {
        self.arr.push(value);

        /////////////////
        // fix heap state
        /////////////////
        uint256 child = self.arr.length - 1;
        if (child == 0) {
            return;
        }

        uint256 parent = (child - 1) / 2;

        while (self.arr[parent] > self.arr[child]) {
            //swap
            uint256 tmp = self.arr[parent];
            self.arr[parent] = self.arr[child];
            self.arr[child] = tmp;

            // reset
            if (parent == 0) {
                return;
            }
            child = parent;
            parent = (child - 1) / 2;
        }
    }

    function pop(Heap storage self) internal returns (uint256) {
        require(self.arr.length > 0, "MinHeap: is empty");

        // return head
        uint256 res = self.arr[0];
        // copy last element to new head
        self.arr[0] = self.arr[self.arr.length - 1];
        // remove last
        self.arr.pop();

        /////////////////
        // fix heap state
        /////////////////
        uint256 len = self.arr.length;
        uint256 parent = 0;
        uint256 minChild;
        {
            uint256 left = 2 * parent + 1;
            uint256 right = 2 * parent + 2;

            if (right < len) {
                // has left and right child
                if (self.arr[left] < self.arr[right]) {
                    minChild = left;
                } else {
                    minChild = right;
                }
            } else if (left < len) {
                // has only left child
                minChild = left;
            } else {
                // no children
                minChild = parent;
            }
        }

        while (minChild != parent && self.arr[parent] > self.arr[minChild]) {
            //swap
            uint256 tmp = self.arr[parent];
            self.arr[parent] = self.arr[minChild];
            self.arr[minChild] = tmp;

            // reset
            parent = minChild;
            {
                uint256 left = 2 * parent + 1;
                uint256 right = 2 * parent + 2;

                if (right < len) {
                    // has left and right child
                    if (self.arr[left] < self.arr[right]) {
                        minChild = left;
                    } else {
                        minChild = right;
                    }
                } else if (left < len) {
                    // has only left child
                    minChild = left;
                } else {
                    // no children
                    minChild = parent;
                }
            }
        }

        return res;
    }

    function peek(Heap storage self) internal view returns (uint256) {
        require(self.arr.length > 0, "MinHeap: is empty");

        return self.arr[0];
    }

    function length(Heap storage self) internal view returns (uint256) {
        return self.arr.length;
    }
}
