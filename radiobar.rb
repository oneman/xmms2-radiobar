#!/usr/bin/env ruby

# xmms2 radiobar will be a simple toolbar designed for the 
# simple needs of radio dj's that do not make sense in
# any other client, it is intended as a supplimentary client
# you would use other clients for playlist management
# controls: play/pause stop, single/cont  prev/next buttons
# flash play button when 30~ secs from stopping (colored buttons)
# show time remaining, show current track and next track ?
# voiceover button

require 'gtk2'
require "xmmsclient"
require 'xmmsclient_glib'

VERSION = 0.2
FLASH_TIME = 30

class Radiobar

 def initialize 
   @window = Gtk::Window.new
   @window.title = "radiobar"
   @window.border_width = 30
   @bar = Gtk::HBox.new(false, 0)
        
   @playpause_button = Gtk::Button.new("Play")
   @stop_button = Gtk::Button.new("Stop")
   @prev_button = Gtk::Button.new("Prev")
   @next_button = Gtk::Button.new("Next")
   @singlecont_button = Gtk::Button.new("Cont")
   @voice_button = Gtk::Button.new("Voice")

   @bar.pack_start(@playpause_button, true, true, 0)
   @bar.pack_start(@stop_button, true, true, 0)
   @bar.pack_start(@prev_button, true, true, 0)
   @bar.pack_start(@next_button, true, true, 0)
   @bar.pack_start(@singlecont_button, true, true, 0)
   @bar.pack_start(@voice_button, true, true, 0)

   @window.add(@bar)
   @window.signal_connect('delete_event') do
    Gtk.main_quit
    false
   end
   @window.show_all
   Gtk.main
 end 

end


radiobar = Radiobar.new




