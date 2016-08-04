package gg.climb.commons.dbhandling

import org.mongodb.scala.{Document, MongoClient, MongoCollection, Observable, Observer}

class MongoDBHandler(){
  val mongoClient: MongoClient = MongoClient()
  val names: Observable[String] = mongoClient.listDatabaseNames()
  val database = mongoClient.getDatabase("league_analytics")
	val collection: MongoCollection[Document] = database.getCollection("metadata")
	val element: Observable[Document] = collection.find().first()
	element.subscribe(new Observer[Document] {

		override def onNext(result: Document): Unit = println(result)

		override def onError(e: Throwable): Unit = println("Failed")

		override def onComplete(): Unit = println("Completed")
	})
}

object MongoDBHandler{
  def apply() = new MongoDBHandler()
  def main(args : Array[String]): Unit = {
    val dbh = MongoDBHandler()
  }
}
