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

resolvers += Resolver.mavenLocal

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

  "org.scalatest" %% "scalatest" % "3.0.0" % Test,
  "org.scalatestplus.play" %% "scalatestplus-play" % "1.5.1" % Test,

	"gg.climb" % "ramenX" % "0.0.2"
)

classpathTypes += "maven-plugin"

PlayKeys.playRunHooks <+= baseDirectory.map(Webpack.apply)


fork in run := true
