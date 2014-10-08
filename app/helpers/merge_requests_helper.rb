module MergeRequestsHelper
  def patches
    @patches ||= @mr.patches
  end

  def patch
    @patch ||= patches.last
  end
end
