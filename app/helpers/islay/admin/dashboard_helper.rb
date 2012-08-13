module Islay::Admin::DashboardHelper
  def primary_cells
    cells.select {|c| c[:col] == :primary}.map {|c| c[:name]}
  end

  def secondary_cells
    cells.select {|c| c[:col] == :secondary}.map {|c| c[:name]}
  end

  def cells
    @cells ||= Islay::Engine.extensions.entries.map {|k, e| e.config[:dashboard]}.compact.flatten
  end
end
