class SearchableObserver < ActiveRecord::Observer
  observe(*Islay::Engine.searches.models.to_a)

  def after_save(model)
    name = model.class.to_s.underscore.to_sym
    update_entry(model, name)

    dependents = Islay::Engine.searches.assocs[name]

    if dependents
      models = dependents.map {|d| model.send(d)}.flatten
      models.each {|m| update_entry(m)}
    end
  end

  private

  def update_entry(model, name = nil)
    name ||= model.class.to_s.underscore.to_sym
    blk = Islay::Engine.searches.updates[name]

    if blk
      terms = blk.call(model).reject{|k, v| k.empty?}.map do |term, weight|
        "setweight(to_tsvector('pg_catalog.english', '#{term}'), '#{weight}')"
      end
      update = "UPDATE #{model.class.table_name} SET terms = (#{terms.join(' || ')}) WHERE id = #{model.id}"
      ActiveRecord::Base.connection.execute(update)
    end
  end
end

