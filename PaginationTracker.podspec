Pod::Spec.new do |s|
	# info
	s.name = 'PaginationTracker'
	s.version = '1.0.0'
	s.summary = 'Small library for tracking pagination in a table or collection view.'
	s.description = <<-DESC
	Pagination tracker will listen for events that the user scrolled to a certain point,
	and will automatically trigger next page loads as needed.
	DESC
	s.homepage = 'https://github.com/appwise-labs/PaginationTracker'
	s.authors = {
		'David Jennes' => 'david.jennes@gmail.com'
	}
	s.license = {
		:type => 'MIT',
		:file => 'LICENSE'
	}

	# configuration
	s.ios.deployment_target = '10.0'
	s.swift_version = '5.0'

	# files
	s.source = {
		:git => 'https://github.com/appwise-labs/PaginationTracker.git',
		:tag => s.version
	}
	s.default_subspec = 'Core', 'CoreData'

	# Core spec
	s.subspec 'Core' do |ss|
		ss.source_files = 'Sources/Core/**/*.swift'

		ss.dependency 'Alamofire'
		ss.dependency 'StatefulUI'
	end

	# Core Data spec
	s.subspec 'CoreData' do |ss|
		ss.source_files = 'Sources/CoreData/**/*.swift'

		ss.dependency 'PaginationTracker/Core'
		ss.dependency 'AppwiseCore/CoreData'
	end
end
