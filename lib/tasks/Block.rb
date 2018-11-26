require_relative 'hooks'

class Block
  include Indentation
  include Hooks
  attr_accessor :file, :indent
  before :generate, call: :indent
  # after  :generate, call: :write_end

  def initialize(file, indent=nil)
    self.file = file
    self.indent = indent
  end

  def generate
    yield
  end
end
