# frozen_string_literal: true

RSpec.configure do |c|
  c.mock_with :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

require 'spec_helper_local' if File.file?(
  File.join(File.dirname(__FILE__), 'spec_helper_local.rb'),
)

include RspecPuppetFacts

default_facts = {
  puppetversion: Puppet.version,
  facterversion: Facter.version
}

default_fact_files = [
  File.expand_path(
    File.join(File.dirname(__FILE__), 'default_facts.yml'),
  ),
  File.expand_path(
    File.join(File.dirname(__FILE__), 'default_module_facts.yml'),
  ),
]

default_fact_files.each do |file|
  next unless File.exist?(file)
  next unless File.readable?(file)
  next unless File.size?(file)

  begin
    require 'deep_merge'

    data = YAML.safe_load(
      File.read(file),
      permitted_classes: [],
      permitted_symbols: [],
      aliases: true,
    )

    default_facts.deep_merge!(data)
  rescue StandardError => e
    RSpec.configuration.reporter.message(
      "WARNING: Unable to load #{file}: #{e}",
    )
  end
end

default_facts.each do |fact, value|
  add_custom_fact fact, value, merge_facts: true
end

RSpec.configure do |c|
  c.default_facts = default_facts

  c.before :each do
    Puppet.settings[:strict] = :warning
    Puppet.settings[:strict_variables] = true
  end

  c.filter_run_excluding(bolt: true) unless ENV['GEM_BOLT']

  c.after(:suite) do
    RSpec::Puppet::Coverage.report!(0)
  end

  backtrace_exclusion_patterns = [
    %r{spec_helper},
    %r{gems},
  ]

  if c.respond_to?(:backtrace_exclusion_patterns)
    c.backtrace_exclusion_patterns = backtrace_exclusion_patterns
  elsif c.respond_to?(:backtrace_clean_patterns)
    c.backtrace_clean_patterns = backtrace_exclusion_patterns
  end
end

def ensure_module_defined(module_name)
  module_name.split('::').reduce(Object) do |last, name|
    unless last.const_defined?(name, false)
      last.const_set(name, Module.new)
    end

    last.const_get(name, false)
  end
end
