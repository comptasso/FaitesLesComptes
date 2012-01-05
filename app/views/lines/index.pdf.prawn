@listing.total_pages.times do |t|
  pdf.table @listing.page(t)
end