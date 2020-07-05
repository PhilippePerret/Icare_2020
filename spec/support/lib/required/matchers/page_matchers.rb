# encoding: UTF-8
=begin
  Matchers de page (Capybara::Session)
=end

RSpec::Matchers.define :have_titre do |expected, options|
  match do |page|
    @errors = []
    @actual = page.find('h2.page-title').text
    expected = Regexp.new(expected) if expected.is_a?(String)
    ok = @actual =~ expected
    ok || @errors << "le titre devrait être à peu près “#{expected.source}”, mais c’est “#{@actual}”"
    unless options.nil?
      if options.key?(:retour)
        retour_exists = page.has_css?("h2.page-title a[href=\"#{options[:retour][:route]}\"]", text: options[:retour][:text])
        unless retour_exists
          if page.has_css?('h2.page-title a')
            dretour = options[:retour]
            if dretour.key?(:route)
              unless page.has_css?("h2.page-title a[href=\"#{dretour[:route]}\"]")
                hrefretour = page.find('h2.page-title a')['href']
                @errors << "La route du lien retour devrait être `#{dretour[:route]}`, or c'est `#{hrefretour}`"
              end
            end
            if dretour.key?(:text)
              unless page.has_css?('h2.page-title a', text: dretour[:text])
                textretour = page.find('h2.page-title a').text
                @errors << "Le texte du lien retour devrait être “#{dretour[:text]}” or c'est “#{textretour}”"
              end
            end
          else
            @errors << "le titre ne contient aucun lien retour"
          end
        end
        ok = ok && retour_exists
      end
    end
    ok
  end
  description do
    "Le titre de la page est à peu près “#{expected.source}”."
  end
  failure_message do
    "Mauvais titre de page : #{@errors.join(VG)}."
  end
end #/have_titre
