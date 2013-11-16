#!/usr/bin/env ruby

require 'tmpdir'

def has_program?(program)
  ENV['PATH'].split(File::PATH_SEPARATOR).any? do |directory|
    File.executable?(File.join(directory, program.to_s))
  end
end

raise unless has_program?('youtube-dl')
raise unless has_program?('ffmpeg')

def youtube_dl(id)
  command = ['youtube-dl']
  command += ['-o', 'youtube']
  command << id

  system(*command)
end

def ffmpeg
  Dir.mkdir('ffmpeg')

  command = ['ffmpeg']
  command += ['-i', 'youtube']
  command += ['-r', '1']
  command += ['-filter:v', 'crop=in_w:1/2*in_h:0:(in_h-out_h)/2.5']
  command << '-an'
  command += ['-f', 'image2']
  command << 'ffmpeg/%05d'

  system(*command)
end

def imagemagick
  entries = Dir.entries('ffmpeg').reverse! - ['.', '..']

  command = ['convert']

  entries.each_with_index do |entry, index|
    command << "ffmpeg/#{entry}"
    command += ['-page', '+0' + "+#{(index * 171) + 171}"]
  end

  command += ['-background', 'transparent']
  command += ['-layers', 'merge']
  command << 'imagemagick.png'

  system(*command)
end

Dir.mktmpdir do |dir|
  Dir.chdir dir do
    youtube_dl(ARGV.first)
    ffmpeg()
    imagemagick()
  end
  FileUtils.copy "#{dir}/imagemagick.png", 'imagemagick.png'
end
