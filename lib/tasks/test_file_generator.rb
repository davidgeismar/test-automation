require "pry-byebug"
require_relative 'test_procs'

class TestFileGenerator
  include ::TestProcs
  attr_accessor :klass, :file, :generate_fields, :generate_enumerized_attributes, :generate_associations, :generate_validators, :generate_index_specifications

  def initialize(klass, file, generate_fields=true, generate_enumerized_attributes=true, generate_associations=true,
                  generate_validators=true, generate_index_specifications=true )
    self.klass = klass
    self.file = file
    self.generate_fields = generate_fields
    self.generate_enumerized_attributes = generate_enumerized_attributes
    self.generate_associations = generate_associations
    self.generate_validators = generate_validators
    self.generate_index_specifications = generate_index_specifications
  end

  def init_test_creation
    file.write("RSpec.describe #{klass}, type: :model do \n")


    data = [{klass_method: :fields, klass_method_args: nil, allow_generation: generate_fields, context_name: "fields", write_spec_proc: field_proc },
            {klass_method: :enumerized_attributes, klass_method_args: nil, allow_generation: generate_enumerized_attributes,context_name: "enumerize", write_spec_proc: enumerize_proc},
            {klass_method: :validators, klass_method_args: nil, allow_generation: generate_validators, context_name: "validations",  write_spec_proc: validation_proc },
            {klass_method: :index_specifications, klass_method_args: nil, allow_generation: generate_index_specifications, context_name: "index", write_spec_proc: index_proc },
            {klass_method: :reflect_on_all_associations, klass_method_args: [:belongs_to, :has_many, :has_and_belongs_to_many], allow_generation: generate_associations, context_name: "associations", write_spec_proc: association_proc }

            ]

    data.each do |argv|
      generate_specs(argv)
    end


    # association_specs_generator



      # validation_specs_generator

      # index_specification_specs_generator

    file.write("end \n")

  end

  private


  def association_specs_generator
    if klass.reflect_on_all_associations(:belongs_to, :has_many, :has_and_belongs_to_many).present? && generate_associations
       file.write("\tcontext 'associations' do \n")
         klass.reflect_on_all_associations(:belongs_to).each do |relation|
           file.write("\t\tit { is_expected.to belong_to(:#{relation.name}).of_type(#{relation.name.to_s.classify.constantize}) } \n")
         end
         klass.reflect_on_all_associations(:has_many).each do |relation|
           file.write("\t\tit { is_expected.to have_many(:#{relation.name}).of_type(#{relation.name.to_s[0..-2].classify.constantize}) } \n")
         end
         klass.reflect_on_all_associations(:has_and_belongs_to_many).each do |relation|
           file.write("\t\tit { is_expected.to have_and_belong_to_many(:#{relation.name}).of_type(#{relation.name.to_s[0..-2].classify.constantize}) } \n")
         end
      file.write("\tend \n")
    end
  end

  def generate_specs(klass_method: klass_method, klass_method_args: klass_method_args, allow_generation: allow_generation, context_name: context_name, write_spec_proc: write_spec_proc )
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
