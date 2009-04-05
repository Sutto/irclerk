function(doc)
{
  if(doc["type"] == "message") emit([doc.slug, Date.parse(doc.received_at)], doc);
}