Gem::Specification.new do |gem|
  gem.authors       = ['Casper Thomsen', 'Martin Toft']
  gem.email         = []
  gem.license       = 'MIT'
  gem.description   = 'Ruby implementation of "doubly-augmented" interval trees'
  gem.summary       = <<-EOS
    In an "interval tree" built from n intervals, one interval among the n that
    has a non-empty intersection with a query interval can be found in time
    O(log n).
    This library supports finding all m intervals with non-empty intersection in
    time O(log(n) + m).
  EOS
  gem.homepage      = 'https://github.com/clearhaus/range-tree'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = []
  gem.test_files    = gem.files.grep(/^spec/)
  gem.name          = 'range-tree'
  gem.require_paths = ['lib']
  gem.version       = '1.0.0'

  gem.add_development_dependency 'rspec'
end
