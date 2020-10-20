# encoding: UTF-8

# Le fait de prendre des screenshots est très dispendieux en temps
# On peut les zapper en mettant cette constante à true
NO_SCREENSHOT = false
# NO_SCREENSHOT = true

require 'yaml'
require 'capybara/rspec'

Capybara.run_server = false
Capybara.default_driver = :selenium
# Test sans navigateur
# Capybara.default_driver = :selenium_headless
# Capybara.current_driver = :selenium_headless


Capybara.save_path = './spec/tmp/screenshots'

# Les requisitions pour les tests
require './spec/support/lib/required'
# Les constantes d'erreurs générales sur l'atelier
require './_lib/required/__first/constants/errs_n_mess'

class Capybara::Session
  include SpecModuleNavigation
end

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|

  def implementer(path, line)
    puts "Implémenter le test #{path}:#{line}".jaune
  end #/ pending

  # Pour requérir tout un dossier se trouvant dans ./spec/support/modules
  def require_support(folder_name)
    Dir["./spec/support/modules/#{folder_name}/**/*.rb"].each{|m|require m}
  end #/ require_support

  config.include Capybara::DSL, :type => :feature

  # POur se souvenir des tests qui échouent
  config.example_status_persistence_file_path = './spec/tmp/failure_files.txt'

  # Pour ne pas écrire la ligne indiquant les options employées
  config.silence_filter_announcements = true

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before :suite do
    # puts "Je commance la suite de tests"
    # À EXÉCUTER AVANT LES TESTS
    ENV['SPEC_FORMATTER'] = case config.formatters.first.class.name
    when /DocumentationFormatter$/ then "Documentation"
    when /ProgressFormatter$/ then "Progress"
    else config.formatters.first.class.name.split('::').last
    end
    # puts "config.formatters.first: #{config.formatters.first.class.name}"
    # puts "ENV['SPEC_FORMAT']: #{ENV['SPEC_FORMAT'].inspect}"
    vide_all_dossiers
    vide_db
    File.open('./TESTS_ON','wb'){|f|f.write(Time.now.to_i.to_s)}

  end
  config.after :suite do
    # À EXÉCUTER APRÈS LES TESTS
    # puts "Je finis la suite de tests"
    File.unlink('./TESTS_ON') if File.exists?('./TESTS_ON')
  end

  config.before :each do
    extend SpecModuleNavigation
  end

  def pitch msg
    unless ENV['SPEC_FORMATTER'] == 'Documentation'
      # Si on ne doit pas visualiser les messages (-fd/--format documentation)
      # on s'en retourne. Mais on attend quand même un tout petit car souvent
      # ça laisse le temps de finir d'écrire un fichier, d'enregistrer une
      # donnée dans la base de données, etc.
      sleep 0.3
      return
    end
    puts msg.gsub(/^[\t ]+/,'').bleu
  end #/ pitch


  # Pour requérir un module dans le dossier './spec/support/data'
  FOLDER_SUPPORT = File.join('.','spec','support')
  FOLDER_DATA = File.join(FOLDER_SUPPORT,'data')
  def require_data(relpath)
    require File.join(FOLDER_DATA, relpath)
  end #/ require_data

  def degel(gel_name)
    require_gel unless defined?(Gel)
    Gel.get(gel_name).degel
  end #/ degel

  def require_gel
    Dir['./spec/support/Gel/**/*.rb'].each{|m|require m}
  end #/ require_gel


  def screenshot(affixe)
    return if NO_SCREENSHOT
    @screenshot_index ||= 0
    save_screenshot("#{@screenshot_index += 1}-#{affixe}.png")
  end #/ screenshot


  def uri_encode(str)
    URI.encode_www_form_component(str)
  end #/ uri_encode


# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  config.filter_run_when_matching :focus

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = true

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end
end
