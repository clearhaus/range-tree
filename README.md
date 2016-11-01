# range-tree

[![Build status](https://circleci.com/gh/clearhaus/range-tree.svg?style=shield)](https://circleci.com/gh/clearhaus/range-tree)

This library is an extended version of the well-known data structure [interval
tree](https://en.wikipedia.org/wiki/Interval_tree#Augmented_tree).

In a traditional interval tree built from n intervals, one interval among the n
that has a non-empty intersection with a query interval can be found in time
O(log n). This library supports finding all m intervals with non-empty
intersection in time O(log(n) + m).


## Usage

```ruby
require 'range_tree'

ranges = [1..2, 2..3, 3..4, 4..5]

tree = RangeTree.new(ranges)

tree.search(3..4)
# => [2..3, 3..4, 4..5]
```
