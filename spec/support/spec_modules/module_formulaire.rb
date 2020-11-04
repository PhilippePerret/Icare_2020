# encoding: UTF-8
=begin

  @usage

  feature ...
    scenario ...
      extend SpecModuleFormulaire

=end

module SpecModuleFormulaire
  def fill_formulaire_with(form_id, data)
    within(form_id) do
      data.each do |prop, val|
        next if val[:editable] === false
        name = "u#{prop}"
        value = val[:value]
        case val[:type]
        when 'select'
          select(value, from: name)
        when 'checkbox'
          if value === true
            check(name)
          else
            uncheck(name)
          end
        when 'file'
          unless value.nil? || value.empty?
            fpath = File.join(SPEC_FOLDER_DOCUMENTS, value)
            attach_file(name, fpath)
          end
        else
          fill_in(name, with: value)
        end
      end
    end
  end #/ fill_formulaire_with
  def submit_formulaire(form_id)
    within(form_id) do
      click_on('Candidater')
    end
  end #/ submit_formulaire
  def check_messages_errors(data)
    sleep 0.3 # juste pour souffler (je sais qu'on n'en a pas besoin)
    data.each do |prop, val|
      expect(page).to have_content(val[:have]) unless val[:have].nil?
      expect(page).not.to have_content(val[:not_have]) unless val[:not_have].nil?
    end
  end #/ check_messages_errors
end
