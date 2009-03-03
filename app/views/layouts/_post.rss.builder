xm.item do
  #key = post.topic.posts.size == 1 ? I18n.t "site.layouts.post.topic_posted_by" : I18n.t "site.layouts.post.topic_replied_by"
  xm.title (I18n.t "site.layouts.post.topic_posted_by", :title => post.topic.title, :user => (h(post.user.login)), :date => (post.created_at.rfc822)).to_s
  xm.description post.body_html
  xm.pubDate post.created_at.rfc822
  xm.guid [request.host_with_port+ActionController::Base.relative_url_root.to_s, post.forum_id.to_s, post.topic_id.to_s, post.id.to_s].join(":"), "isPermaLink" => "false"
  xm.author "#{post.user.login}"
  xm.link topic_url(post.forum_id, post.topic_id)
end
