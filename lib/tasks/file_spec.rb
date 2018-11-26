require_relative "spec"

module FileSpecs

  class NameSpec < Spec
    attr_accessor :klass, :file, :indent, :field_name

    def initialize(klass, file, indent, field_name)
      super(klass, file, indent)
      self.field_name = field_name
    end

    def generate
      file.write("it stores file_name do\n")
      file.write("\t\texpect(#{klass.to_s.downcase}.#{field_name}_file_name).to eq('missing.png')\n")
      file.write("\t\tend\n")
    end
  end

  class ContentTypeSPec < Spec
    attr_accessor :klass, :file, :indent, :field_name

    def initialize(klass, file, indent, field_name)
      super(klass, file, indent)
      self.field_name = field_name
    end

    def generate
      file.write("\t\tit stores content_type do\n")
      file.write("\t\t\t\texpect(#{klass.to_s.downcase}.#{field_name}_content_type).to eq('#{field_name}/png')).to eq('missing.png')\n")
      file.write("\t\tend\n")
    end
  end

  class SizeSpec < Spec
    attr_accessor :klass, :file, :indent, :field_name

    def initialize(klass, file, indent, field_name)
      super(klass, file, indent)
      self.field_name = field_name
    end

    def generate
      file.write("\t\tit stores file_size\n")
      file.write("\t\t\t\texpect(#{klass.to_s.downcase}.#{field_name}_file_size).to eq(95)\n")
      file.write("\t\tend\n")
    end
  end

  class UpdatedAtSpec < Spec
    attr_accessor :klass, :file, :indent, :field_name

    def initialize(klass, file, indent, field_name)
      super(klass, file, indent)
      self.field_name = field_name
    end

    def generate
      file.write("\t\tit stores updated_at\n")
      file.write("\t\t\t\texpect(#{klass.to_s.downcase}.#{field_name}_updated_at).to be_present\n")
      file.write("\t\tend\n")
    end
  end

  class FingerprintSpec < Spec
    attr_accessor :klass, :file, :indent, :field_name

    def initialize(klass, file, field_name)
      super(klass, file)
      self.field_name = field_name
    end

    def generate
      file.write("\t\tit stores fingerprint\n")
      file.write("\t\t\t\texpect(#{klass.to_s.downcase}.#{field_name}_fingerprint).to eq('71a50dbba44c78128b221b7df7bb51f1')\n")
      file.write("\t\tend\n")
    end
  end
end
