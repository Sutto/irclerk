function(doc)
{
  if(doc["type"] == "message") emit(doc.slug, doc);
}