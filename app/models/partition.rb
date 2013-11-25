class Partition < ActiveRecord::Base
  
  belongs_to :model
  belongs_to :inventory_pool
  belongs_to :group
  
  validates_presence_of :model, :inventory_pool, :group, :quantity
  validates_numericality_of :quantity, :only_integer => true, :greater_than => 0
  validates_uniqueness_of :group_id, :scope => [:model_id, :inventory_pool_id]

end
