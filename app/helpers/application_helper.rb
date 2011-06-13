module ApplicationHelper
  def title
    base_title="Ray's micropost"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  
  def logo
    image_tag("logo.png",:alt=>"Ray's micropost",:class=>"round")
  end
end
