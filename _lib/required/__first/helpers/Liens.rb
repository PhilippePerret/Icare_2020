# encoding: UTF-8
# frozen_string_literal: true
require_relative './Linker'


CONTACT_LINK = Linker.new(text: 'formulaire de contact', route:"contact/mail")
LOGIN_LINK   = Linker.new(text: 's’identifier', route:'user/login')
