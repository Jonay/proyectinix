class ActsAsVoteableMigrationGenerator < Rails::Generator::Base

	def manifest
		record do |m|
			m.migration_template 'migration.rb', File.join('db', 'migrate'), :assigns => {
			  :migration_name => 'CreateVoteable'
			}, :migration_file_name => 'create_voteable'
		end
	end
end
