import java.net.InetSocketAddress
import play.sbt.PlayRunHook
import sbt._

object Webpack {
	def apply(base: File): PlayRunHook = {
		object WebpackHook extends PlayRunHook {
			var process: Option[Process] = None

			override def beforeStarted(): Unit = {
				process = Option(
					                Process("npm run build", base).run()
				                )
			}

			override def afterStarted(addr: InetSocketAddress): Unit = {
				process = Option(
					                Process("npm run watch", base).run()
				                )
			}

			override def afterStopped(): Unit = {
				process.foreach(_.destroy())
				process = None
			}
		}

		WebpackHook
	}
}
