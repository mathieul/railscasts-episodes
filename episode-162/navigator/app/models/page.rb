class Page < CouchRest::ExtendedDocument
  include CouchRest::Validation
  
  UNKNOWN_ID = '__unknown'.freeze
  
  attr_reader :parent

  use_database DB_SERVER.default_database

  property :name,     :type => String
  property :content,  :type => String
  property :path,     :type => Array, :default => []
  timestamps!

  validates_present :name, :content

  create_callback :before, :set_parent_and_fix_path

  # roots mapped view is the subset of pages that don't have a parent
  view_by :roots,
    :map =>
      "function (doc) {
        if (doc.path && doc.path.length === 1) {
          emit(doc, null);
        }
      }"

  # children mapped view has the following format:
  # key:    [page_id, children_path]
  # value:  children_doc
  view_by :children,
    :map =>
      "function(doc) {
        if (doc.path) {
          emit([doc.path.slice(-2,-1)[0], doc.path], doc) 
        }
      }"

  view_by :path
  view_by :name

  class << self
    def root
      Page.by_roots
    end
  end

  alias :to_param :id

  def parent_id
    return @parent.id if @parent
    return @parent = nil if path.length < 2
    parents = Page.by_path :startkey => path[0...-1], :limit => 1
    return @parent = nil if parents.empty?
    @parent = parents[0]
    @parent.id
  end

  def parent_id=(id)
    parent = Page.get(id) if id
    self['path'] = [id_or_set_id]
    if parent
      self['path'].unshift(*parent.path)
      @parent = parent
    else
      @parent = nil
    end
    @parent ? @parent.id : nil
  end

  def children
    Page.by_children :startkey => [id], :endkey => [id, {}]
  end

  def ancestors
    path[0...-1].reverse.map { |id| Page.get(id) }
  end

  protected
  def id_or_set_id
    unless self['_id']
      new_id = name.parameterize.underscore[0..10] rescue UNKNOWN_ID
      self['_id'] = new_id
    end
    self['_id']
  end

  def set_parent_and_fix_path
    pid = self.delete('parent_id')
    self.parent_id = pid unless @parent
  end
end
