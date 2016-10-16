import scala.util.matching.Regex

lazy val webpack = TaskKey[Unit]("Run webpack when packaging the application")

def runWebpack(file: File): Int = {
  val p: Regex = "(?i)windows".r
  val proc = sys.props("os.name") match {
    case p(x) => Process("cmd /c \"webpack " + file + "\"")
    case _ => Process("webpack", file)
  }
  proc.!
}

webpack := {
  if(runWebpack(baseDirectory.value) != 0) throw new Exception("Something goes wrong when running webpack.")
}

dist <<= dist dependsOn webpack

stage <<= stage dependsOn webpack

test <<= (test in Test) dependsOn webpack
