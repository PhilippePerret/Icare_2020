# encoding: UTF-8
# frozen_string_literal: true
require 'json'

ONLINE = false # CLI s'utilise toujours en local
OFFLINE = !ONLINE

require './_lib/_pages_/concours/xrequired/constants'
require_relative './Concours'
