# encoding: UTF-8
# frozen_string_literal: true
require_relative '../../optional_classes/TUser'
require_relative '../../optional_classes/TMails'
require_relative '../../optional_classes/TActualites'
require_relative '../../optional_classes/TWatchers'

CONCOURS_SUPPORT_FOLDER = File.expand_path(File.join('.','spec','support','asset','concours'))
CONCOURS_FOLDER_FICHES_EVALUATIONS = File.join(CONCOURS_SUPPORT_FOLDER, 'fiches_evaluations')
