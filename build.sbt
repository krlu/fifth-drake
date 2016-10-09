name := """fifth-drake"""

version := "1.0-SNAPSHOT"

lazy val root = (project in file("."))
                .enablePlugins(PlayScala, BuildInfoPlugin, GitVersioning, GitBranchPrompt)

buildInfoKeys := Seq[BuildInfoKey](name, version, scalaVersion, sbtVersion)
buildInfoPackage := "controllers"
buildInfoOptions += BuildInfoOption.ToJson

git.useGitDescribe := true

scalaVersion := "2.11.7"

resolvers += Resolver.mavenLocal

libraryDependencies ++= Seq(
  jdbc,
  cache,
  ws,
  "org.scalatestplus.play" %% "scalatestplus-play" % "1.5.1" % Test,
	"gg.climb" % "climb-core" % "0.0.1"
)

classpathTypes += "maven-plugin"

PlayKeys.playRunHooks <+= baseDirectory.map(Webpack.apply)


fork in run := true
