import java.io.FileInputStream
import java.util.Properties
import collection.JavaConversions._

name := """fifth-drake"""

lazy val root = (project in file("."))
                .enablePlugins(PlayScala, BuildInfoPlugin, GitVersioning, GitBranchPrompt)

buildInfoKeys := Seq[BuildInfoKey](name, version, scalaVersion, sbtVersion)
buildInfoPackage := "controllers"
buildInfoOptions += BuildInfoOption.ToJson

git.useGitDescribe := true

flywayUrl := "jdbc:postgresql://localhost:5432/league_analytics"
flywaySchemas := Seq("audit", "league")
flywayLocations := Seq("filesystem:postgres/")

scalastyleConfig := new File("project/scalastyle-config.xml")
scalastyleFailOnError := true

scalaVersion := "2.11.7"

libraryDependencies ++= Seq(
  jdbc,
  cache,
  ws,

  "org.postgresql" % "postgresql" % "9.4.1208.jre7",
  "org.slf4j" % "slf4j-api" % "1.7.21",

  "com.typesafe.scala-logging" %% "scala-logging" % "3.4.0",
  "org.mongodb.scala" %% "mongo-scala-driver" % "1.0.1",
  "org.scalikejdbc" %% "scalikejdbc" % "2.4.2",
  "org.scalikejdbc" %% "scalikejdbc-config" % "2.4.2",
  "org.scalikejdbc" %% "scalikejdbc-interpolation" % "2.4.2",
  "org.scalaz" %% "scalaz-core" % "7.2.4",

  "org.scalatest" %% "scalatest" % "3.0.0" % Test,
  "org.scalatestplus.play" %% "scalatestplus-play" % "1.5.1" % Test
)

classpathTypes += "maven-plugin"

PlayKeys.playRunHooks <+= baseDirectory.map(Webpack.apply)

fork in run := true

def fileToOption (f : File) : Option[String] =
  if (f.exists) {
    Some(f.getAbsolutePath)
  }
  else {
    None
  }

javaOptions ++=
  List( sys.props.get("fifth-drake.properties")
      , fileToOption(baseDirectory(_ / "conf" / "fifth-drake.local.properties").value)
      , fileToOption(baseDirectory(_ / "conf" / "fifth-drake.properties").value)
      )
    .find(_.isDefined)
    .flatten
    .map { propsPath =>
      val fifthDrakeProps: Properties = new Properties()
      var opts: List[String] = List()
      fifthDrakeProps.load(new FileInputStream(propsPath))
      for ((k, v) <- fifthDrakeProps) {
        opts = s"-D$k=$v" :: opts
      }
      opts
    }.getOrElse(List())
