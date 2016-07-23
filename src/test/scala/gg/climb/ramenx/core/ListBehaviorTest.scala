package gg.climb.ramenx.core

import gg.climb.ramenx.UnitTestSpec

import scala.runtime.RichInt

/**
  * Created by prasanth on 7/21/16.
  */
class ListBehaviorTest extends UnitTestSpec {

  "A ListBehavior" should "provide a value at time t" in {
    val behavior: ListBehavior[RichInt, RichInt] = new ListBehavior[RichInt, RichInt](identity)
    assert(behavior.get(new RichInt(0)).self == 0)
    assert(behavior.get(new RichInt(1)).self == 1)
  }
}
