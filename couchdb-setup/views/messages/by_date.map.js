function(doc)
{
  if(doc["type"] == "message") emit([doc.date, Date.parse(doc.received_at)], doc);
}