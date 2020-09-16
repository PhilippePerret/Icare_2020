# encoding: UTF-8
# frozen_string_literal: true

operation("📤 Copie et importation des tables locales vers le site distant…")
operation("#{TABU}(⏳ patience, ça peut prendre un moment)")

TableGetter.export_all_tables
TableGetter.upload_all_tables
