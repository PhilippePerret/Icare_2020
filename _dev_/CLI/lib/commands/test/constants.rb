# encoding: UTF-8
# frozen_string_literal: true
require 'yaml'

TABU = "    "
URL_BASE = "https://www.atelier-icare.net"

DATA_URLS = YAML.load_file(File.join(__dir__,'data_urls.yaml'))
