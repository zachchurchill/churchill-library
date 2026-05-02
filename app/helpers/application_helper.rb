module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title = "")
    base_title = "Churchill Library"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def books_filter_path(filters, page: nil)
    query = filters.except("page")
    query["page"] = page.to_s if page.to_i > 1
    books_path(query)
  end
end
