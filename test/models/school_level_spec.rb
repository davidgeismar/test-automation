context 'fields' do 
	it { is_expected.to have_field(:_id).of_type(BSON::ObjectId) } 
	it { is_expected.to have_field(:created_at).of_type(Time) } 
	it { is_expected.to have_field(:updated_at).of_type(Time) } 
end 

context 'associations' do 
end 
