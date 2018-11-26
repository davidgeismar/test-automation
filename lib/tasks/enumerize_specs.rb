require_relative "spec"

module EnumerizeSpecs
  class BaseSpec < Spec
    attr_accessor :klass, :file, :attribute, :indent
    def initialize(klass, file, indent=nil, attribute={})
      super(klass, file, indent)
      self.attribute = attribute
    end

    def generate
      file.write("it { is_expected.to enumerize(:#{attribute.last.name}).in(#{attribute.last.values}).with_i18n_scope(#{attribute.last.i18n_scope.first}) } \n")
    end
  end
end
