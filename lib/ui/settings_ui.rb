module SettingsUI
  def show_settings
    window do
      extend SettingsUI

      background black
      get_auth
      stack(:margin => [4,4,4+gutter,4]) do
        background gray(0.2), :curve => 10
        border gray(0.6), :curve => 10
        tagline "Settings", :stroke => white
        ignore_settings
        filter_settings
        color_settings
        button("Save") do
          @config.save
          owner.app { reload! }
        end
      end
    end
  end

private
  def ignore_settings
    stack(:margin => [8]*4) do
      para 'Ignore: ', :stroke => white
      flow do
        list_box(:items => @twit.friends.sort.map{|f| f.name}, :margin_left => 10) do |friend_name|
          @config.ignores << friend_name.text
          @ignores.text = @config.ignores.join(", ")
        end
        button("clear") { @config.ignores = []; @ignores.text = "" }
      end
      @ignores = para(@config.ignores.join(", "), :stroke => white, :margin_left => 10)
    end
  end

  def filter_settings
    stack(:margin => [8]*4) do
      para 'Filters: ', :stroke => white
      flow do
        filter_input = edit_line
        button("nope") do
          @config.filters << filter_input.text
          @filters.text = @config.filters.join(", ")
          filter_input.text = ""
        end
        button("clear") { @config.filters = []; @filters.text = "" }
      end
      @filters = para(@config.filters.join(", "), :stroke => white, :margin_left => 10)
    end
  end

  def color_settings
    stack(:margin => [8]*4) do
      para 'Colors! ', :stroke => white
      demo = stack do
        background black
        demo_tweet
      end
      flow do
        [:background, :border, :title, :body].each do |part|
          button(part.to_s)do
            @config.colors[part] = ask_color(part.to_s.capitalize).to_s
            demo.clear { background black; demo_tweet }
          end
        end
        button("Reset Colors"){ @config.colors = nil; demo.clear {background black; demo_tweet} }
      end
    end
  end

  def demo_tweet
    flow :margin => [2]*4 do
      background @config.colors[:background], :curve => 10
      border @config.colors[:border], :curve => 10, :strokewidth => 2
      stack :width => 50, :margin => [6,6,2,6] do
        image "http://s3.amazonaws.com/twitter_production/profile_images/57493217/angry-bee-crop_normal.jpg"
      end
      stack :width => -77 do
        flow do
          para('Gutter', :stroke => @config.colors[:title], :margin => [10,5,5,0], :font => 'Coolvetica')
          inscription('at 10:55p', :stroke => @config.colors[:title], :margin => [10,7,0,0])
        end
        inscription('I like to go get lots of cheese and eat it publically.  This cheese does much, you know',
          :stroke => @config.colors[:body], :margin => [10,0,0,4], :leading => 0)
      end
    end
  end


  def get_auth
    @config = GutterConfig.get_conf
    @user = @config.user
    @twit = TwitterAccount.new(
      :user => @config.user, :password => @config.password)
  end
end #SettingsUI
