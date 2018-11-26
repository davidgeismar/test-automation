require 'pry-byebug'
require_relative 'test_procs'
require_relative 'specs_generator'
require_relative 'context_block_generator'
require_relative 'image_spec_block_generator'
require_relative 'instance_method_spec'
require_relative 'datatable_spec'

class TestFileGenerator

  include TestProcs
  attr_accessor :klass,
                :file,
                :generate_fields,
                :generate_enumerized_attributes,
                :generate_associations,
                :generate_validators,
                :generate_index_specifications

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

    # exclude unknown modules"#<Module:0x00007fe896c2be98>",
    highest_namespaces = (modules.map do|mod|
                              mod.to_s.split( '::' )[0].constantize unless mod.to_s.starts_with?("#")
                          end).uniq.compact
    # Mongoid
    if highest_namespaces.include? Mongoid
      ContextBlockGenerator.new(file, "MONGOID", 0).generate do
        if modules.include? Mongoid::Document
          #FIELDS
          ContextBlockGenerator.new(file, "fields", 2).generate do
            SpecsGenerator.new(klass, file, klass.fields, MongoidSpecs::DocumentSpec, 4).generate  if klass.fields.present?
            # ENUMERIZE

            SpecsGenerator.new(klass, file, klass.enumerized_attributes.attributes, EnumerizeSpecs::BaseSpec, 4).generate  if (modules.include?(Enumerize::Base) && klass.enumerized_attributes.present?)

          end
        end
        # #ASSOCIATIONS
        # if klass.reflect_on_all_associations(:belongs_to, :has_many, :has_and_belongs_to_many).present?
        #   ContextBlockGenerator.new(file, "associations").generate do
        #     SpecsGenerator.new(klass, file, klass.reflect_on_all_associations(:belongs_to, :has_many, :has_and_belongs_to_many), MongoidSpecs::AssociationSpec).generate
        #   end
        # end
        # # VALIDATORS
        # if klass.validators.present?
        #   ContextBlockGenerator.new(file, "validations").generate do
        #     SpecsGenerator.new(klass, file, klass.validators, MongoidSpecs::ValidationSpec).generate
        #   end
        # end
        # #INDICES
        # if klass.index_specifications.present?
        #   ContextBlockGenerator.new(file, "indices").generate do
        #     SpecsGenerator.new(klass, file, klass.index_specifications, MongoidSpecs::IndexSpec).generate
        #   end
        # end
        # instance_methods = klass.instance_methods(false).select {|m| klass.instance_method(m).source_location.first.ends_with? "/#{klass.to_s.downcase}.rb"}
        # if instance_methods.present?
        #   ContextBlockGenerator.new(file, "instance methods").generate do
        #     SpecsGenerator.new(klass, file, instance_methods, ::InstanceMethodSpec).generate
        #   end
        # end
        # if klass.attachment_definitions.present?
        #   ContextBlockGenerator.new(file, "paperclip_files").generate do
        #     ImageSpecBlockGenerator.new(klass, file, klass.attachment_definitions.keys).generate
        #   end
        # end
        # if modules.include? Edulib::Datatable
        #   ContextBlockGenerator.new(file, "Datatable").generate do
        #     if klass.datatable_exclude_fields.present?
        #       DescribeBlockGenerator.new(file, 'datatable_exclude_fields').generate do
        #         SpecsGenerator.new(klass, file, nil, ::DatatableSpecs::ExcludeFieldsSpec).generate
        #       end
        #     end
        #     if klass.datatable_fields.present?
        #       DescribeBlockGenerator.new(file, 'datatable_fields').generate do
        #         SpecsGenerator.new(klass, file, nil, ::DatatableSpecs::FieldsSpec).generate
        #       end
        #     end
        #     if klass.datatable_search_fields.present?
        #       DescribeBlockGenerator.new(file, 'datatable_search_fields').generate do
        #         SpecsGenerator.new(klass, file,nil,  ::DatatableSpecs::SearchFieldsSpec).generate
        #       end
        #     end
        #     DescribeBlockGenerator.new(file, 'datatable_config').generate do
        #       SpecsGenerator.new(klass, file, nil, ::DatatableSpecs::ConfigSpec).generate
        #     end
        #   end
        # end
      end
    end
  end

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
