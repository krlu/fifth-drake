name := """fifth-drake"""

version := "1.0-SNAPSHOT"

lazy val root = (project in file(".")).enablePlugins(PlayJava)

scalaVersion := "2.11.7"

libraryDependencies ++= Seq(
  javaJdbc,
  cache,
  javaWs
)
classpathTypes += "maven-plugin"
libraryDependencies += "org.bytedeco" % "javacpp" % "1.1"
libraryDependencies += "org.bytedeco" % "javacv" % "1.1"
libraryDependencies += "com.google.code.gson" % "gson" % "2.6.2"
libraryDependencies += "com.github.mpkorstanje" % "simmetrics-core" % "3.0.1"
libraryDependencies += "com.github.jai-imageio" % "jai-imageio-core" % "1.3.1"
libraryDependencies += "org.mongodb" % "bson" % "3.2.2"
libraryDependencies += "org.mongodb" % "mongodb-driver" % "3.2.2"
libraryDependencies += "com.squareup.okio" % "okio-parent" % "1.7.0"
libraryDependencies += "com.squareup.okhttp3" % "parent" % "3.2.0"
libraryDependencies += "com.google.guava" % "guava" % "19.0"
libraryDependencies += "com.typesafe" % "config" % "1.3.0"

javaOptions in run += "-Docr.tessdataPath=" + Option(System.getProperty("ocr.tessdataPath")).getOrElse("C:\\Users\\Kenneth\\Documents\\GitHub\\esportsAnalyticsWeb\\app\\")

lazy val myProject = (project in file("."))
  .enablePlugins(PlayJava, PlayEbean)

fork in run := true
