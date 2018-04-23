require 'pry-byebug'
require_relative 'test_procs'
require_relative 'specs_generator'
require_relative 'context_block_generator'

class TestFileGenerator
  include TestProcs
  attr_accessor :klass, :file, :generate_fields, :generate_enumerized_attributes, :generate_associations, :generate_validators, :generate_index_specifications

  def initialize(klass, file, generate_fields = true, generate_enumerized_attributes = true, generate_associations = true,
                 generate_validators = true, generate_index_specifications = true)
    self.klass = klass
    self.file = file
    self.generate_fields = generate_fields
    self.generate_enumerized_attributes = generate_enumerized_attributes
    self.generate_associations = generate_associations
    self.generate_validators = generate_validators
    self.generate_index_specifications = generate_index_specifications
  end


  def init_test_creation
    modules = klass.included_modules
    # highest_namespaces = modules.map{|module| module.to_s.split( '::' )[0].constantize}.uniq

    ContextBlockGenerator.new(file, "MONGOID").generate do
      ContextBlockGenerator.new(file, "fields").generate do
        SpecsGenerator.new(klass, [[:fields]], [], file, MongoidSpecs::DocumentSpec).generate  if modules.include? Mongoid::Document
        SpecsGenerator.new(klass, [[:enumerized_attributes, []], [:attributes, []]], [], file, EnumerizeSpecs::BaseSpec).generate  if modules.include? Enumerize::Base
      end
      ContextBlockGenerator.new(file, "associations").generate do
        SpecsGenerator.new(klass, [[:reflect_on_all_associations, [:belongs_to, :has_many, :has_and_belongs_to_many]]], file, MongoidSpecs::AssociationSpec).generate
      end
      ContextBlockGenerator.new(file, "validations").generate do
        SpecsGenerator.new(klass, [[:validators]], file, MongoidSpecs::ValidationSpec).generate
      end
      ContextBlockGenerator.new(file, "indices").generate do
        SpecsGenerator.new(klass, [[:index_specifications]], file, MongoidSpecs::IndexSpec).generate
      end
    end





  end
  #
  # def init_test_creation
  #   file.write("RSpec.describe #{klass}, type: :model do \n")
  #   data = [
  #     { klass_method: :fields, klass_method_args: nil, allow_generation: generate_fields,
  #       context_name: 'fields', write_spec_proc: field_proc },
  #     { klass_method: :enumerized_attributes, klass_method_args: nil,
  #       allow_generation: generate_enumerized_attributes, context_name: 'enumerize',
  #       write_spec_proc: enumerize_proc },
  #     { klass_method: :validators, klass_method_args: nil,
  #       allow_generation: generate_validators, context_name: 'validations',
  #       write_spec_proc: validation_proc },
  #     { klass_method: :index_specifications, klass_method_args: nil,
  #       allow_generation: generate_index_specifications, context_name: 'index',
  #       write_spec_proc: index_proc },
  #     { klass_method: :reflect_on_all_associations, klass_method_args: %i[belongs_to has_many has_and_belongs_to_many],
  #       allow_generation: generate_associations, context_name: 'associations', write_spec_proc: association_proc }
  #
  #   ]
  #
  #   data.each do |argv|
  #     generate_specs(argv)
  #   end
  #
  #   file.write("end \n")
  # end

  private

  def generate_specs(klass_method: klass_method, klass_method_args: klass_method_args, allow_generation: allow_generation, context_name: context_name, write_spec_proc: write_spec_proc)
    if klass.send(klass_method, *klass_method_args).present? && allow_generation
      file.write("\tcontext '#{context_name}' do \n")
      if klass_method_args.present?
        write_spec_proc.call klass, klass_method, klass_method_args
      else
        write_spec_proc.call klass.send(klass_method)
      end
      file.write("\tend \n")
    end
  end
end
