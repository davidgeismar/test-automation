require_relative "test_file_generator"
namespace :specs do

  def retrieve_filenames_without_ext(path, process_filename)
    filenames = Dir["#{path}/*.rb"]
    return filenames.map{|filename| process_filename.call filename}
  end

  desc 'check specs to writte'
  task to_write: :environment do
    spec_folder = YAML.load_file(Rails.root.join('lib', 'tasks', 'config.yml'))["spec_folder"]
    spec_models_path = Rails.root.join(spec_folder, 'models')
    models = retrieve_filenames_without_ext(Rails.root.join('app', 'models'), Proc.new {|filename| filename.split("/")[-1][0..-4]})
    spec_models = retrieve_filenames_without_ext(spec_models_path, Proc.new{|filename| filename.split("/")[-1][0..-9]})
    diff = models - spec_models
    puts(diff)
    puts(diff.count)
    diff.each do |filename|
      File.open("#{spec_models_path}/#{filename}_spec.rb", "w+") do |f|

         TestFileGenerator.new(filename.classify.constantize, f).init_test_creation

      end
       # bundle exec rspec spec/models/product_spec.#!/usr/bin/env ruby -wKU

    end
  end

end
