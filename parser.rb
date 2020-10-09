#!/usr/bin/env ruby
#-*- encoding: utf-8 -*-

# http://blog.evernote.com/tech/2013/08/08/evernote-export-format-enex/

require 'nokogiri'
require 'date'
require 'ostruct'

class Note < OpenStruct; end
class Notes < Array; end

notes = Notes.new

xml = Nokogiri::XML(File.open(ARGV[0]))
xml.xpath("//note").each do |n|
  note = Note.new
  note.title = n.xpath('title').first.content
  note.content_xml = n.xpath('content').first.content
  note.content = Nokogiri::XML(note.content_xml).content
  note.created = DateTime.parse(n.xpath('created').first.content)
  note.updated = DateTime.parse(n.xpath('updated').first.content)
  note.tags = n.xpath('tag').map(&:content)
  note.attributes = n.xpath('note-attributes')
                     .children
                     .inject({}){|h, i| h[i.name] = i.content ; h }
  notes << note
end