class AlterFeaturesAddLink < ActiveRecord::Migration[4.2]
  def up
    add_column(:features, :link_url, :string)
    add_column(:features, :link_title, :string)
  end

  def down
    remove_column(:features, :link_url)
    remove_column(:features, :link_title)
  end
end
