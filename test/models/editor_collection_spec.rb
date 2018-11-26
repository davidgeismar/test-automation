	context 'MONGOID' do 
	context 'fields' do 
		it { is_expected.to have_field(:_id).of_type(BSON::ObjectId).with_default_value_of(#<Proc:0x00007fb7c9673828@/Users/davidgeismar/.rbenv/versions/2.4.3/lib/ruby/gems/2.4.0/gems/mongoid-6.4.0/lib/mongoid/fields.rb:55 (lambda)>) } 
		it { is_expected.to have_field(:created_at).of_type(Time).with_default_value_of() } 
		it { is_expected.to have_field(:updated_at).of_type(Time).with_default_value_of() } 
	end 
	end 
