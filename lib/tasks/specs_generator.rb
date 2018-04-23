require_relative "mongoid_spec.rb"
require_relative "enumerize_specs.rb"


class SpecsGenerator
  include MongoidSpecs
  attr_accessor :klass, :klass_methods, :args, :file, :spec_kind

  def initialize(klass, klass_methods = [], args=[], file, spec_kind)
    self.klass = klass
    self.file = file
    self.klass_methods = klass_methods
    self.args = args
    self.spec_kind = spec_kind
  end



  # private
  def generate

    instances = klass_methods.inject(klass) do |result, sub_arr|
      if sub_arr[0].present? && sub_arr[1].present?
        result.try(sub_arr[0], *sub_arr[1])
      elsif sub_arr[0]
        result.try(sub_arr[0])
      end
    end
    instances.each do |instance|
      spec_kind.new(klass, file, instance).generate
    end
  end

end
