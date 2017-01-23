package gg.climb.ramenx

/**
  * Created by prasanth on 8/20/16.
  */
class ListEventStreamTest extends UnitTestSpec {

  it should "convert to a Behavior via the step function" in {
    type Time = Int
    val initial = (0,1)
    val last = (5,2)
    val e: EventStream[Time, Int] = new ListEventStream[Time, Int](List())
    val stepped: Behavior[Time, Int] = e.stepper(initial, last)
  }
}
