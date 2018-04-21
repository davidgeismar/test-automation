require 'rails_helper'

RSpec.describe Product, type: :model do

  let(:product) { create(:product) }

  context 'MONGOID' do
    it { is_expected.to be_timestamped_document }
    it { is_expected.to be_kind_of Mongoid::Slug }
    it { is_expected.to be_kind_of Edulib::Datatable }

    context 'fields' do
      it { is_expected.to have_field(:isbn).of_type(Integer) }
      it { is_expected.to have_field(:secondary_isbn).of_type(Integer) }
      it { is_expected.to enumerize(:type).in(:digital_book, :website, :application).with_i18n_scope(['models.product.enum.type']) }
      it { is_expected.to have_field(:editor_code).of_type(String) }
      it { is_expected.to have_field(:title).of_type(String) }
      it { is_expected.to have_field(:reference).of_type(String) }
      it { is_expected.to have_field(:description).of_type(String) }
      it { is_expected.to have_field(:use_terms).of_type(String) }
      it { is_expected.to have_field(:release_date).of_type(Date) }
      it { is_expected.to enumerize(:language).in(:arab, :chinese, :deutsch, :english, :french, :italian, :spanish).with_i18n_scope(['models.product.enum.language']) }
      it { is_expected.to have_field(:series_name).of_type(String) }
      it { is_expected.to enumerize(:resource_type).in(:textbook, :extracurricular, :multimedia, :educational_support).with_i18n_scope(['models.product.enum.resource_type']) }
      it { is_expected.to have_field(:authors).of_type(Array).with_default_value_of([]) }
      it { is_expected.to have_field(:keywords).of_type(Array).with_default_value_of([]) }
      it { is_expected.to have_field(:published).of_type(Mongoid::Boolean) }
      it { is_expected.to have_field(:is_bundle).of_type(Mongoid::Boolean) }
      it { is_expected.to have_field(:is_former_casteilla).of_type(Mongoid::Boolean).with_default_value_of(false) }
      it { is_expected.to have_field(:editor__name).of_type(String) }
      it { is_expected.to have_field(:school_levels__names).of_type(String) }
      it { is_expected.to have_field(:grades__names).of_type(String) }
      it { is_expected.to have_field(:degrees__names).of_type(String) }
      it { is_expected.to have_field(:grades_degrees__names).of_type(String) }
      it { is_expected.to have_field(:subjects__names).of_type(String) }
      it { is_expected.to have_field(:article__ids).of_type(Array).with_default_value_of([]) }
    end

    context 'associations' do
      it { is_expected.to belong_to(:editor).of_type(Editor) }

      it { is_expected.to have_many(:articles).of_type(Article) }

      it { is_expected.to have_and_belong_to_many(:school_levels).of_type(SchoolLevel) }
      it { is_expected.to have_and_belong_to_many(:grades).of_type(Grade) }
      it { is_expected.to have_and_belong_to_many(:degrees).of_type(Degree) }
      it { is_expected.to have_and_belong_to_many(:subjects).of_type(Subject) }
    end

    context 'validations' do
      it { is_expected.to validate_presence_of(:subjects) }
      it { is_expected.to validate_presence_of(:grades) }
      it { is_expected.to validate_presence_of(:subjects) }
      it { is_expected.to validate_presence_of(:type) }
      it { is_expected.to validate_presence_of(:reference) }
      it { is_expected.to validate_presence_of(:title) }
      it { is_expected.to validate_presence_of(:resource_type) }
      it { is_expected.to validate_presence_of(:release_date) }
      it { is_expected.to validate_presence_of(:editor) }
    end

    context 'index' do
      it { is_expected.to have_index_for(isbn: 1).with_options(name: 'isbn__index') }
      it { is_expected.to have_index_for(title: 1).with_options(name: 'title__index') }
      it { is_expected.to have_index_for(editor__name: 1).with_options(name: 'editor__name__index') }
    end

    context 'methods' do
      it { is_expected.to respond_to :after_article_add }
      it { is_expected.to respond_to :before_article_remove }
      it { is_expected.to respond_to :product_image }
      it { is_expected.to respond_to :product_school_level }
      it { is_expected.to respond_to :product_grades }
      it { is_expected.to respond_to :product_degrees }
      it { is_expected.to respond_to :product_grades_degrees }
      it { is_expected.to respond_to :product_subjects }
    end

    context 'paperclip file' do
      before do
        product.update image: File.new('app/assets/images/missing/missing.png', 'rb')
      end
      it 'stores file_name' do
        expect(product.image_file_name).to eq('missing.png')
      end
      it 'stores content_type' do
        expect(product.image_content_type).to eq('image/png')
      end
      it 'stores file_size' do
        expect(product.image_file_size).to eq(95)
      end
      it 'stores updated_at' do
        expect(product.image_updated_at).to be_present
      end
      it 'stores fingerprint' do
        expect(product.image_fingerprint).to eq('71a50dbba44c78128b221b7df7bb51f1')
      end
    end
  end

  context 'DATATABLE' do
    describe 'datatable_exclude_fields' do
      it { expect(Product.datatable_exclude_fields).to match_array %w(editor_code reference_number series_name editor_collection__name release_date language resource_type keywords authors secondary_isbn description use_terms is_bundle is_former_casteilla _keywords grades__names degrees__names) }
    end

    describe 'datatable_fields' do
      it { expect(Product.datatable_fields).to match [:isbn, :reference, :title, :published, :year_of_edition, :editor__name, :school_levels__names, :grades_degrees__names, :subjects__names, :type, :image, :_id] }
    end

    describe 'datatable_search_fields' do
      it { expect(Product.datatable_search_fields).to contain_exactly :isbn, :reference, :title, :published, :year_of_edition, :editor__name, :school_levels__names, :grades_degrees__names, :subjects__names}
    end

    describe 'datatable_config' do
      it { expect(Product.datatable_config('http://example.com')).to include 'ajax', 'pagingType', 'serverSide', 'pageLength', 'columns', 'language' }
    end
  end
end
