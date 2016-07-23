package gg.climb.ramenx.core

import gg.climb.ramenx.UnitTestSpec

class ListBehaviorTest extends UnitTestSpec {

  "A ListBehavior" should "provide a value at time t" in {
    val behavior: ListBehavior[Int, Int] = new ListBehavior[Int, Int](identity: Int => Int)
    assert(behavior.get(0).self == 0)
    assert(behavior.get(1).self == 1)
  }

  it should "be creatable with a constant value" in {
    val behavior: Behavior[Int, Int] = ListBehavior.pure[Int, Int](0)
    assert(behavior.get(0).self == 0)
    assert(behavior.get(1).self == 0)
    assert(behavior.get(10).self == 0)
  }
}
