require 'bundler/setup'

ROOT = File.expand_path('../..', __FILE__).freeze

module ExamplesHelper
  def read_example(name)
    File.read(File.join(ROOT, name))
  end
end

RSpec.configure do |config|
  config.include ExamplesHelper
end
