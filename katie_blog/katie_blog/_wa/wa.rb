require 'sinatra'
set :public_folder, "./"
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

require 'reverse_markdown'
require 'base64'


class Site
  attr_accessor :collections
  def collections
    @collections ||= {}
  end
  
  def obj_from_entry type, idx
    f = collections[type][idx]
    fm = /^\-\-\-\n(.*?)\n\-\-\-.*?\n/m
    p [:file,f]
    raw=open(f).read
    raw=~fm
    p [raw, $1]
    yml=$1
    md=raw.gsub(fm,'')
    obj = YAML.load(yml)
    obj[:path] = f
    obj[:html] = hack(Kramdown::Document.new(md).to_html)
    obj  
  end
end


def site
  $site ||= Site.new
end

get "/images/:image" do 
  send_file "../images/#{params[:image]}"
end

class ReverseMarkdown::Converters::Code
  def convert(node, state = {})
    if node.text =~ /\n/
      lang = ''
      buff = node.text.split("\n")
      if buff[0] =~ /^\#(.*)/
        lang = $1
        buff.shift
      end

      """\n\n```#{lang}
#{buff.join("\n")}
```
"""
    else
      "`#{node.text}`"
    end
  end
end

class H2M
  def self.convert html
    html = html.gsub(/\<figure .*?\>/,'').gsub(/\<figcaption .*?\>/,'').gsub(/\<\/figure\>/,'').gsub(/\<\/figcaption\>/,'')
  
    md = ReverseMarkdown.convert(html)
  end
end

def images()
  """
    <div class='screen hidden' id=media>
   
    <div class='flex scroll content' id=gallery>
      #{Dir.glob("../images/*.*").map do |path|
        if File.file?(path)
          "<div class=item><img src='/images/#{File.basename(path)}'></image></div>"
        end
      end.join}
    </div>
    </div>
  """
end

set :protection, :except => :path_traversal
enable :sessions
get "/blogs/katie/*" do
  path = "/_site/#{params[:splat].join}"
  if File.exist?("..#{path}") and !File.directory?("..#{path}")
  else
    path = File.join(path, "index.html")
    p :PATH,path
  end
  send_file(File.expand_path("../#{path}"))
end


def script path
  path = File.join(path)
  "<script src=#{path}></script>"
end

def link path
  path = File.join(path)
  "<link type='text/css' rel=stylesheet href=#{path}></link>"
end

def nav
  """
    <div id=nav class='screen hidden'>
      <div style='height:100px;'></div>
      #{[:posts, :pages, :media, :settings].map do |q| 
        "<div id=nav_#{q} class='nav_item action-list-item flex' data-dest=#{q}><div>#{q}</div><img src='/images/#{q}.svg' width=48px></img></div>" 
      end.join}
      <div style='height:100px;'></div>
    </div>
  """
end

def front_matter()
  """
    <div id=front-matter class='screen hidden'>        
    </div>
  """
end

def collection_item type, q, i
  """
    <div class='collection-item action-list-item' data-index=#{i} data-#{type.to_s.gsub(/s$/,'')}=true>
     "+ #{File.basename(q[:path].to_s)}<br>
      "#{q['title']}
    </div>
  """
end

def collections type
  i = -1
  p site.collections
  """
    <div class='screen hidden scroll' id=#{type}>
      #{site.collections[type].map do |t,q| collection_item(type, site.obj_from_entry(type,i+=1),i) end.join}
    </div>
  """
end

def site_settings
  """
  <div id=settings class='screen hidden'>
  
  </div>
  """
end

def editor
"""
    <div id=editor class='screen hidden'>
    <div class='flex-none'>
      <div class=row>
        <input class=hflex type=text id=title placeholder=Post name...></input> 
      </div>
    </div>
    <button id=insert-image data-dest=image-modal class=nav_item>Img</button>
    <trix-editor id=editor></trix-editor>
  </div>
  <iframe scrolling=no frameborder=0 style='display:none;position:absolute;top: 0;z-index:90000;min-width:100vw;min-height:100vh;overflow:hidden;' id=_preview>
  </iframe>
  </div>
  """
end

