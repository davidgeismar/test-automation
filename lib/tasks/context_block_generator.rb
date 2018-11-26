require_relative 'block'

class ContextBlockGenerator < Block
  attr_accessor :context_name, :file, :indent
  def initialize(file, context_name, indent=nil)
    super(file, indent)
    self.context_name = context_name
  end

  def generate
    file.write("context '#{context_name}' do\n")
    super
  end
end

class BeforeBlockGenerator < Block
  def generate
    file.write("before do \n")
    super
  end
end

class DescribeBlockGenerator < Block
  attr_accessor :description

  def initialize(file, indent=nil, description)
    super(file, indent)
    self.description = description
  end

  def generate
    file.write("describe '#{description}' do \n")
    super
  end
end
