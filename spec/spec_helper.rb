require 'bundler/setup'

ROOT = File.expand_path('../..', __FILE__).freeze

$: << File.join(ROOT, 'lib')
require 'typed_ruby'

module ExamplesHelper
  def read_example(name)
    File.read(File.join(ROOT, 'examples', name))
  end
end

RSpec.configure do |config|
  config.include ExamplesHelper
end
