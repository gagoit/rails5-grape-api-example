module DataHelpers
  def clean_db
    User.destroy_all
  end
end