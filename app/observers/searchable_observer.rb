class SearchableObserver < ActiveRecord::Observer
  observe(*Islay::Engine.searches.models.to_a)

  def after_save(model)
    name = model.class.to_s.underscore.to_sym
    Search.update_entry(model, name)

    dependents = Islay::Engine.searches.assocs[name]

    if dependents
      models = dependents.map {|d| model.send(d)}.flatten
      models.each {|m| Search.update_entry(m)}
    end
  end
end

