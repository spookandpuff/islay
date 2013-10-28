# Treat the Islay engine itself as an extension.
Islay::Engine.extensions.register do |e|
  e.namespace :islay

  e.add_item_entry('Asset', :asset, 'picture')
  e.add_item_entry('User', :user, 'user')

  e.nav_section(:dashboard, 1) do |s|
    s.root('Dashboard', :dashboard, 'home', :root => true)
  end

  e.nav_section(:reports, 1) do |s|
    s.root('Reports', :reports, 'bar-chart')
    s.sub_nav('Overview', :reports, :root => true)
  end

  e.nav_section(:page_contents, 4) do |s|
    s.root('Page Contents', :pages, 'file-text')
  end

  e.nav_section(:asset_library, 4) do |s|
    s.root('Asset Library', :asset_library, 'picture')
    s.sub_nav('Overview', :asset_library, :root => true)
    s.sub_nav('Collections', :asset_groups)
    s.sub_nav('Assets', :assets)
    s.sub_nav('Tags', :asset_tags)
    s.sub_nav('Processing', :asset_processes)
  end

  e.nav_section(:config, 9) do |s|
    s.root('Configuration', :users, 'cog')
  end

  e.nav_section(:add_item, 10) do |s|
    s.root("Add Item", :add_item, 'plus-sign', :id => 'islay-add-item', :title => 'Add a New Item')
  end
end
