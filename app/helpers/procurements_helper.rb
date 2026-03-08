module ProcurementsHelper
  def procurement_starred?(procurement)
    procurement.starred_by?(current_user)
  end
end
