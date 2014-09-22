class Tree < ActiveRecord::Base
  belongs_to :user
  validates :virtual_right_count, :presence => true
  validates :virtual_left_count, :presence => true
  validates :total_left, :presence => true
  validates :total_right, :presence => true
  validates :total_cheque_count, :presence => true
  validates :level, :presence => true
  validates :user_id,:presence=>true
  validates :parent ,:presence=>true
  before_create  :add_parent
  after_create :update_tree
  def add_parent
    self.id=self.user_id
    parent_d=Tree.find_by(:id=>self.parent)

    if parent_d.left==0
    self.level=parent_d.level+1
    elsif parent_d.right==0
    self.level=parent_d.level+1
    else
      puts "detect left parent #{parent_d.parent} left #{parent_d.left}"
      dl= detect_parent(parent_d.left)
      puts "final left #{parent_d.left}   #{parent_d.left ==0}"

      puts "detect right parent #{parent_d.parent} right #{parent_d.right}"
      dr=  detect_parent(parent_d.right)
      puts "final right #{parent_d.right}    #{parent_d.right ==0}"

      if dr.level>dl.level
      self.parent=dl.id
      self.level=dl.level+1
      else
      self.parent=dr.id
      self.level=dr.level+1
      end
    end
  end

  def detect_parent(parent)
    parent_de=Tree.find_by(:id=>parent)

    puts "parent #{parent_de.parent}  left  #{parent_de.left}  right  #{parent_de.right}"

    if parent_de.left ==0
      puts "if left parent #{parent_de.parent}  left  #{parent_de.left}   #{parent_de.left==0}"
    return parent_de
    elsif parent_de.right ==0
      puts "if right parent #{parent_de.parent}  left  #{parent_de.right}   #{parent_de.right==0}"
    return parent_de
    else
      puts "parent #{parent_de.parent}  left  #{parent_de.left}  #{parent_de.left==0}"
      parent_dl=detect_parent(parent_de.left)

      puts "parent #{parent_de.parent}  right   #{parent_de.right}  #{parent_de.right ==0}"
      parent_dr=detect_parent(parent_de.right)
    end

    if parent_dr.level>parent_dl.level
    return parent_dl
    else
    return parent_dr
    end
  end

  def update_tree
    super_parent_id=self.parent
    chiled_id=self.id
    sp=Tree.find_by(:id=>super_parent_id)
    if sp.left==0
    sp.left=chiled_id
    else
    sp.right=chiled_id
    end
    sp.save()
    #update
    while super_parent_id!=0
      p=Tree.find_by(:id=>super_parent_id)
      if chiled_id==p.left
        p.total_left+=1
        p.virtual_left_count+=1
        cheque_test_creation(p)
      else
      p.total_right+=1
        p.virtual_right_count+=1
        cheque_test_creation(p)
      end
      # @p.save()
      chiled_id= super_parent_id
      super_parent_id=p.parent
    end
  end

  def  cheque_test_creation(parent)
    calculations=Calculation.first
    node_no=calculations.blanced_nodes_number
    if parent.virtual_left_count>=node_no && parent.virtual_right_count>=node_no
      parent.virtual_left_count-=node_no
      parent.virtual_right_count-=node_no
      parent.total_cheque_count+=node_no
      parent.save()
      Cheque.create(:user_id=>parent.id,:date=>Time.now,:value=>calculations.user_profit)
    else
    parent.save()
    end

  end
end

