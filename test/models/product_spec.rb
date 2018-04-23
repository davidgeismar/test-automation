	context 'MONGOID' do 
	context 'fields' do 
		it { is_expected.to have_field(:_id).of_type(BSON::ObjectId) } 
		it { is_expected.to have_field(:created_at).of_type(Time) } 
		it { is_expected.to have_field(:updated_at).of_type(Time) } 
		it { is_expected.to have_field(:editor_id).of_type(Object) } 
		it { is_expected.to have_field(:editor_collection_id).of_type(Object) } 
		it { is_expected.to have_field(:school_level_ids).of_type(Array) } 
		it { is_expected.to have_field(:isbn).of_type(Integer) } 
		it { is_expected.to have_field(:secondary_isbn).of_type(Integer) } 
		it { is_expected.to have_field(:reference).of_type(String) } 
		it { is_expected.to have_field(:reference_number).of_type(Integer) } 
		it { is_expected.to have_field(:description).of_type(String) } 
		it { is_expected.to have_field(:use_terms).of_type(String) } 
		it { is_expected.to have_field(:editor_code).of_type(String) } 
		it { is_expected.to have_field(:title).of_type(String) } 
		it { is_expected.to have_field(:release_date).of_type(Date) } 
		it { is_expected.to have_field(:series_name).of_type(String) } 
		it { is_expected.to have_field(:keywords).of_type(Array) } 
		it { is_expected.to have_field(:authors).of_type(Array) } 
		it { is_expected.to have_field(:published).of_type(Mongoid::Boolean) } 
		it { is_expected.to have_field(:is_bundle).of_type(Mongoid::Boolean) } 
		it { is_expected.to have_field(:is_former_casteilla).of_type(Mongoid::Boolean) } 
		it { is_expected.to have_field(:year_of_edition).of_type(Integer) } 
		it { is_expected.to have_field(:_slugs).of_type(Array) } 
		it { is_expected.to have_field(:editor__name).of_type(String) } 
		it { is_expected.to have_field(:editor_collection__name).of_type(String) } 
		it { is_expected.to have_field(:school_levels__names).of_type(String) } 
		it { is_expected.to have_field(:grades__names).of_type(String) } 
		it { is_expected.to have_field(:degrees__names).of_type(String) } 
		it { is_expected.to have_field(:grades_degrees__names).of_type(String) } 
		it { is_expected.to have_field(:subjects__names).of_type(String) } 
		it { is_expected.to have_field(:article__ids).of_type(Array) } 
		it { is_expected.to have_field(:_keywords).of_type(Array) } 
		it { is_expected.to have_field(:image_file_name).of_type(String) } 
		it { is_expected.to have_field(:image_content_type).of_type(String) } 
		it { is_expected.to have_field(:image_file_size).of_type(Integer) } 
		it { is_expected.to have_field(:image_updated_at).of_type(DateTime) } 
		it { is_expected.to have_field(:image_fingerprint).of_type(String) } 
		it { is_expected.to enumerize(:type).in(["application", "digital_book", "website"]).with_i18n_scope(models.product.enum.type) } 
		it { is_expected.to enumerize(:language).in(["arab", "chinese", "deutsch", "english", "french", "italian", "spanish"]).with_i18n_scope(models.product.enum.language) } 
		it { is_expected.to enumerize(:resource_type).in(["textbook", "extracurricular", "multimedia", "educational_support"]).with_i18n_scope(models.product.enum.resource_type) } 
	end 
	context 'associations' do 
		it { is_expected.to belong_to(:editor).of_type(Editor) } 
		it { is_expected.to belong_to(:editor_collection).of_type(EditorCollection) } 
		it { is_expected.to have_many(:articles).of_type(Article) } 
		it { is_expected.to have_and_belong_to_many(:school_levels).of_type(SchoolLevel) } 
	end 
	context 'validations' do 
		it { is_expected.to validate_presence_of(:editor) }
		it { is_expected.to validate_presence_of(:editor_collection) }
	end 
	context 'indices' do 
		it { is_expected.to have_index_for({:isbn=>1}).with_options(name: 'isbn__index') }
		it { is_expected.to have_index_for({:title=>1}).with_options(name: 'title__index') }
		it { is_expected.to have_index_for({:editor__name=>1}).with_options(name: 'editor__name__index') }
	end 
	end 
