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
  
  def pagination collection
    if collection.total_pages > 1
      "<p class='pages'>" + (I18n.t "site.helper.application.pages_title").to_s + ": <strong>" + 
      will_paginate(collection, :inner_window => 10, :next_label => (I18n.t "site.helper.application.next").to_s, :prev_label => (I18n.t "site.helper.application.previous").to_s) +
      "</strong></p>"
    end
  end
  
  def next_page collection
    unless collection.current_page == collection.total_pages or collection.total_pages == 0
      "<p style='float:right;'>" + link_to((I18n.t "site.helper.application.next_page").to_s, { :page => collection.current_page.next }.merge(params.reject{|k,v| k=="page"})) + "</p>"
    end
  end
  
end
