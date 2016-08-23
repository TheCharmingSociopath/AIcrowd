sql = "
SELECT i.id, i.data, i.imageable_id AS product_id
FROM images i,
     categorisations c
WHERE c.categorisable_id = i.id
AND c.category_id = 1
AND EXISTS (SELECT 'x' FROM products p WHERE status = 'complete' AND i.imageable_id = p.id)
AND EXISTS (SELECT 'x' FROM transformations t WHERE t.image_id = i.id)
"

results = Image.find_by_sql(sql)


results.each do |image|
  puts "wget --output-document image-#{image.product_id}.jpg #{image.data.url(:xlarge)} "
end
