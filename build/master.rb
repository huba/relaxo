
Dir.chdir("../") do
	require './lib/relaxo/version'

	Gem::Specification.new do |s|
		s.name = "relaxo"
		s.version = Relaxo::VERSION::STRING
		s.author = "Samuel Williams"
		s.email = "samuel.williams@oriontransfer.co.nz"
		s.homepage = "http://www.oriontransfer.co.nz/gems/relaxo"
		s.platform = Gem::Platform::RUBY
		s.summary = "Relaxo is a helper for loading and working with CouchDB."
		s.files = FileList["{bin,lib,test}/**/*"] + ["README.md"]

		s.executables << 'relaxo'

		s.add_dependency("couchrest")
		s.add_dependency("rest-client")

		s.has_rdoc = "yard"
	end
end
