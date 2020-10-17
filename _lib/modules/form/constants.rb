# encoding: UTF-8
# frozen_string_literal: true
require_relative 'Form_helpers'

ERRORS.merge!({
  data_field_required: "Les données du champ doivent être définies",
  name_param_required: 'Il faut définir le paramètre :name.',
  unknown_tag_type: "Type de balise/field inconnu: %s",
  token_file_unfound: "Le fichier token (%s) du formulaire est introuvable",
  token_data_dont_match: "Les données du token ne matchent pas…",
  other_button_invalid: "Pour instancier un autre bouton de formulaire, il faut fournir soit le bouton lui-même (String), soit une table contenant {:text, :route}.",
})

DEFAULT_LIBELLE_WIDTH = '200px'
DEFAULT_VALUE_WIDTH   = '400px'

INPUT_SUBMIT_BUTTON = '<input type="submit" value="%{name}" class="%{class}">'
WATCHER_HIDDEN_FIELDS = '<input type="hidden" name="op" value="run" /><input type="hidden" name="wid" value="%{wid}" />'

SPAN_DATE_FIELDS = '<span id="%{prefix_id}-date-fields" class="%{class}">%{select_day}%{select_month}%{select_year}</span>'
OPTION_SELECTED_TAG = '<option value="%{value}" selected>%{titre}</option>'

INPUT_TEXT_TAG = '<input type="text" id="%{id}" name="%{name}" value="%{value}" class="%{class}" placeholder="%{placeholder}" style="%{style}" />'
INPUT_TEXT_TAG_S = '<input type="text" id="%{id}" name="%{name}" value="%{value}" />'
PASSWORD_TAG = '<input type="password" id="%{id}" name="%{name}" value="%{value}" class="%{class}" style="%{style}" />'
TEXTAREA_TAG = '<textarea id="%{id}" name="%{name}" class="%{class}" style="%{style}" placeholder="%{placeholder}">%{value}</textarea>'

TITRE_TAG = '<h4 style="%{style}">%{label}</h4>'
EXPLICATION_TAG = '<div class="explication" style="%{style}">%{text}</div>'

ERRORABLE_FIELD = '<div class="errorfield hidden" id="%{id}"></div>'

CHECKBOX_TAG = '<input type="checkbox" id="%{id}" name="%{name}"%{checked}><label for="%{id}">%{values}</label>'

# FILE_TAG = '<input type="file" name="%{name}" id="%{id}" />'

FILE_TAG = '<span id="container-file-%{id}" data-name="%{name}" class="file-field vmiddle"><button type="button" class="file-reset hidden">❌</button><input type="file" name="%{name}" id="%{name}" /><button type="button" class="file-choose btn small">%{button_name}</button><span class="file-name"></span></span>'

RAW_TAG = '<div style="%{style}">%{content}</div>'

TAGS_TYPES = {
  text:         INPUT_TEXT_TAG,
  password:     PASSWORD_TAG,
  hidden:       HIDDEN_FIELD,
  textarea:     TEXTAREA_TAG,
  select:       TAG_SELECT,
  titre:        TITRE_TAG,
  checkbox:     CHECKBOX_TAG,
  explication:  EXPLICATION_TAG,
  file:         FILE_TAG,
  date:         nil, # sera renseigné en direct
  raw:          RAW_TAG
}
