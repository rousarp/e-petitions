# == Schema Information
#
# Table name: petitions
#
#  id                   :integer(4)      not null, primary key
#  title                :string(255)     not null
#  description          :text
#  response             :text
#  state                :string(10)      default("pending"), not null
#  open_at              :datetime
#  department_id        :integer(4)      not null
#  creator_signature_id :integer(4)      not null
#  created_at           :datetime
#  updated_at           :datetime
#  creator_id           :integer(4)
#  rejection_text       :text
#  closed_at            :datetime
#  signature_count      :integer(4)      default(0)
#  response_required    :boolean(1)      default(FALSE)
#  internal_response    :text
#  rejection_code       :string(50)
#  notified_by_email    :boolean(1)      default(FALSE)
#  duration             :string(2)       default("12")
#  email_requested_at   :datetime
#

class Petition < ActiveRecord::Base
  include State

  attr_accessible :title, :description, :duration, :department_id, :creator_signature_attributes
  after_create :set_petition_on_creator_signature

  searchable do
    text :title
    text :description
    text :creator_name do
      creator_signature.name
    end
    text :department_name do
      department.name
    end
    string :title
    integer :signature_count
    time :closed_at, :trie => true
    time :created_at, :trie => true
    string :state
  end

  # = Relationships =
  belongs_to :department
  belongs_to :creator_signature, :class_name => 'Signature'
  accepts_nested_attributes_for :creator_signature
  has_many :signatures
  has_many :department_assignments

  # = Validations =
  validates_presence_of :response, :if => :email_signees, :message => "must be completed when email signees is checked"
  validates_presence_of :open_at, :closed_at, :if => :open?
  validates_presence_of :rejection_code, :if => :rejected?
  # Note: we only validate creator_signature on create since if we always load creator_signature on validation then
  # when we save a petition, the after_update on the creator_signature gets fired. An overhead that is unecesssary.
  validates_presence_of :creator_signature, :message => "%{attribute} must be completed", :on => :create
  validates_presence_of :title, :description, :duration, :department, :message => "%{attribute} must be completed"
  validates_inclusion_of :state, :in => STATES, :message => "'%{value}' not recognised"
  validates_length_of :title, :maximum => 150, :unless => 'title.blank?', :message => 'Title is too long.'
  validates_length_of :description, :maximum => 1000, :unless => 'description.blank?', :message => 'Description is too long.'

  attr_accessor :email_signees

  # = Finders =
  scope :threshold, lambda {{
        :conditions => ['signature_count >= ? or response_required = ?',
                        SystemSetting.value_of_key(SystemSetting::THRESHOLD_SIGNATURE_COUNT).to_i, true] }}
  scope :for_state, lambda { |state|
    if CLOSED_STATE.casecmp(state) == 0
      {:conditions => ['state = ? and closed_at < ?', OPEN_STATE, Time.zone.now]}
    elsif OPEN_STATE.casecmp(state) == 0
      {:conditions => ['state = ? and closed_at >= ?', OPEN_STATE, Time.zone.now]}
    else
      {:conditions => ['state = ?', state]}
    end
  }
  scope :for_departments, lambda {|departments| {:conditions => ['department_id in (?)', departments.map(&:id)]}}
  scope :visible, :conditions => ['state in (?)', VISIBLE_STATES]
  scope :moderated, :conditions => ['state in (?)', MODERATED_STATES]
  scope :trending, lambda { |number_of_days|
                    joins(:signatures).
                    where("signatures.state" => "validated").
                    where("signatures.updated_at > ?", number_of_days.day.ago).
                    order("count('signatures.id') DESC").
                    group('petitions.id').
                    limit(10)
                  }
  scope :last_hour_trending, joins(:signatures).
                             select("petitions.id as id, count('signatures.id') as signatures_in_last_hour").
                             where("signatures.state" => "validated").
                             where("signatures.updated_at > ?", 1.hour.ago).
                             order("signatures_in_last_hour DESC").
                             group('petitions.id').
                             limit(12)

  def self.update_all_signature_counts
    Petition.visible.each do |petition|
      petition_current_count = petition.count_validated_signatures
      if petition_current_count != petition.signature_count
        petition.update_attribute(:signature_count, petition_current_count)
      end
    end
  end

  def self.counts_by_state
    counts_by_state = {}
    states = State::STATES + [CLOSED_STATE]
    states.each do |key_name|
      counts_by_state[key_name.to_sym] = for_state(key_name.to_s).count
    end
    counts_by_state
  end

  def reassign!(new_department)
    self.department = new_department
    save!
    department_assignments.create!(:department => new_department, :assigned_on => Time.now)
  end

  def count_validated_signatures
    signatures.validated.count
  end

  def need_emailing
    signatures.need_emailing(email_requested_at)
  end

  def awaiting_moderation?
    self.state == VALIDATED_STATE
  end

  def open?
    self.state == OPEN_STATE
  end

  def can_be_signed?
    self.state == OPEN_STATE and self.closed_at > Time.zone.now
  end

  def rejected?
    self.state == REJECTED_STATE
  end

  def hidden?
    self.state == HIDDEN_STATE
  end

  def closed?
    self.state == OPEN_STATE && self.closed_at <= Time.zone.now
  end

  def state_label
    if (self.closed?)
      CLOSED_STATE
    else
      self.state
    end
  end

  def rejection_reason
    RejectionReason.find_by_code(self.rejection_code).title
  end

  def rejection_description
    RejectionReason.find_by_code(self.rejection_code).description
  end

  def editable_by?(user)
    return true if user.is_a_threshold? || user.is_a_sysadmin?
    return true if user.departments.include?(department)
    return false
  end

  def response_editable_by?(user)
    return true if user.is_a_threshold? || user.is_a_sysadmin?
    return false
  end

  # need this callback since the relationship is circular
  def set_petition_on_creator_signature
    self.creator_signature.update_attribute(:petition_id, self.id)
  end

  def signature_counts_by_postal_district
    Hash.new(0).tap do |counts|
      signatures.validated.find_each do |signature|
        counts[signature.postal_district] += 1 if signature.postal_district.present?
      end
    end
  end
end