def url2path url
  url ? url.gsub(/^.*\:\/\/.*?\//,'') : ""
end

get "/admin" do
  redirect "/admin/"
end


post '/preview' do
  parser_options = {
    autolink: true,
    tables: true,
    fenced_code_blocks: true,
    disable_indented_code_blocks: false,
    underline: true
  }
  class HTML < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet 
  end

  markdown = Redcarpet::Markdown.new(HTML,  parser_options)
  "<style>#{css = Rouge::Themes::Github.render(:scope => '.highlight')}</style>"+markdown.render(`ruby ../h2m.rb`)
end

set :static_cache_control, [:public, max_age: 0]

get "/" do
  redirect "/_site/index.html"
end

get "/admin/login" do
  "Login"
  session[:user] = :admin
  "Logged in: admin<br><a href=/admin/> continue </a>"
end

require 'erb'

get "/admin/" do
cache_control :public, max_age: 0
  if !session[:user]
    redirect '/admin/login'
  end
  "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"+
  link('/css/style.css')+
  link('/css/hilite.css')+
  link('/css/style.css')+
  script("/js/trix/trix.js")+
  link("/css/trix.css")+
  script('/js/editor.js')+
  """
    #{open('action_bar.html').read}
  """+
  nav()+
  images()+
  ERB.new(open('image_modal.html').read).result+
  collections(:pages)+
  collections(:posts)+
  collections(:drafts)+
  site_settings()+
  front_matter()+  
  editor()+
  script('/js/lib_.js')+  
  script('/js/nav.js')+    
  script('/js/onload.js')+  
  """
  </div>
  </div>
  """
end


get "/admin/add/posts/" do
  File.open(path="#{Time.now}.md", "w") do |f|
    f.puts """---
title: 'bob'
date: #{Time.now.to_s.split(" ")[0..1].join(" ")}
categories: []
tags: []    
---
    """
  end
  
  site.collections[:posts][l=site.collections[:posts].length] = path
  
  {index: l}.to_json
end

get "/css/hilite.css" do
  Rouge::Themes::Github.render(:scope => '.highlight')
end

require 'json'


get "/admin/preview" do
  redirect session[:preview]
end

get "/admin/edit/:type/:index" do
  type = params[:type].to_sym
  idx = params[:index].to_i
  site.obj_from_entry(type,idx).to_json
end
require 'kramdown'


def hack str
  while str =~ /\<code\>(.*?)<\/code\>/m
    v = $1
    if v =~ /\n/
      tag = 'cb'
    else
      tag = 'edoc'
    end
    
    str = str.gsub("<code>#{v}</code>", "<#{tag}>#{v}</#{tag}>")
  end
  str = str.gsub("<edoc>","<code>").gsub("</edoc>","</code>")
end

def gen_collection type, ext="*.m*d*"
  Dir.glob("../_#{type}/#{ext}").each do |f| 
    if !site.collections[type]
      site.collections[type] = a = []
    end
    unless (col = site.collections[type]).index(f)
      col << f
    end
  end
end

get "/admin/front-matter/:type/:idx" do
  type = params[:type].to_sym
  
  obj = site.obj_from_entry type,params[:idx].to_i

  {html: obj.map do |k,v|
    next "" if [:title, :path, :html].index k.to_sym
    "<div class=row><div class=col3rd>#{k}</div><input type=text class=hflex value=#{v}></input></div>"
  end.join("")}.to_json
end

get "/admin/list/:type" do
  type = params[:type].to_sym
  gen_collection type
  ({html: collections(type)}).to_json
end

post "/admin/delete/" do

  params = JSON.parse request.body.read
  
  params
 
 
  path = "../"+url2path(params['file']);
  
  path = File.expand_path(path)
  
  `rm #{path}`
  
  ""
end

post "/admin/preview" do

  params = JSON.parse request.body.read
  
  params

  session[:preview] = "/blogs/katie/2017/preview"
  
  File.open('../_drafts/preview.markdown','w') do |f|
    f.puts """---
banner: #{nil}
title:  \"#{params['title']}\"
---    
#{H2M.convert params['body']}

"""
  end
  
  `cd .. && jekyll build --drafts`
  ""
end


post "/admin/upload/image" do
  params = request.body.read
  params = JSON.parse(params)
  
  data = params['data']
  filename = params['filename']
 
  ## Decode the image
  data_index = data.index('base64') + 7
  filedata = data.slice(data_index, data.length)
  decoded_image = Base64.decode64(filedata)
   
  ## Write the file to the system
  file = File.new("../images/#{filename}", "w+")
  file.write(decoded_image) 
  file.close 
  
  "OK: 200"
end

get "/images" do
  ({html: images}).to_json
end

[:posts, :drafts, :pages].each do |t| 
  File.exists?('../_'+t.to_s) ? nil : `mkdir ../_#{t}`
  gen_collection t 
  if !site.collections[t]
    site.collections[t] = []
  end
end
