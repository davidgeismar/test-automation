require_relative "mongoid_spec.rb"
require_relative "enumerize_specs.rb"


class SpecsGenerator
  include MongoidSpecs
  attr_accessor :klass, :file, :instances, :spec_kind, :indent
  #binding
  def initialize(klass, file, instances=nil, spec_kind, indent)
    self.klass = klass
    self.file = file
    self.spec_kind = spec_kind
    self.instances = instances
    self.indent = indent
  end



  # private
  #  too complicated need refacto
  def generate
    if instances
      instances.each do |instance|
        spec_kind.new(klass, file, indent, instance).generate
      end
    else
      spec_kind.new(klass, file, indent).generate
    end
  end
end
