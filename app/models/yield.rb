class Yield < ActiveRecord::Base

  include Overrides

  extend DataAccess # provides all_limited

  extend SimpleSearch
  SEARCH_INCLUDES = %w{ citation specie site treatment cultivar }
  SEARCH_FIELDS = %w{ species.genus cultivars.name yields.mean yields.n yields.stat yields.statname citations.author sites.sitename treatments.name }

  belongs_to :citation
  belongs_to :site
  belongs_to :specie
  belongs_to :treatment
  belongs_to :cultivar
  belongs_to :user
  belongs_to :ebi_method, :class_name => 'Methods', :foreign_key => 'method_id'

  validates_presence_of     :mean
  validates_numericality_of :mean
  validates_presence_of     :statname, :if => Proc.new { |y| !y.stat.blank? }

  scope :all_order, includes(:specie).order('species.genus, species.species')
  scope :sorted_order, lambda { |order| order(order).includes(SEARCH_INCLUDES) }
  scope :search, lambda { |search| where(simple_search(search)) }
  scope :citation, lambda { |citation|
    if citation.nil?
      {}
    else
      where("citation_id = ?", citation)
    end
  }

  comma do
    id
    citation_id
    site_id
    specie_id
    treatment_id
    cultivar_id
    date
    dateloc
    statname
    stat
    mean
    n
    notes
    created_at
    updated_at
    user_id
    checked
    access_level
  end

  comma :test_pat do
    checked
  end

  comma :show_yields do |f|
     site :city_state
     specie :scientificname
     citation :author_year
     cultivar :sn_name
     treatment :name_definition

  end

  def to_s
    id
  end

  #Columns we search when referenced from another model
  #Fields present in 'select_default'
  def self.search_columns
    return ["yields.id"]
  end

end
