import com.esag.lolobjects.RiotId
import com.esag.lolobjects.esports.Player
import com.esag.lolobjects.game.ChampionStats
import rx.lang.scala.Observable
/**
  * Created by prasanth on 7/2/16.
  */
trait DbStream {

  type Gold = Int
  type Hp = Int
  type Xp = Int
  type Resource = Int
  type Damage = Int
  type Item

  def getMinionKills(player: Player) : Observable[Int]

  def getCurrentGold(player: Player) : Observable[Gold]
  def getTotalGold(player: Player) : Observable[Gold]

  def getCurrentHp(player: Player) : Observable[Hp]
  def getMaxHp(player: Player) : Observable[Hp]

  def getXp(player: Player) : Observable[Xp]

  def getCurrentResource(player: Player) : Observable[Resource]
  def getMaxResource(player: Player) : Observable[Resource]

  def getTotalDamage(player: Player) : Observable[Damage]

  def getChampionStats(player: Player) : Observable[ChampionStats]

  def getItems(player: Player) : Observable[RiotId[Item]]
}
