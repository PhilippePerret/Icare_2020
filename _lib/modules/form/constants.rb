# encoding: UTF-8


SPAN_DATE_FIELDS = '<span id="%{prefix_id}-date-fields" class="%{class}">%{select_day}%{select_month}%{select_year}</span>'
OPTION_TAG = '<option value="%{value}">%{titre}</option>'.freeze
OPTION_SELECTED_TAG = '<option value="%{value}" selected>%{titre}</option>'.freeze
SELECT_TAG = '<select id="%{id}" name="%{name}" class="select-%{prefix} %{class}">%{options}</select>'.freeze

INPUT_TEXT_TAG = '<input type="text" id="%{id}" name="%{name}" value="%{value}" class="%{class}" />'.freeze
PASSWORD_TAG = '<input type="password" id="%{id}" name="%{name}" value="%{value}" class="%{class}" />'.freeze
TEXTAREA_TAG = '<textarea id="%{id}" name="%{name}" class="%{class}" style="height:%{height}px;">%{value}</textarea>'.freeze

TITRE_TAG = '<h4>%{label}</h4>'.freeze
EXPLICATION_TAG = '<div class="explication">%{name}</div>'.freeze

CHECKBOX_TAG = '<input type="checkbox" id="%{id}" name="%{name}"%{checked}><label for="%{id}">%{values}</label>'

FILE_TAG = '<input type="file" name="%{name}" id="%{id}" />'.freeze

RAW_TAG = '<div>%{name}</div>'.freeze

TAGS_TYPES = {
  text:         INPUT_TEXT_TAG,
  password:     PASSWORD_TAG,
  hidden:       HIDDEN_FIELD,
  textarea:     TEXTAREA_TAG,
  select:       SELECT_TAG,
  titre:        TITRE_TAG,
  checkbox:     CHECKBOX_TAG,
  explication:  EXPLICATION_TAG,
  file:         FILE_TAG,
  raw:          RAW_TAG
}
