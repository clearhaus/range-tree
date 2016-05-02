require 'range_tree'

describe 'RangeTree' do
  describe '.new' do
    it 'handles []' do
      t = RangeTree.new([])
      expect(t.root).to eq(nil)
    end

    it 'handles [1..5]' do
      t = RangeTree.new([1..5])

      expect(t.root.range).to eq(1..5)
      expect(t.root.left).to eq(nil)
      expect(t.root.right).to eq(nil)

      expect(t.root.min).to eq(1)
      expect(t.root.max).to eq(5)
    end

    it 'handles [1...5]' do
      t = RangeTree.new([1...5])

      expect(t.root.range).to eq(1...5)
      expect(t.root.left).to eq(nil)
      expect(t.root.right).to eq(nil)

      expect(t.root.min).to eq(1)
      expect(t.root.max).to eq(4)
    end

    it 'handles [1..2, 3..4, 2..8, 5..6]' do
      t = RangeTree.new([1..2, 3..4, 2..8, 5..6])

      # [1..2, 2..8, 3..4, 5..6]
      #              middle

      expect(t.root.range).to eq(3..4)
      expect(t.root.left.range).to eq(2..8)
      expect(t.root.left.left.range).to eq(1..2)
      expect(t.root.left.left.left).to eq(nil)
      expect(t.root.left.left.right).to eq(nil)
      expect(t.root.left.right).to eq(nil)
      expect(t.root.right.range).to eq(5..6)
      expect(t.root.right.left).to eq(nil)
      expect(t.root.right.right).to eq(nil)

      expect(t.root.max).to eq(8)
      expect(t.root.left.max).to eq(8)
      expect(t.root.left.left.max).to eq(2)
      expect(t.root.right.max).to eq(6)
    end

    it 'handles [1...2, 3...4, 2...8, 5...6]' do
      t = RangeTree.new([1...2, 3...4, 2...8, 5...6])

      # [1...2, 2...8, 3...4, 5...6]
      #                middle

      expect(t.root.range).to eq(3...4)
      expect(t.root.left.range).to eq(2...8)
      expect(t.root.left.left.range).to eq(1...2)
      expect(t.root.left.left.left).to eq(nil)
      expect(t.root.left.left.right).to eq(nil)
      expect(t.root.left.right).to eq(nil)
      expect(t.root.right.range).to eq(5...6)
      expect(t.root.right.left).to eq(nil)
      expect(t.root.right.right).to eq(nil)

      expect(t.root.max).to eq(7)
      expect(t.root.left.max).to eq(7)
      expect(t.root.left.left.max).to eq(1)
      expect(t.root.right.max).to eq(5)
    end
  end


  describe '#search' do
    context 'in []' do
      let (:ranges) { [] }
      let (:t) { RangeTree.new(ranges) }
      it 'for any input' do
        expect(t.search(0)).to eq([])
        expect(t.search(nil)).to eq([])
        expect(t.search(0..0)).to eq([])
        expect(t.search(1..3)).to eq([])
        expect(t.search(1..1, limit: 3)).to eq([])
      end
    end

    context 'in [2..3, 3..5, 4..10, 5..7, 6..10, 7..9, 9..11]' do
      let (:ranges) { [2..3, 3..5, 4..10, 5..7, 6..10, 7..9, 9..11] }
      let (:t) { RangeTree.new(ranges, sorted: true) }
      it 'for 4..8' do
        expect(t.search(4..8)).to eq([3..5, 4..10, 5..7, 6..10, 7..9])
      end

      context 'to the left' do
        it 'for 1..2' do
          expect(t.search(1..2)).to eq([2..3])
        end

        it 'for 0...2' do
          expect(t.search(0...2)).to eq([])
        end
      end

      context 'to the right' do
        it 'for 11..12' do
          expect(t.search(11..12)).to eq([9..11])
        end

        it 'for 12..13' do
          expect(t.search(12..13)).to eq([])
        end
      end
    end

    context 'in [2..3, 3..5, 4..10, 5..7, 6..10, 7..9, 9..11].shuffle' do
      5.times do
        let (:ranges) { [2..3, 3..5, 4..10, 5..7, 6..10, 7..9, 9..11].shuffle }
        let (:t) { RangeTree.new(ranges) }
        it 'for 4..8' do
          expect(t.search(4..8)).to eq([3..5, 4..10, 5..7, 6..10, 7..9])
        end

        it 'for 4...8' do
          expect(t.search(4..8)).to eq([3..5, 4..10, 5..7, 6..10, 7..9])
        end
      end
    end

    context 'in [2...3, 3...5, 4...10, 5...7, 6...10, 7...9, 9...11]' do
      let (:ranges) { [2...3, 3...5, 4...10, 5...7, 6...10, 7...9, 9...11] }
      let (:t) { RangeTree.new(ranges, sorted: true) }
      it 'for 4...8' do
        expect(t.search(4...8)).to eq([3...5, 4...10, 5...7, 6...10, 7...9])
      end

      it 'for 4..8' do
        expect(t.search(4..8)).to eq([3...5, 4...10, 5...7, 6...10, 7...9])
      end

      context 'to the left' do
        it 'for 0..1' do
          expect(t.search(0..1)).to eq([])
        end

        it 'for 1..2' do
          expect(t.search(1..2)).to eq([2...3])
        end
      end

      it 'for 4...4 (empty range)' do
        expect(t.search(4...4)).to eq([])
      end

      it 'for 10..1 (empty range)' do
        expect(t.search(10..1)).to eq([])
      end
    end

    context 'in [2..3, 3..5, 4..10, 5..7, 6..10, 7..9, 9..11]' do
      let (:ranges) { [2..3, 3..5, 4..10, 5..7, 6..10, 7..9, 9..11] }
      let (:t) { RangeTree.new(ranges, sorted: true) }

      it 'for 4..8 with limit: -3' do
        expect(t.search(4..8, limit: -3)).to eq([])
      end

      it 'for 4..8 with limit: 0' do
        expect(t.search(4..8, limit: 0)).to eq([])
      end

      it 'for 4..8 with limit: 2' do
        expect(t.search(4..8, limit: 2)).to eq([3..5, 4..10])
      end

      it 'for 4..8 with limit: 100' do
        expect(t.search(4..8, limit: 100)).to eq([3..5, 4..10, 5..7, 6..10, 7..9])
      end
    end

    describe 'query range completely overlapping all ranges' do
      let (:ranges) { [2..3, 3..5, 4..10, 5..7, 6..10, 7..9, 9..11] }
      let (:t) { RangeTree.new(ranges, sorted: true) }

      it 'returns the entire input' do
        expect(t.search(0..20)).to eq([2..3, 3..5, 4..10, 5..7, 6..10, 7..9, 9..11])
      end
    end

    describe 'query range completely included in exactly one ranges' do
      let (:ranges) { [2..3, 3..5, 4..8, 5..7, 6..9, 7..9, 9..11] }
      let (:t) { RangeTree.new(ranges, sorted: true) }

      it 'returns that one range' do
        expect(t.search(10..11)).to eq([9..11])
      end
    end
  end
end
