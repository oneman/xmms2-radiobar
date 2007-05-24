#!/usr/bin/env ruby

# http://wiki.xmms2.xmms.se/index.php/Client:radiobar
# http://coconutfunworld.com/blog.php?auth=54&page=1&post=41

IPCPATH = "tcp://127.0.0.1:9667"
PLAYING_VOLUME = 74
VOICEOVER_VOLUME = 34


require 'gtk2'
require "xmmsclient"
require 'xmmsclient_glib'

CLIENT = "radiobar"
CLIENTVERSION = 1.1

class Radiobar

 attr_reader :single_cont

 def initialize(xc)
   
   @xc = xc
   @single_cont = "Cont"   

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
   connect_callbacks
   @playback_id = @xc.playback_current_id.wait.value
   @xc.playback_volume_set(:left, PLAYING_VOLUME)
   @xc.playback_volume_set(:right, PLAYING_VOLUME)
   @volume = PLAYING_VOLUME
   state @xc.playback_status.wait.value
   @xc.add_to_glib_mainloop
   @window.show_all
   Gtk.main
 end 
 
 def connect_callbacks
   @xc.broadcast_playback_current_id.notifier do |res|
    if @playback_id != res.value
      if @single_cont == "Single"
         @xc.playback_stop
      end 
    end
    @playback_id = res.value
   end

   @xc.broadcast_playback_status.notifier do |res|
    state(res.value)
   end

   @xc.broadcast_playback_volume_changed.notifier do |res|
    @volume = res.value[:left]
   end

 end

 def connect_buttons

    @playpause_button.signal_connect("clicked") do |w|
     unless @tid
      case w.label
      when "Play"
        @xc.playback_start
       when "Pause"
        @playpause_button.sensitive = false
	@tid= Gtk::timeout_add(10) { volume_down(0); true }
        @tid2 = Gtk::timeout_add(800) { 
                Gtk::timeout_remove(@tid); 
                Gtk::timeout_remove(@tid2); 
                @tid = nil;
                @xc.playback_pause
                w.label = "Resume" 
                @playpause_button.sensitive = true }
      when "Resume"
        @playpause_button.sensitive = false
        @xc.playback_start
	@tid = Gtk::timeout_add(10) { 
                   if @voice_button.label == "Over"
                     volume_up(VOICEOVER_VOLUME); 
                   else
                     volume_up
                   end 
                   true }
        @tid2 = Gtk::timeout_add(800) { 
                Gtk::timeout_remove(@tid); 
                Gtk::timeout_remove(@tid2);
                @tid = nil;
                w.label = "Pause" 
                @playpause_button.sensitive = true }
      end
     end
    end

    @stop_button.signal_connect("clicked") do |w|
      @xc.playback_stop
    end

    @prev_button.signal_connect("clicked") do |w|
       @xc.playlist_set_next_rel(-1)
       @xc.playback_tickle
    end

    @next_button.signal_connect("clicked") do |w|
       @xc.playlist_set_next_rel(1)
       @xc.playback_tickle
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
      unless @tid
       @voice_button.sensitive = false
       case w.label
       when "Voice"
	@tid= Gtk::timeout_add(10) { volume_down; true }
        @tid2 = Gtk::timeout_add(800) { 
                Gtk::timeout_remove(@tid); 
                Gtk::timeout_remove(@tid2); 
                @tid = nil;
                w.label = "Over"
                @voice_button.sensitive = true }
       when "Over"
	@tid = Gtk::timeout_add(10) { volume_up; true }
        @tid2 = Gtk::timeout_add(800) { 
                Gtk::timeout_remove(@tid); 
                Gtk::timeout_remove(@tid2);
                @tid = nil;
                w.label = "Voice" 
                @voice_button.sensitive = true }
       end
      end
    end

 end

 def volume_down(lowest=VOICEOVER_VOLUME)
       unless @volume < lowest + 1
        @xc.playback_volume_set(:left, @volume - 1)
        @xc.playback_volume_set(:right, @volume - 1)
        @volume = @volume - 1
       end
 end

 def volume_up(highest=PLAYING_VOLUME)
        unless @volume > highest - 1
         @xc.playback_volume_set(:left, @volume + 1)
         @xc.playback_volume_set(:right, @volume + 1)
         @volume = @volume + 1
        end
 end


 def state(value)
  case value
  when 0 
    stopped
  when 1
    playing
  when 2
    paused
  end
 end

 def stopped
    @playpause_button.label = "Play"
 end

 def playing
    @playpause_button.label = "Pause"
 end

 def paused
    @playpause_button.label = "Resume"
 end


end

xc = Xmms::Client.new(CLIENT)
xc.connect(IPCPATH)
radiobar = Radiobar.new(xc)


