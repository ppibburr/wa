require 'sinatra'
set :public_folder, "./"
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

require 'reverse_markdown'

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
    <div class=flex-none>
      <input type=file name=attachment id=image-upload multiple></input> 
      <button class=button>Delete</button>
      <button id=select class=button style='float:right;'>Select</button>
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
  send_file("../#{path}")
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
    <div id=nav class=screen>
      <div style='height:100px;'></div>
      #{[:posts, :pages, :media, :settings].map do |q| "<div id=nav_#{q} class='nav_item flex'><div>#{q}</div><img src='/images/images.png' width=48px></img></div>" end.join}
      <div style='height:100px;'></div>
    </div>
  """
end

def pages
  """
  <div id=pages class='screen hidden'>
  
  </div>
  """
end

def post_item p,i
  """
    <div class='post-item nav_item' data-index=#{i} data-post=true>
      #{File.basename(p[:path].to_s)}<br>
      #{p[:title]}
    </div>
  """
end

def posts a
  i = -1
  """
    <div class='screen hidden scroll' id=posts>
      <div class=hbar-item id=new_post style='position:absolute;top:0;left:calc(50vw-4em);'></div>
      #{a.map do |p| post_item(p,i+=1) end.join}
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
        <input class=hflex type=text id=keys placeholder=Tags...></input>
        <input class=hflex type=text id=icon placeholder=Icon...></input>
        <input class=hflex type=text id=banner placeholder=Banner...></input>        
      </div>
    </div>
    <button id=insert-image>Img</button>
    <trix-editor id=editor></trix-editor>
    <div class=hbar-item id=post-bar style='position:absolute;top:0;left:calc(30vw);'>
    <img src=/images/publish.png style='max-width:4em;' class=hbar-item id=publish></img> 
    <img src=/images/view.png style='max-width:4em;;' class=hbar-item id=preview></img> 
    <img src=/images/remove.png style='max-width:4em;margin-right:0em;' class=hbar-item id=delete> </img>   
    </div>
  </div>
  <div id=image-modal class='modal hidden'>
    <input type=text placeholder=url id=insert-image-url class='field hbar-item'></input>
    <img id=from-gallery class=hbar-item src=/images/images.png></img><br>
    width: <input type=text width=40px></input><br>
    height: <input type=text width=40px></input><br>
    <button id=insert class=button style='width:100%;'>insert</button>
  </div>
  <iframe scrolling=no frameborder=0 style='display:none;position:absolute;top: 0;z-index:90000;min-width:100vw;min-height:100vh;overflow:hidden;' id=_preview>
  </iframe>
  </div>
  """
end

get "/" do
  """
  <div>
    <input type=text placeholder='url'></input><img src=/images/images.png></img>
  </div>
  """
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
  <div id=main class=screen>
    <div id=menu>
      <div id=home class=hbar-item></div>
      <div id=back class=hbar-item style='float:right;'></div>
    </div>
  """+
  nav()+
  images()+
  pages()+
  posts([])+
  site_settings()+
  editor()+
  script('/js/onload.js')+  
  """
  </div>
  </div>
  """
end


get "/css/hilite.css" do
  Rouge::Themes::Github.render(:scope => '.highlight')
end

get "/admin/new/post" do
  link('/css/hilite.css')+
  link('/css/style.css')+
  script("/js/trix/trix.js")+
  link("/css/trix.css")+
  script('/js/editor.js')+
  open('index.html').read+
  script('/js/onload.js')+
  images
end

require 'json'
post "/admin/images/select" do
  params = request.body.read
  session[:selected_image] = JSON.parse(params)['file'].gsub(/^.*\:\/\/.*?\/blogs\/katie\//,'')
end

get "/admin/images/selected" do
  {file: session[:selected_image]}.to_json
end

get "/admin/preview" do
  redirect session[:preview]
end

get "/admin/edit/post/:index" do
  idx = params[:index].to_i
  session[:posts][idx].to_json
end
require 'kramdown'


get "/admin/list/posts" do
  a = Dir.glob("../_posts/*.m*d*").map do |f| 
    fm = /^\-\-\-\n(.*?)\n\-\-\-\n/m
    raw=open(f).read
    raw=~fm
    yml=$1
    md=raw.gsub(fm,'')
    obj = YAML.load(yml)
    obj[:path] = f
    obj[:html] = Kramdown::Document.new(md).to_html.gsub("<code><code>","<code>")
    obj
  end
  
  session[:posts] = a;
  
  ({html: posts(a)}).to_json
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

