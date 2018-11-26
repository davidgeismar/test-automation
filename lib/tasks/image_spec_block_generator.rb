require_relative('file_spec')
class ImageSpecBlockGenerator < Spec
  attr_accessor :klass, :file, :instances

  def initialize(klass, file, indent, instances)
    super(klass, file, indent)
    self.instances = instances
  end

  def generate
    BeforeBlockGenerator.new(file) do
      file.write("#{klass.to_s.downcase}.update image: File.new('app/assets/images/missing/missing.png', 'rb')")
    end
    instances.each do |instance|
      ::FileSpecs::NameSpec.new(klass,file, instance).generate
      ::FileSpecs::ContentTypeSPec.new(klass,file, instance).generate
      ::FileSpecs::SizeSpec.new(klass, file, instance).generate
      ::FileSpecs::UpdatedAtSpec.new(klass, file, instance).generate
      ::FileSpecs::FingerprintSpec.new(klass, file, instance).generate
    end
    # file.write("\t\tit { is_expected.to respond_to :#{method} }\n")
  end
end
