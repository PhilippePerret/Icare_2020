# encoding: UTF-8
# frozen_string_literal: true
require_module('watchers')

EMO_TRAVAIL   = Emoji.get('objets/serre-joint')
EMO_PUNAISE   = Emoji.get('objets/punaise')
EMO_CALENDAR  = Emoji.get('objets/calendar')
EMO_BUREAU    = Emoji.get('objets/bureau')

RETOUR_BUREAU = Tag.retour(route:'bureau/home', titre:'Bureau')
