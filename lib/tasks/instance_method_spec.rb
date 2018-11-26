class InstanceMethodSpec < Spec
  attr_accessor :klass, :file, :method

  def initialize(klass, file, indent, method)
    super(klass, file, indent)
    self.method = method
  end

  def generate
    file.write("it { is_expected.to respond_to :#{method} }\n")
  end
end
