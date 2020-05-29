# encoding: UTF-8
HIDDEN_FIELD  = '<input type="hidden" id="%{id}" name="%{name}" value="%{value}" />'.freeze
SUBMIT_BUTTON = '<input type="submit" class="btn" value="%{name}" />'.freeze

SPAN_TAG = '<span class="%{class}">%{text}</a>'.freeze

SPAN_DATE_FIELDS = '<span id="%{prefix_id}-date-fields" class="%{class}">%{select_day}%{select_month}%{select_year}</span>'
OPTION_TAG = '<option value="%{value}">%{titre}</option>'.freeze
OPTION_SELECTED_TAG = '<option value="%{value}" selected>%{titre}</option>'.freeze
SELECT_TAG = '<select id="%{id}" name="%{name}" class="select-%{prefix} %{class}">%{options}</select>'.freeze

INPUT_TEXT_TAG = '<input type="text" id="%{id}" name="%{name}" value="%{value}" class="%{class}" />'.freeze
PASSWORD_TAG = '<input type="password" id="%{id}" name="%{name}" value="%{value}" class="%{class}" />'.freeze
TEXTAREA_TAG = '<textarea id="%{id}" name="%{name}" class="%{class}">%{value}</textarea>'.freeze

TAGS_TYPES = {
  text:       INPUT_TEXT_TAG,
  password:   PASSWORD_TAG,
  hidden:     HIDDEN_FIELD,
  textarea:   TEXTAREA_TAG
}
