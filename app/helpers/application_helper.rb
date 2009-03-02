require 'md5'

module ApplicationHelper
  # convenient plugin point
  def head_extras
  end

  def submit_tag(value = "Save Changes"[], options={} )
    or_option = options.delete(:or)
    return super + "<span class='button_or'>"+"or"[]+" " + or_option + "</span>" if or_option
    super
  end

  def ajax_spinner_for(id, spinner="spinner.gif")
    "<img src='/images/#{spinner}' style='display:none; vertical-align:middle;' id='#{id.to_s}_spinner'> "
  end

  def avatar_for(user, size=32)
    image_tag "http://www.gravatar.com/avatar.php?gravatar_id=#{MD5.md5(user.email)}&rating=PG&size=#{size}", :size => "#{size}x#{size}", :class => 'photo'
  end

  def feed_icon_tag(title, url)
    (@feed_icons ||= []) << { :url => url, :title => title }
    link_to image_tag('feed-icon.png', :size => '14x14', :alt => "Subscribe to #{title}"), url
  end

  def search_posts_title
    returning(params[:q].blank? ? (I18n.t "site.general.recent_post").to_s : (I18n.t "site.general.searching_for").to_s + " '#{h params[:q]}'") do |title|
      title << " "+ (I18n.t "site.general.by_user").to_s + " " + h(User.find(params[:user_id]).display_name) if params[:user_id]
      title << " "+(I18n.t "site.general.in_forum").to_s + " " + h(Forum.find(params[:forum_id]).name) if params[:forum_id]
    end
  end

  def topic_title_link(topic, options)
    if topic.title =~ /^\[([^\]]{1,15})\]((\s+)\w+.*)/
      "<span class='flag'>#{$1}</span>" + 
      link_to(h($2.strip), topic_path(@forum, topic), options)
    else
      link_to(h(topic.title), topic_path(@forum, topic), options)
    end
  end

  def search_posts_path(rss = false)
    options = params[:q].blank? ? {} : {:q => params[:q]}
    prefix = rss ? 'formatted_' : ''
    options[:format] = 'rss' if rss
    [[:user, :user_id], [:forum, :forum_id]].each do |(route_key, param_key)|
      return send("#{prefix}#{route_key}_posts_path", options.update(param_key => params[param_key])) if params[param_key]
    end
    options[:q] ? search_all_posts_path(options) : send("#{prefix}all_posts_path", options)
  end

  # on windows and this isn't working like you expect?
  # check: http://beast.caboo.se/forums/1/topics/657
  # strftime on windows doesn't seem to support %e and you'll need to 
  # use the less cool %d in the strftime line below
  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
  
    case distance_in_minutes
      when 0..1           then (distance_in_minutes==0) ? (I18n.t "datetime.distance_in_words.less_than_x_minutes.zero").to_s : (I18n.t "datetime.distance_in_words.less_than_x_minutes.one").to_s 
      when 2..59          then (I18n.t "datetime.distance_in_words.less_than_x_minutes.other", :count => distance_in_minutes ).to_s
      when 60..90         then (I18n.t "datetime.distance_in_words.about_x_hours.one").to_s
      when 90..1440       then (I18n.t "datetime.distance_in_words.about_x_hours.other", :count => (distance_in_minutes.to_f / 60.0).round).to_s
      when 1440..2160     then (I18n.t "datetime.distance_in_words.x_days.one").to_s # 1 day to 1.5 days
      when 2160..2880     then (I18n.t "datetime.distance_in_words.x_days.other", :count => (distance_in_minutes.to_f / 1440.0).round).to_s # 1.5 days to 2 days
      else from_time.strftime((I18n.t "time.formats.datetime_format").to_s).gsub(/([AP]M)/) { |x| x.downcase }
    end
  end
  
  def pagination collection
    if collection.total_pages > 1
      "<p class='pages'>" + 'Pages'[:pages_title] + ": <strong>" + 
      will_paginate(collection, :inner_window => 10, :next_label => "next"[], :prev_label => "previous"[]) +
      "</strong></p>"
    end
  end
  
  def next_page collection
    unless collection.current_page == collection.total_pages or collection.total_pages == 0
      "<p style='float:right;'>" + link_to("Next page"[], { :page => collection.current_page.next }.merge(params.reject{|k,v| k=="page"})) + "</p>"
    end
  end
  
end
