require 'simplecov'

SimpleCov.start do
  add_filter                "vendor"
  add_filter                "spec"
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

require File.expand_path("../../lib/whedon", __FILE__)

class Ex < Whedon::Schedule
  def initialize(line)
    self.raise_error_on_duplicate = true
    super(line)
  end
end

def local(*args)
  Time.local(*args)
end
alias lo local

def utc(*args)
  Time.utc(*args)
end

def cl(line)
  Whedon::Schedule.new(line)
end

def compare(line, array)
  expect(cl(line).to_array).to eq(array)
end
