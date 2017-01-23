package gg.climb.ramenx

class ListBehaviorTest extends UnitTestSpec {

  "A ListBehavior" should "provide a value at time t" in {
    val behavior: ListBehavior[Int, Int] = new ListBehavior[Int, Int](identity: Int => Int)
    assert(behavior(0).self == 0)
    assert(behavior(1).self == 1)
  }

  it should "be creatable with a constant value" in {
    val behavior: Behavior[Int, Int] = ListBehavior.always[Int, Int](0)
    assert(behavior(0).self == 0)
    assert(behavior(1).self == 0)
    assert(behavior(10).self == 0)
  }

  it should "be mappable" in {
    val behavior: Behavior[Int, String] = new ListBehavior[Int, Int](identity).map(_.toString)
    assert(behavior(0) == "0")
    assert(behavior(1) == "1")
  }
}
