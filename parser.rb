#!/usr/bin/env ruby
#-*- encoding: utf-8 -*-

# http://blog.evernote.com/tech/2013/08/08/evernote-export-format-enex/

require 'nokogiri'
require 'date'
require 'ostruct'
# require 'pry'

class Note < OpenStruct; end
class Notes < Array; end

notes = Notes.new
filename = ARGV[0]
xml = Nokogiri::XML(File.open(ARGV[0]))

xml.xpath("//note").each do |n|
  note = Note.new
  note.title = n.xpath('title').first.content
  note.content_xml = n.xpath('content').first.content
  note.content = Nokogiri::XML(note.content_xml).content

  note.created = DateTime.parse(n.xpath('created').first.content).strftime("%Y-%m-%d %H:%M %Z")
  note.updated = DateTime.parse(n.xpath('updated').first.content).strftime("%Y-%m-%d %H:%M %Z")
  note.tags = n.xpath('tag').map(&:content)

  notes << note
  text = n.elements[1].children.first.text
  doc = Nokogiri::HTML(text)

  md_filename = filename.gsub('.enex','.md')
  File.open(md_filename, 'w') do |file|
    file.write "# #{note.title}\n"
    file.write "Title: #{note.title}\n"
    file.write "Created: #{note.created}\n"
    file.write "Updated: #{note.updated}\n"
    file.write "\n\n\n"

    doc.xpath('//div[contains(@style, "-en-paragraph")]').each_with_index do |paragraph, i|
      next if i == 0

      paragraph.children.each do |child|
        if child.has_attribute?('href')
          file.write "[#{child.text}](#{child.attribute('href').text})\n"
        else
          text = child.text.delete_suffix('(')
          text = text.delete_prefix(')')
          file.write "#{text}\n"
        end
      end
    end
  end
end
