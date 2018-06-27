require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'

begin
  if Gem::Specification::find_by_name('puppet-lint')
    require 'puppet-lint/tasks/puppet-lint'
    PuppetLint.configuration.ignore_paths = ["spec//*.pp", "pkg//*.pp"]
    PuppetLint.configuration.fail_on_warnings
    PuppetLint.configuration.send('relative')
    PuppetLint.configuration.send('disable_80chars')
    PuppetLint.configuration.send('disable_class_inherits_from_params_class')
    PuppetLint.configuration.send('disable_class_parameter_defaults')
    PuppetLint.configuration.send('disable_documentation')
    PuppetLint.configuration.send('disable_single_quote_string_with_variables')
    task :default => [:rspec, :lint]
  end
rescue Gem::LoadError
  task :default => :rspec
end
