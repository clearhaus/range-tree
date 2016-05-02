class RangeTree
  class Node
    def initialize(left, range, right, min, max)
      @left  = left
      @range = range
      @right = right
      @min   = min || range.min
      @max   = max || range.max
    end
    attr_reader :left, :range, :right, :min, :max
  end

  def initialize(ranges, sorted: false)
    ranges.sort_by!{|r| [r.min, r.max]} unless sorted
    # It's only required to be sorted by `r.min`, but if many ranges has the
    # same left endpoint, then it's more efficient if also secondarily sorted by
    # the right endpoint (or equivalently by the length).

    @root = RangeTree.split(ranges)
  end
  attr_reader :root

  def self.split(ranges)
    return nil if ranges.empty?

    middle = ranges.length/2

    left  = split(ranges.slice(0, middle)) # Handle middle == 0 correctly.
    range = ranges[middle] # Current range.
    right = split(ranges[(middle+1)..-1]) # Handle middle == ranges.length correctly.

    ary = [left, range, right].compact

    Node.new(left, range, right,
             ary.map(&:min).min, # Subtree's min.
             ary.map(&:max).max) # Subtree's max.
  end

  def search(range, limit: Float::INFINITY)
    range = range.is_a?(Range) ? range : (range..range)

    result = []
    RangeTree.search_helper(range, @root, result, limit)

    result
  end

  def self.search_helper(q, root, result, limit)
    return if root.nil?

    # Visit left child?
    if (l = root.left) and l.max and q.min and \
        not l.max < q.min # The interesting part.
      search_helper(q, root.left, result, limit)
    end

    return if result.length >= limit
    # Yes, it needs to be checked here rather than in the top. Otherwise, at the
    # point of checking, there wasn't added too many, but after left child has
    # been checked, we might hit the limit and then, "this" will add one as
    # well.

    # Add root?
    result << root.range if RangeTree.ranges_intersect?(q, root.range)

    # Visit right child?
    if (r = root.right) and q.max and r.min and \
        not q.max < r.min # The interesting part.
      search_helper(q, root.right, result, limit)
    end
  end

  def self.ranges_intersect?(a, b)
    return false unless a.min && a.max && b.min && b.max

    a.min <= b.max && a.max >= b.min
  end
end
