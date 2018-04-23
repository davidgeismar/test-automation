class ContextBlockGenerator
  attr_accessor :file, :context_name
  def initialize(file, context_name)
    self.file = file
    self.context_name = context_name
  end

  def generate(&spec_block)
    file.write("\tcontext '#{context_name}' do \n")
    spec_block.call
    file.write("\tend \n")
  end
end
