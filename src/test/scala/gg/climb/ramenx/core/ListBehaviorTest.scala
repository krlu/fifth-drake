package gg.climb.ramenx.core

import gg.climb.ramenx.UnitTestSpec

/**
  * Created by prasanth on 7/21/16.
  */
class ListBehaviorTest extends UnitTestSpec {

  "A ListBehavior" should "provide a value at time t" in {
    val behavior = new ListBehavior[Int, Int](identity)
    assert(behavior.get(0).self == 0)
    assert(behavior.get(1).self == 1)
  }
}
