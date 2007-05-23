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

IPCPATH = "tcp://127.0.0.1:9667"
FLASH_TIME = 30

CLIENT = "radiobar"

class Radiobar

 attr_reader :single_cont

 def initialize(xc)
   
   @xc = xc
   @single_cont = "single"   

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
   connect_buttons
   @window.show_all
   Gtk.main
 end 

 def connect_buttons

    @playpause_button.signal_connect("clicked") do |w|
      @xc.playback_start
    end

    @stop_button.signal_connect("clicked") do |w|
      @xc.playback_stop
    end

    @prev_button.signal_connect("clicked") do |w|
      `xmms2 prev`
    end

    @next_button.signal_connect("clicked") do |w|
      `xmms2 next`
    end

    @singlecont_button.signal_connect("clicked") do |w|
      case w.label
      when "Single"
        w.label = "Cont"
        @single_cont = "Cont"
      when "Cont"
        w.label = "Single"
        @single_cont = "Single"
      end
    end

    @voice_button.signal_connect("clicked") do |w|
      case w.label
      when "Voice"
        w.label = "Over"
      when "Over"
        w.label = "Voice"

      end
    end
 

 end


end

xc = Xmms::Client.new(CLIENT)
xc.connect(IPCPATH)
xc.add_to_glib_mainloop
radiobar = Radiobar.new(xc)




