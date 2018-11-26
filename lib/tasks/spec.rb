require_relative('indentation')
require_relative('hooks')
class Spec

  # include Indentation
  # include Hooks
  # before :generate, call: :indent

  def initialize(klass, file, indent=nil)
    self.klass = klass
    self.file = file
    self.indent = indent
  end

  def generate
    raise "generate method must be implemented"
  end
end
